require 'blockchain'

class Spree::BlockchainController < Spree::BaseController
  include Spree::Core::ControllerHelpers::Order
	skip_before_filter :verify_authenticity_token

	def instructions
    report_error! and return unless current_order.present?
    payment, transaction = verify_or_initiate_payment!

    case payment.state
    when "processing"
      render :instructions, locals: {
        address: transaction.receiving_address,
        amount_expected: transaction.amount_in_btc,
        amount_received: transaction.amount_received,
        cancel_url: spree_blockchain_cancel_url
      }
    when "completed"
      ensure_proper_order_state!
      redirect_to spree_blockchain_success_url(order_num: current_order.number)
    end and return
	end

	def callback
    # lookup order data
    order = Spree::Order.find_by_number(params[:o])

		# find the first incomplete payment with a matching token
    payment = bitcoin_payments(order).processing.find do |incomplete_payment|
      incomplete_payment.source.secret_token == params[:s]
    end

    if payment.present?
      verify_payment!(payment)
    else
      render(text: "*payment not found*", status: :not_found) and return
    end

    render(text: "*ok*", status: :ok)
	end

	def cancel
    payment = bitcoin_payments.processing.last
    notice = Spree.t(:spree_blockchain_cancel_error)

    if payment.present? && payment.amount == 0.0
      payment.void!
      notice = Spree.t(:spree_blockchain_checkout_cancelled)
    end

    current_order.empty! and session.delete(:order_id)

    redirect_to root_url, notice: notice
	end

	def success
    order = Spree::Order.find_by_number(params[:order_num])
    if order.try(:complete?)
      session.delete(:order_id)
      redirect_to spree.order_url(order), notice: Spree.t(:order_processed_successfully)
    else
      report_error! and return
    end
	end

	private

	def payment_method
    if params[:payment_method_id].present?
      Spree::PaymentMethod.find(params[:payment_method_id])
    else
      Spree::PaymentMethod::Blockchain.take
    end
	end

  def bitcoin_payments order = current_order
    order.bitcoin_payments.processing
  end

  def report_error! order = current_order, notice = Spree.t(:spree_blockchain_checkout_error)
    target = order ? spree.edit_order_url(order, state: "payment") : root_url
    redirect_to target, notice: notice
  end

  def total_in_btc order = current_order
    Blockchain.to_btc("USD", order.total.to_f)
  end

  def verify_or_initiate_payment!
    bitcoin_payments.any? ? verify_payment! : initiate_payment!
  end

  def initiate_payment! order = current_order
    # create a secret token to verify the payment
    secret_token = SecureRandom.urlsafe_base64(30)

    # create a single-use payment receiving address
    receiver = Blockchain.receive(
      payment_method.preferred_final_address,
      spree_blockchain_callback_url(o: order.number, s: secret_token)
    )

    # create a transaction (for verifying the payment later)
    transaction = Spree::BlockchainTransaction.new(
      amount_in_btc: total_in_btc,
      amount_received: 0.0,
      order_total: order.total,
      order_id: order.number,
      receiving_address: receiver.input_address,
      secret_token: secret_token
    )

    # create a payment
    payment = order.payments.create(
      payment_method: payment_method,
      source: transaction
    )

    # start processing the payment
    payment.started_processing!

    # update the order to reflect changes
    order.update!
    return payment, transaction
  rescue
    report_error! order, Spree.t(:spree_blockchain_unavailable)
  end

  def verify_payment! payment = bitcoin_payments.last
    # find the order and transaction
    order, transaction = payment.order, payment.source

    payment.started_processing! if payment.void?
    if transaction.order_total != order.total
      transaction.update_attributes!(
        amount_in_btc: total_in_btc,
        order_total: order.total
      )
    end

    # update the transaction to reflect amounts received in bitcoin
    amount_received = received_funds(transaction.receiving_address)
    transaction.update_attributes!(amount_received: amount_received)

    # update the payment to reflect USD equivalent of amounts received
    payment.update_attributes!(
      amount: transaction.order_total * (amount_received / transaction.amount_in_btc)
    )

    payment.complete! if transaction.satisfied?

    unless order.complete?
      order.update!
      order.next if payment.completed?
    end

    return payment, transaction
  end

  def received_funds address
    blockchain_address = Blockchain.get_address(address)
    blockchain_address.total_received / 10.0**8
  rescue
    0.0
  end

  def ensure_proper_order_state! order = current_order
    order ||= Spree::Order.find_by_number(params[:order_num])
    return if order.nil? || order.complete?
    if bitcoin_payments(order).completed.any?
      order.update!
      order.next
    end
  end
end
