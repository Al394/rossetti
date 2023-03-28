class CreateCustomizations < ActiveRecord::Migration[6.1]
  def change
    create_table :customizations do |t|
      t.string :parameter
      t.string :value
      t.string :um
      t.text :notes
      t.timestamps
    end
  end
end
