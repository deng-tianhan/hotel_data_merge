class AddMetadataToHotels < ActiveRecord::Migration[7.1]
  def change
    add_column :hotels, :metadata, :json
  end
end
