# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exception_notification/ikachan/version'

Gem::Specification.new do |spec|
  spec.name          = "exception_notification-ikachan"
  spec.version       = ExceptionNotification::Ikachan::VERSION
  spec.authors       = ["Uchio KONDO"]
  spec.email         = ["udzura@paperboy.co.jp"]
  spec.description   = %q{ExceptionNotification ikachan plugin}
  spec.summary       = %q{ExceptionNotification ikachan plugin}
  spec.homepage      = "https://github.com/udzura/exception_notification-ikachan"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "exception_notification", ">= 3.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
end
