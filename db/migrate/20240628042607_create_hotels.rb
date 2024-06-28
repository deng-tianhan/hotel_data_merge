class CreateHotels < ActiveRecord::Migration[7.1]
  def change
    create_table :hotels do |t|
      t.string :identifier
      t.string :name
      t.decimal :latitude
      t.decimal :longitude
      t.string :address
      t.string :city
      t.string :country
      t.string :postal_code
      t.string :description

      t.timestamps
    end
  end
end
