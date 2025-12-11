class Movie < ApplicationRecord
  validates :title, presence: true
  validates :tmdb_id, presence: true, uniqueness: true
  validates :release_date, presence: true
  
  has_many :search_results, dependent: :destroy
end

