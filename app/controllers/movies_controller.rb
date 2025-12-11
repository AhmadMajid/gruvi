class MoviesController < ApplicationController
  def index
    @movies = []
    @errors = []
    @current_page = (params[:page] || 1).to_i
    @total_pages = 0
    @sort_by = params[:sort_by] || 'popularity'
    
    if params[:start_date].present? && params[:end_date].present?
      begin
        Rails.logger.info "Received start_date: #{params[:start_date].inspect}"
        Rails.logger.info "Received end_date: #{params[:end_date].inspect}"
        
        start_date = parse_date(params[:start_date])
        end_date = parse_date(params[:end_date])
        
        if start_date > end_date
          @errors << "Start date must be before end date"
        else
          result = search_movies_by_date_range(start_date, end_date, @current_page, @sort_by)
          @movies = result[:movies]
          @total_pages = result[:total_pages]
        end
      rescue ArgumentError, Date::Error => e
        @errors << "Invalid date format. Please select valid dates."
      rescue StandardError => e
        @errors << "An error occurred while searching for movies: #{e.message}"
        Rails.logger.error "Movie search error: #{e.message}\n#{e.backtrace.join("\n")}"
      end
    end
  end
  
  private
  
  def search_movies_by_date_range(start_date, end_date, page = 1, sort_by = 'popularity')

    cache_key = "discover/movie?start_date=#{start_date}&end_date=#{end_date}&page=#{page}&sort=#{sort_by}"
    
    cached_request = ApiRequest.where(url: cache_key)
                               .where('created_at > ?', ApiRequest::CACHE_EXPIRY.ago)
                               .first
    
    if cached_request
      Rails.logger.info "Using cached search results for: #{cache_key}"
      movies = cached_request.search_results.order(:position).map(&:movie)
      total_pages = get_total_pages(start_date, end_date)
      { movies: movies, total_pages: total_pages }
    else
      Rails.logger.info "Fetching new results from TMDb for: #{cache_key}"
      result = fetch_from_tmdb(start_date, end_date, page, sort_by)
      movies = result[:movies]
      total_pages = result[:total_pages]
      
      api_request = ApiRequest.create!(url: cache_key)
      movies.each_with_index do |movie, index|
        SearchResult.create!(
          api_request: api_request,
          movie: movie,
          position: index
        )
      end
      
      { movies: movies, total_pages: total_pages }
    end
  end
  
  def get_total_pages(start_date, end_date)

    response = Tmdb::Discover.movie(
      'primary_release_date.gte' => start_date.to_s,
      'primary_release_date.lte' => end_date.to_s,
      'page' => 1
    )
    [response.total_pages, 500].min
  rescue => e
    Rails.logger.error "Error fetching total pages: #{e.message}"
    1
  end
  
  def fetch_from_tmdb(start_date, end_date, page = 1, sort_by = 'popularity')
    movies = []
    total_pages = 1
    
    tmdb_sort = case sort_by
    when 'popularity'
      'popularity.desc'
    when 'rating'
      'vote_average.desc'
    when 'votes'
      'vote_count.desc'
    when 'newest'
      'primary_release_date.desc'
    when 'oldest'
      'primary_release_date.asc'
    when 'alphabetical'
      'title.asc'
    else
      'popularity.desc'
    end
    
    query_params = {
      'primary_release_date.gte' => start_date.to_s,
      'primary_release_date.lte' => end_date.to_s,
      'sort_by' => tmdb_sort,
      'page' => page
    }
    
    if sort_by == 'rating'
      query_params['vote_count.gte'] = 20
    end
    
    response = Tmdb::Discover.movie(query_params)
    
    total_pages = [response.total_pages, 500].min
    Rails.logger.info "Page #{page}/#{total_pages}: Found #{response.results.count} results"
      
    response.results.each do |result|
        next if result.release_date.nil?
        
        begin
          movie_date = Date.parse(result.release_date)
          
          if movie_date < start_date || movie_date > end_date
            next
          end
          
          movie = Movie.find_or_initialize_by(tmdb_id: result.id)
          movie.update(
            title: result.title,
            release_date: movie_date,
            overview: result.overview || '',
            poster_path: result.poster_path,
            popularity: result.popularity,
            vote_average: result.vote_average,
            vote_count: result.vote_count,
            revenue: result.revenue
          )
          movies << movie
        rescue ArgumentError => e
          Rails.logger.warn "Skipping movie with invalid date: #{result.title} (#{result.release_date})"
          next
        end
    end
    
    Rails.logger.info "Total pages available: #{total_pages}"
    
    { movies: movies, total_pages: total_pages }
  end
  
  def parse_date(date_string)
    return nil if date_string.blank?

    if date_string.match?(/\A\d{2}\/\d{2}\/\d{4}\z/)
      day, month, year = date_string.split('/').map(&:to_i)
      Date.new(year, month, day)
    else
      Date.parse(date_string)
    end
  end
end

