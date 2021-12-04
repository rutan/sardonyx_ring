# frozen_string_literal: true

require_relative 'lib/sardonyx_ring/version'

Gem::Specification.new do |spec|
  spec.name = 'sardonyx_ring'
  spec.version = SardonyxRing::VERSION
  spec.authors = ['rutan']
  spec.email = ['ru_shalm@hazimu.com']

  spec.summary = 'Slack bot framework'
  spec.description = 'Slack bot framework'
  spec.homepage = 'https://github.com/rutan/sardonyx_ring'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'eventmachine'
  spec.add_dependency 'faye-websocket'
  spec.add_dependency 'parse-cron'
  spec.add_dependency 'slack-ruby-client'
end
