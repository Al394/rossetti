class AddCustomerMachineNameToIndustryDatum < ActiveRecord::Migration[6.1]
  def change
    add_column :industry_data, :customer_machine_name, :string

    puts 'Aggiorno IndustryData'
    IndustryDatum.all.each do |industry_datum|
      industry_datum.update_column(:customer_machine_name, industry_datum.customer_machine.name)
    end

  end
end
