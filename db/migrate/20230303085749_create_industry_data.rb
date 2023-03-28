class CreateIndustryData < ActiveRecord::Migration[6.1]
  def change
    create_table :industry_data do |t|
      t.belongs_to :customer_machine
      t.string :jdf_url
      t.string :job_id
      t.string :file_name
      t.string :folder
      t.string :material, default: ""
      t.string :duration
      t.string :extra_data
      t.string :status
      t.text :ink
      t.integer :quantity, default: 0
      t.datetime :start_at
      t.datetime :ends_at
      t.datetime :sent_to_gest
      t.timestamps
    end
  end
end
