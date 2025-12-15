class SearchResult < ApplicationRecord
  belongs_to :api_request
  belongs_to :movie
end
