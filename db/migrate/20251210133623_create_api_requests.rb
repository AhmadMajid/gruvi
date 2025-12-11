class CreateApiRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :api_requests do |t|
      t.text :url

      t.timestamps
    end
    add_index :api_requests, :url, unique: true
  end
end
