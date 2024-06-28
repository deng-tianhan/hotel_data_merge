class AddDestinationToHotels < ActiveRecord::Migration[7.1]
  def change
    add_column :hotels, :destination, :integer
  end
end
