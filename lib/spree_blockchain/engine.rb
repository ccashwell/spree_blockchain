module SpreeBlockchain
  class Engine < Rails::Engine
    engine_name 'spree_blockchain'

    config.to_prepare do
    	Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
			Rails.configuration.cache_classes ? require(c) : load(c)
		end
	end

    initializer "spree.spree_blockchain.payment_methods", after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::Blockchain
    end
  end
end
