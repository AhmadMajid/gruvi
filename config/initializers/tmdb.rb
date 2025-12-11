if ENV['TMDB_API_KEY'].present?
  Tmdb::Api.key(ENV['TMDB_API_KEY'])
  Tmdb::Api.language('en')
else
  Rails.logger.warn "TMDb API key not set. Please set TMDB_API_KEY environment variable."
end
