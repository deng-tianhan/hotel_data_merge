class AddCategoryToAmenities < ActiveRecord::Migration[7.1]
  def change
    add_column :amenities, :category, :string
  end
end
