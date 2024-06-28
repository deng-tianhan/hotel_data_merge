class CreateAmenities < ActiveRecord::Migration[7.1]
  def change
    create_table :amenities do |t|
      t.integer :hotel_id
      t.string :name

      t.timestamps
    end
  end
end
