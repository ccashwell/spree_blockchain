class CreateSpreeBlockchainTransactions < ActiveRecord::Migration
  def change
    create_table :spree_blockchain_transactions do |t|
      t.decimal :amount_in_btc
    	t.string  :order_id
    	t.string  :receiving_address
    	t.string  :secret_token
    end
  end
end
