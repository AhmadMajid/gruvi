class AddResponseDataToApiRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :api_requests, :response_data, :text
  end
end
