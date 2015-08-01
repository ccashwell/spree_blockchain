Spree::Order.class_eval do
  def bitcoin_payments
    Spree::PaymentMethod::Blockchain.take.payments.where(order_id: self.id)
  rescue
    Spree::Payment.none
  end

  def bitcoin_payment_address
    bitcoin_payments.last.source.receiving_address
  end

  def bitcoin_payment_expected
    bitcoin_payments.map {|pmnt| pmnt.source.amount_in_btc }.sum
  end

  def bitcoin_payment_received
    bitcoin_payments.map {|pmnt| pmnt.source.amount_received }.sum
  end

  def bitcoin_payment_due
    bitcoin_payment_expected - bitcoin_payment_received
  end
end
