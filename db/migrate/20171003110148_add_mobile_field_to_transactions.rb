class AddMobileFieldToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :mobile, :string
    add_column :transactions, :transaction_number, :string
  end
end
