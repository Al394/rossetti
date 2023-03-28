class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.belongs_to :user
      t.belongs_to :resource, polymorphic: true
      t.boolean :read, default: false
      t.string :kind
      t.text :notes
      t.timestamps
    end
  end
end
