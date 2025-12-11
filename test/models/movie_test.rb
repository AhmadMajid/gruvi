require "test_helper"

class MovieTest < ActiveSupport::TestCase
  test "should not save movie without title" do
    movie = Movie.new(tmdb_id: 123, release_date: Date.today)
    assert_not movie.save, "Saved movie without title"
  end
  
  test "should not save movie without tmdb_id" do
    movie = Movie.new(title: "Test Movie", release_date: Date.today)
    assert_not movie.save, "Saved movie without tmdb_id"
  end
  
  test "should not save movie without release_date" do
    movie = Movie.new(title: "Test Movie", tmdb_id: 123)
    assert_not movie.save, "Saved movie without release_date"
  end
  
  test "should not save duplicate tmdb_id" do
    Movie.create!(title: "Movie 1", tmdb_id: 123, release_date: Date.today)
    movie = Movie.new(title: "Movie 2", tmdb_id: 123, release_date: Date.today)
    assert_not movie.save, "Saved movie with duplicate tmdb_id"
  end
  
  test "should have association with search_results" do
    movie = movies(:one)
    assert_respond_to movie, :search_results
  end
  
  test "should destroy associated search_results when movie is destroyed" do
    movie = Movie.create!(title: "To Delete", tmdb_id: 999998, release_date: Date.today)
    api_request = api_requests(:one)
    SearchResult.create!(api_request: api_request, movie: movie, position: 10)
    
    assert_difference 'SearchResult.count', -1 do
      movie.destroy
    end
  end
end

