class CreateOffices < ActiveRecord::Migration[7.1]
  def change
    create_table :offices do |t|
      t.text :municipality
      t.text :country
      t.float :lat
      t.float :lon

      t.timestamps
    end
  end
end
