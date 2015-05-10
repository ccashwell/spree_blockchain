Spree Blockchain.info Plugin
=============

Accept bitcoin payments on your Spree store with this totally unofficial Blockchain.info API plugin. For more information on the Blockchain.info API for merchants, visit https://blockchain.info.

Installation
------------

Add spree_blockchain to your Gemfile:

```ruby
gem 'spree_blockchain'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_blockchain:install
```

After installing the gem, go to your Spree admin console and navigate to Configuration > Payment Methods > New Payment Method.

Select "Spree::PaymentMethod::Blockchain" from the "Provider" dropdown, enter a name (like "Bitcoin") for the payment method, and click "Create."

Enter the address where you want payments to be forwarded in the appropriate field on the Edit Payment Method page, then click "Update".

The plugin should now be active!
