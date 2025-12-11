class CreateSearchResults < ActiveRecord::Migration[8.1]
  def change
    create_table :search_results do |t|
      t.references :api_request, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
