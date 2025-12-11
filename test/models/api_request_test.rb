require "test_helper"

class ApiRequestTest < ActiveSupport::TestCase
  test "should not save api_request without url" do
    request = ApiRequest.new
    assert_not request.save, "Saved api_request without url"
  end
  
  test "should not save duplicate url" do
    ApiRequest.create!(url: "http://example.com/api")
    request = ApiRequest.new(url: "http://example.com/api")
    assert_not request.save, "Saved api_request with duplicate url"
  end
  
  test "CACHE_EXPIRY should be 24 hours" do
    assert_equal 24.hours, ApiRequest::CACHE_EXPIRY
  end
  
  test "cache method should execute block on first call" do
    url = "http://test.com/#{Time.now.to_i}"
    executed = false
    
    ApiRequest.cache(url) do
      executed = true
      "result"
    end
    
    assert executed, "Block was not executed"
    assert ApiRequest.exists?(url: url), "ApiRequest was not created"
  end
  
  test "cache method should return cached symbol on subsequent call within expiry" do
    url = "http://test.com/cached/#{Time.now.to_i}"
    
    ApiRequest.cache(url) { "first" }
    
    result = ApiRequest.cache(url) { "second" }
    
    assert_equal :cached, result
  end
  
  test "cache method should execute block again after cache expiry" do
    url = "http://test.com/expired/#{Time.now.to_i}"
    
    request = ApiRequest.create!(url: url)
    request.update_column(:updated_at, (ApiRequest::CACHE_EXPIRY + 1.hour).ago)
    
    executed = false
    result = ApiRequest.cache(url) do
      executed = true
      "fresh"
    end
    
    assert executed, "Block was not executed for expired cache"
    assert_equal "fresh", result
  end
  
  test "should have association with search_results" do
    api_request = api_requests(:one)
    assert_respond_to api_request, :search_results
  end
  
  test "should destroy associated search_results when api_request is destroyed" do
    api_request = ApiRequest.create!(url: "test/url/#{Time.now.to_i}")
    movie = movies(:one)
    SearchResult.create!(api_request: api_request, movie: movie, position: 0)
    
    assert_difference 'SearchResult.count', -1 do
      api_request.destroy
    end
  end
end

