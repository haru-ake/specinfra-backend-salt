# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "specinfra/salt_backend/version"

Gem::Specification.new do |spec|
  spec.name          = "specinfra-backend-salt"
  spec.version       = Specinfra::SaltBackend::VERSION
  spec.authors       = ["HARU Akebono"]
  spec.email         = ["haru.akebono.11@gmail.com"]

  spec.summary       = %q{Specinfra backend for SaltStack}
  spec.description   = %q{Specinfra backend for SaltStack}
  spec.homepage      = "https://github.com/haru-ake/specinfra-backend-salt"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency 'specinfra', '~> 2.0'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
