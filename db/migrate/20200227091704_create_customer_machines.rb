class CreateCustomerMachines < ActiveRecord::Migration[6.1]
  def change
    create_table :customer_machines do |t|
      t.string :name
      t.string :ip_address
      t.string :serial_number
      t.string :path
      t.string :username
      t.string :psw
      t.string :hotfolder_path
      t.string :import_job
      t.string :status
      t.boolean :is_mounted, default: false
      t.text :api_key
      t.timestamps
    end
  end
end
