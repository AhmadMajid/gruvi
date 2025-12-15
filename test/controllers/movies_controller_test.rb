require "test_helper"

class MoviesControllerTest < ActionDispatch::IntegrationTest
  test "should get index without parameters" do
    get movies_index_url
    assert_response :success
    assert_select "h1", "Movie Search"
  end
  
  test "should handle DD/MM/YYYY date format" do
    mock_response = OpenStruct.new(results: [], total_pages: 1)
    
    Tmdb::Discover.stubs(:movie).returns(mock_response)
    
    get movies_index_url, params: { 
      start_date: "01/01/2025", 
      end_date: "31/12/2025" 
    }
    assert_response :success
    refute_select ".error", "Should not show error for valid DD/MM/YYYY format"
  end
  
  test "should handle YYYY-MM-DD date format" do
    mock_response = OpenStruct.new(results: [], total_pages: 1)
    
    Tmdb::Discover.stubs(:movie).returns(mock_response)
    
    get movies_index_url, params: { 
      start_date: "2025-01-01", 
      end_date: "2025-12-31" 
    }
    assert_response :success
    refute_select ".error", "Should not show error for valid YYYY-MM-DD format"
  end
  
  test "should show error for invalid date format" do
    get movies_index_url, params: { 
      start_date: "invalid", 
      end_date: "2025-12-31" 
    }
    assert_response :success
    assert_select ".error", text: /Invalid date format/
  end
  
  test "should show error when start_date is after end_date" do
    get movies_index_url, params: { 
      start_date: "2025-12-31", 
      end_date: "2025-01-01" 
    }
    assert_response :success
    assert_select ".error", text: /Start date must be before end date/
  end
  
  test "should accept sort_by parameter" do
    mock_response = OpenStruct.new(results: [], total_pages: 1)
    
    Tmdb::Discover.stubs(:movie).returns(mock_response)
    
    get movies_index_url, params: { 
      start_date: "2025-01-01", 
      end_date: "2025-12-31",
      sort_by: "rating"
    }
    assert_response :success
  end
  
  test "should accept page parameter" do
    mock_response = OpenStruct.new(results: [], total_pages: 5)
    
    Tmdb::Discover.stubs(:movie).returns(mock_response)
    
    get movies_index_url, params: { 
      start_date: "2025-01-01", 
      end_date: "2025-12-31",
        page: 2
    }
    assert_response :success
    assert_equal 2, assigns(:current_page)
  end
  
  test "should use cached results when available" do
    cache_key = "discover/movie?start_date=2025-05-01&end_date=2025-05-31&page=1&sort=popularity"
    api_request = ApiRequest.create!(url: cache_key, response_data: { 'total_pages' => 5 })
    movie = Movie.create!(title: "Cached Movie May", tmdb_id: 888888, release_date: "2025-05-15")
    SearchResult.create!(api_request: api_request, movie: movie)
    
    mock_response = OpenStruct.new(results: [], total_pages: 1)
    Tmdb::Discover.stubs(:movie).returns(mock_response)
    
    get movies_index_url, params: { 
      start_date: "2025-05-01", 
      end_date: "2025-05-31"
    }
    assert_response :success
    
    assert_includes assigns(:movies).map(&:tmdb_id), 888888
  end
  
  test "should handle network errors gracefully" do
    Tmdb::Discover.stubs(:movie).raises(StandardError.new("Network error"))
    
    get movies_index_url, params: { 
      start_date: "2030-07-01", 
      end_date: "2030-07-31"
    }
    assert_response :success
    assert_match /An error occurred/, response.body
  end
  
  test "should refresh expired cache and reuse same ApiRequest record" do
    cache_key = "discover/movie?start_date=2025-06-01&end_date=2025-06-30&page=1&sort=popularity"
    api_request = ApiRequest.create!(url: cache_key, response_data: { 'total_pages' => 2 })
    old_movie = Movie.create!(title: "Old Cached Movie", tmdb_id: 999999, release_date: "2025-06-15")
    SearchResult.create!(api_request: api_request, movie: old_movie)
    
    api_request.update_column(:created_at, 25.hours.ago)
    
    initial_api_request_id = api_request.id
    initial_api_request_count = ApiRequest.count
    
    new_movie_data = OpenStruct.new(
      id: 111111,
      title: "Fresh Movie",
      release_date: "2025-06-20",
      overview: "A new movie",
      poster_path: "/path.jpg",
      popularity: 100.0,
      vote_average: 8.5,
      vote_count: 1000
    )
    mock_response = OpenStruct.new(results: [new_movie_data], total_pages: 1)
    Tmdb::Discover.stubs(:movie).returns(mock_response)
    
    get movies_index_url, params: { 
      start_date: "2025-06-01", 
      end_date: "2025-06-30"
    }
    assert_response :success
    
    assert_equal initial_api_request_count, ApiRequest.count, "Should not create duplicate ApiRequest"
    
    api_request.reload
    assert_equal initial_api_request_id, api_request.id, "Should reuse same ApiRequest record"
    assert api_request.updated_at > 1.hour.ago, "Should update timestamp on expired cache"
    
    assert_equal 1, api_request.search_results.count, "Should have new search results"
    assert_equal 111111, api_request.search_results.first.movie.tmdb_id, "Should have fresh movie data"
    
    assert_includes assigns(:movies).map(&:tmdb_id), 111111, "Should show fresh movie"
    refute_includes assigns(:movies).map(&:tmdb_id), 999999, "Should not show old cached movie"
  end
end
