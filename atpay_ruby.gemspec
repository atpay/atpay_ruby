$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

Gem::Specification.new do |s|
  s.name          = 'atpay_ruby'
  s.version       = '0.0.5'
  s.summary       = 'Ruby bindings for the @Pay API'
  s.description   = ""
  s.authors       = ['James Kassemi']
  s.email         = ['james@atpay.com']
  s.homepage      = 'https://atpay.com'
  s.license       = 'MIT'

  s.add_runtime_dependency('rbnacl-libsodium', '~> 0.6.0')
  s.add_runtime_dependency('trollop', '~> 2.0')
  s.add_runtime_dependency('liquid', '~> 2.6.1')
  s.add_runtime_dependency('thor', '~> 0.18.1')
  s.add_runtime_dependency('httpi')
  s.add_runtime_dependency('multi_json')

  s.add_development_dependency('rspec', '~> 3.0.0')
  s.add_development_dependency('rspec-mocks', '~> 3.0.2')

  s.files         = `git ls-files`.split($/)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']
end
