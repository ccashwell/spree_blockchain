# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_blockchain'
  s.version     = '0.0.1'
  s.summary     = 'Accept bitcoin payments on Spree with Blockchain.info.'
  s.description = 'Accept bitcoin payments on your Spree store via the Blockchain.info API.'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Chris Cashwell'
  s.email     = 'ccashwell@gmail.com'
  s.homepage  = 'https://github.com/ccashwell/spree_blockchain'

  s.files       = `git ls-files`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.1.0.beta'
  s.add_dependency 'blockchain', '~> 1.0.2'
end
