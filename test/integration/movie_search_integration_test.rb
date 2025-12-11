require "test_helper"

class MovieSearchIntegrationTest < ActionDispatch::IntegrationTest
  test "complete movie search flow" do
    get movies_index_url
    assert_response :success
    assert_select "h1", "Movie Search"
    
    assert_select "form"
    assert_select "input[name='start_date']"
    assert_select "input[name='end_date']"
    assert_select "select[name='sort_by']"
    
    mock_movie_data = OpenStruct.new(
      id: 555555,
      title: "Integration Test Movie",
      release_date: "2025-06-15",
      overview: "A great test movie",
      poster_path: "/test.jpg",
      popularity: 100.0,
      vote_average: 8.5,
      vote_count: 500,
      revenue: nil
    )
    
    mock_response = OpenStruct.new(results: [mock_movie_data], total_pages: 1)
    Tmdb::Discover.stubs(:movie).returns(mock_response)
    
    get movies_index_url, params: {
      start_date: "2025-06-01",
      end_date: "2025-06-30"
    }
    
    assert_response :success
    
    assert_select ".movie-card" do
      assert_select "h3", "Integration Test Movie"
      assert_select ".overview", /A great test movie/
    end
    
    movie = Movie.find_by(tmdb_id: 555555)
    assert_not_nil movie
    assert_equal "Integration Test Movie", movie.title
    assert_equal 8.5, movie.vote_average
  end
  
  test "date formatting in display" do
    movie_data = OpenStruct.new(
      id: 777777,
      title: "Date Format Test",
      release_date: "2025-12-25",
      overview: "Testing date display",
      poster_path: nil,
      popularity: 50.0,
      vote_average: 7.0,
      vote_count: 100,
      revenue: nil
    )
    
    mock_response = OpenStruct.new(results: [movie_data], total_pages: 1)
    Tmdb::Discover.stubs(:movie).returns(mock_response)
    
    get movies_index_url, params: {
      start_date: "2025-12-01",
      end_date: "2025-12-31"
    }
    
    assert_response :success
    assert_select ".release-date", text: /25\/12\/2025/
  end
  
  test "modal functionality elements are present" do
    mock_response = OpenStruct.new(results: [], total_pages: 1)
    Tmdb::Discover.stubs(:movie).returns(mock_response)
    
    get movies_index_url, params: {
      start_date: "2025-01-01",
      end_date: "2025-12-31"
    }
    
    assert_response :success
    assert_select "script", text: /openModal/
    assert_select "script", text: /closeModal/
  end
end
