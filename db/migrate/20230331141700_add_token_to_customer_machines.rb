class AddTokenToCustomerMachines < ActiveRecord::Migration[6.1]
  def change
    add_column :customer_machines, :token, :string, default: nil
  end
end
