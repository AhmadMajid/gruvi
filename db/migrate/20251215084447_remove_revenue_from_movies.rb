class RemoveRevenueFromMovies < ActiveRecord::Migration[8.1]
  def change
    remove_column :movies, :revenue, :integer
  end
end
