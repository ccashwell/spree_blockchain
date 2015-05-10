module Spree
  class BlockchainTransaction < ActiveRecord::Base
    has_many :payments, as: :source

    def actions
      []
    end

    def satisfied?
      amount_received >= amount_in_btc
    end
  end
end
