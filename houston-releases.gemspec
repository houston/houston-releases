$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "houston/releases/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name          = "houston-releases"
  spec.version       = Houston::Releases::VERSION
  spec.authors       = ["Bob Lail"]
  spec.email         = ["bob.lailfamily@gmail.com"]

  spec.summary       = "Generates Release Notes automatically from commit messages"
  spec.homepage      = "https://github.com/houston/houston-releases"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
  spec.test_files = Dir["test/**/*"]

  spec.add_dependency "houston-core", ">= 0.8.0.pre"
  spec.add_dependency "record_tag_helper", "~> 1.0" # to keep using div_for

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
end
