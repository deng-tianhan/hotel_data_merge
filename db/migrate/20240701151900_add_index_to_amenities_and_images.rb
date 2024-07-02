class AddIndexToAmenitiesAndImages < ActiveRecord::Migration[7.1]
  def change
    add_index :amenities, %i[ hotel_id category name ], unique: true
    add_index :images, %i[ imageable_type imageable_id link ], unique: true
  end
end
