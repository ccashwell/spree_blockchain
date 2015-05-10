module Spree
  CheckoutController.class_eval do
    before_filter :payment_instructions_redirect, only: :update

    private

    def payment_instructions_redirect
      return unless current_order.present? && params[:state] == "payment"

      method_id = params[:order][:payments_attributes].first[:payment_method_id]
      payment_method = PaymentMethod.find_by_id(method_id)
      if payment_method.is_a? Spree::PaymentMethod::Blockchain
        redirect_to spree_blockchain_instructions_url(payment_method_id: method_id)
      end
    end
  end
end
