# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mail_to_hip_chat/version"

Gem::Specification.new do |s|
  s.name        = "mail_to_hip_chat"
  s.version     = MailToHipChat::VERSION
  s.authors     = ["Gabriel Gironda"]
  s.email       = ["gabriel@gironda.org"]
  s.homepage    = ""
  s.summary     = %q{Funnels email into HipChat}
  s.description = %q{Funnels email into HipChat using CloudMailIn}

  s.rubyforge_project = "mail_to_hip_chat"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "http_parser.rb", "~> 0.5"
  s.add_development_dependency "mocha",          "~> 0.10"
  s.add_development_dependency "yard",           "~> 0.7"
  s.add_development_dependency "rdiscount",      "~> 1.6"
  s.add_development_dependency "webmock",        "~> 1.7"
  s.add_development_dependency "rake"
  
  s.add_runtime_dependency "rack",        "~> 1.3"
  s.add_runtime_dependency "hipchat-api", "~> 1.0"
  s.add_runtime_dependency "mustache",    "~> 0.99"
end
