class CreateMovies < ActiveRecord::Migration[8.1]
  def change
    create_table :movies do |t|
      t.integer :tmdb_id
      t.string :title
      t.date :release_date
      t.text :overview
      t.string :poster_path

      t.timestamps
    end
    add_index :movies, :tmdb_id, unique: true
  end
end
