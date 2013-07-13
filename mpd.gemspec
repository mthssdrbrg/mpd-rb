# encoding: utf-8

$: << File.expand_path('../lib', __FILE__)

require 'mpd/version'

Gem::Specification.new do |s|
  s.name          = 'mpd-rb'
  s.version       = MPD::VERSION
  s.authors       = ["Mathias Söderberg"]
  s.email         = ['mths@sdrbrg.se']
  s.homepage      = 'https://github.com/mthssdrbrg/mpd-rb'
  s.description   = 'Ruby bindings for MPD'
  s.summary       = 'Ruby bindings for MPD'
  s.license       = 'Apache'

  s.files         = Dir['lib/**/*.rb']
  s.test_files    = Dir['spec/**/*.rb']
  s.require_paths = ['lib']

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.2'
end
