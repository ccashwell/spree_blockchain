module Spree
  class PaymentMethod::Blockchain < PaymentMethod
    preference :final_address, :string

    def auto_capture?
      false
    end

    def provider_class
      nil
    end

    def payment_source_class
      nil
    end

    def source_required?
      false
    end
  end
end
