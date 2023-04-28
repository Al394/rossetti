class AddOdlToIndustryDatum < ActiveRecord::Migration[6.1]
  def change
    add_column :industry_data, :odl, :string
  end
end
