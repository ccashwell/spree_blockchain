Spree::Core::Engine.routes.draw do
  get "/spree_blockchain/cancel", to: "blockchain#cancel", as: :spree_blockchain_cancel
  get "/spree_blockchain/instructions", to: "blockchain#instructions", as: :spree_blockchain_instructions
  get "/spree_blockchain/success", to: "blockchain#success", as: :spree_blockchain_success
  get "/spree_blockchain/callback", to: "blockchain#callback", as: :spree_blockchain_callback
end
