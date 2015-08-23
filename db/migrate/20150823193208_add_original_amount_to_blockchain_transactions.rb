class AddOriginalAmountToBlockchainTransactions < ActiveRecord::Migration
  def down
    remove_column :spree_blockchain_transactions, :order_total
  end

  def up
    add_column :spree_blockchain_transactions, :order_total, :decimal
  end
end
