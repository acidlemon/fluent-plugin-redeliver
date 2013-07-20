# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-redeliver"
  gem.version       = "0.1.0"
  gem.authors       = ["Masatoshi Kawazoe (acidlemon)"]
  gem.email         = ["acidlemon@beatsync.net"]
  gem.description   = %q{simple tag-based redeliver plugin}
  gem.summary       = %q{simple tag-based redeliver plugin}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "fluentd"
  gem.add_runtime_dependency "fluentd"
end
