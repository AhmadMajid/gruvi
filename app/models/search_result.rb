class SearchResult < ApplicationRecord
  belongs_to :api_request
  belongs_to :movie
  
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
