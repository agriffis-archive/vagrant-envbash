# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-envbash/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-envbash"
  spec.version       = VagrantPlugins::EnvBash::VERSION
  spec.authors       = ["Aron Griffis"]
  spec.email         = ["aron@arongriffis.com"]
  spec.summary       = %q{Vagrant plugin to load environment variables from env.bash}
  spec.description   = %q{Vagrant plugin to load environment variables from env.bash}
  spec.homepage      = "https://github.com/agriffis/vagrant-envbash"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  # It seems like this shouldn't be required, but I need this in order for
  # "bundle exec vagrant" to run, even when cloning the upstream vagrant-aws
  # plugin. https://botbot.me/freenode/vagrant/2016-05-15/?msg=66099642&page=3
  spec.add_development_dependency "json"
end
