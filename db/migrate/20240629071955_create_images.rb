class CreateImages < ActiveRecord::Migration[7.1]
  def change
    create_table :images do |t|
      t.belongs_to :imageable, polymorphic: true
      t.string :link
      t.string :caption
      t.string :category

      t.timestamps
    end
  end
end
