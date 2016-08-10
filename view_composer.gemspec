# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'view_composer/version'

Gem::Specification.new do |spec|
  spec.name          = "view_composer"
  spec.version       = ViewComposer::VERSION
  spec.authors       = ["Kory Tegman"]
  spec.email         = ["korytegman@gmail.com"]

  spec.summary       = %q{ViewComposer helps you compose objects and serialize
                          them. like a mix between AMS and Draper}
  spec.description   = %q{ViewComposer is a dynamic way to compose view objects}
  spec.homepage      = "http://github.com/koryteg/view_composer"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
