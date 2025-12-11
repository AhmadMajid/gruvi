require "test_helper"

class MoviesControllerHelperTest < ActionDispatch::IntegrationTest
  test "should handle all sort options" do
    sort_options = ['popularity', 'rating', 'votes', 'newest', 'oldest', 'alphabetical']
    
    sort_options.each do |sort_by|
      mock_response = OpenStruct.new(results: [], total_pages: 1)
      Tmdb::Discover.stubs(:movie).returns(mock_response)
      
      get movies_index_url, params: { 
        start_date: "2025-01-01", 
        end_date: "2025-12-31",
        sort_by: sort_by
      }
      assert_response :success, "Failed for sort_by: #{sort_by}"
    end
  end
  
  test "should map sort options to TMDb API parameters correctly" do
    sort_mappings = {
      'popularity' => 'popularity.desc',
      'rating' => 'vote_average.desc',
      'votes' => 'vote_count.desc',
      'newest' => 'primary_release_date.desc',
      'oldest' => 'primary_release_date.asc',
      'alphabetical' => 'title.asc'
    }
    
    sort_mappings.each_with_index do |(our_sort, tmdb_sort), index|

        start_day = 1 + (index * 2)
      end_day = start_day + 1
      
      captured_params = nil
      Tmdb::Discover.stubs(:movie).with { |params|
        captured_params ||= params
        true
      }.returns(OpenStruct.new(results: [], total_pages: 1))
      
      get movies_index_url, params: { 
        start_date: "2026-09-#{start_day.to_s.rjust(2, '0')}", 
        end_date: "2026-09-#{end_day.to_s.rjust(2, '0')}",
        sort_by: our_sort
      }
      
      assert_not_nil captured_params, "TMDb API was not called for #{our_sort}"
      assert_equal tmdb_sort, captured_params['sort_by'], "Sort mapping incorrect for #{our_sort}"
    end
  end
  
  test "should add vote_count filter when sorting by rating" do
    expected_params = nil
    
    Tmdb::Discover.stubs(:movie).with do |params|
      expected_params = params
      true
    end.returns(OpenStruct.new(results: [], total_pages: 1))
    
    get movies_index_url, params: { 
      start_date: "2025-01-01", 
      end_date: "2025-12-31",
      sort_by: "rating"
    }
    
    assert_equal 20, expected_params['vote_count.gte'], "vote_count.gte filter not added for rating sort"
  end
  
  test "should limit total pages to 500" do
    mock_response = OpenStruct.new(results: [], total_pages: 1000)
    Tmdb::Discover.stubs(:movie).returns(mock_response)
    
    get movies_index_url, params: { 
      start_date: "2020-01-01", 
      end_date: "2025-12-31"
    }
    assert_equal 500, assigns(:total_pages), "Total pages not capped at 500"
  end
end
