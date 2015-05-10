class AddAmountReceivedToSpreeBlockchainTransactions < ActiveRecord::Migration
  def down
    remove_column :spree_blockchain_transactions, :amount_received
  end

  def up
    add_column :spree_blockchain_transactions, :amount_received, :decimal
  end
end
