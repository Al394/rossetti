class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.string :code, uniq: true
      t.string :name, uniq: true
      t.integer :value, uniq: true
      t.timestamps
    end
  end

  add_reference :users, :role
end
