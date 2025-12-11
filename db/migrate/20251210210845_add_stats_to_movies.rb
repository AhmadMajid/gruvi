class AddStatsToMovies < ActiveRecord::Migration[8.1]
  def change
    add_column :movies, :popularity, :float
    add_column :movies, :vote_average, :float
    add_column :movies, :vote_count, :integer
    add_column :movies, :revenue, :integer
  end
end
