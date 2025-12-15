require "test_helper"

class SearchResultTest < ActiveSupport::TestCase
  test "should not save search_result without api_request" do
    movie = movies(:one)
    result = SearchResult.new(movie: movie)
    assert_not result.save, "Saved search_result without api_request"
  end
  
  test "should not save search_result without movie" do
    api_request = api_requests(:one)
    result = SearchResult.new(api_request: api_request)
    assert_not result.save, "Saved search_result without movie"
  end
  
  test "should save valid search_result" do
    api_request = api_requests(:one)
    movie = Movie.create!(title: "Valid Movie", tmdb_id: 99998, release_date: Date.today)
    result = SearchResult.new(api_request: api_request, movie: movie)
    assert result.save, "Failed to save valid search_result"
  end
  
  test "should allow multiple search_results for same api_request" do
    api_request = ApiRequest.create!(url: "test/multi/#{Time.now.to_i}")
    movie1 = movies(:one)
    movie2 = movies(:two)
    
    result1 = SearchResult.create!(api_request: api_request, movie: movie1)
    result2 = SearchResult.create!(api_request: api_request, movie: movie2)
    
    assert_equal 2, api_request.search_results.count
  end
end
