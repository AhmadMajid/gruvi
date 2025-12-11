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
    api_request = ApiRequest.create!(url: cache_key)
    movie = Movie.create!(title: "Cached Movie May", tmdb_id: 888888, release_date: "2025-05-15")
    SearchResult.create!(api_request: api_request, movie: movie, position: 0)
    
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
end
