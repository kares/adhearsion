source 'https://rubygems.org'

gemspec

gem 'jruby-openssl', '~> 0.9.10', platform: :jruby

gem 'aruba', '< 0.7', require: false, group: :development

if RUBY_VERSION < '2.0'
  if ENV['AS_VERSION']
    gem 'activesupport', ENV['AS_VERSION']
  else
    # NOTE: keep testing against AS 3.2.x by default
    # :require needed as otherwise some specs fail :
    # undefined method `deep_merge' for {:from=>"foo", :timeout=>3000, :headers=>{:x_foo=>"bar"}}:Hash
    gem 'activesupport', '~> 3.2', require: ['active_support', 'active_support/core_ext/hash']
  end
  gem 'mime-types', '< 2.99'
end

if pb_version = ENV['PB_VERSION']
  git_repo = ENV['PB_REPO'] || 'https://github.com/cloudvox/punchblock.git'
  if pb_version.index('/') && ::File.exist?(pb_version)
    gem 'punchblock', path: pb_version
  elsif pb_version =~ /^((=|>|>=|<|<=|~>)\s*)?\d(\.\w+)+$/
    gem 'punchblock', pb_version
  elsif pb_version =~ /^[0-9abcdef]+$/
    gem 'punchblock', git: git_repo, ref: pb_version
  else
    gem 'punchblock', git: git_repo, branch: pb_version
  end
else
  gem 'punchblock', '~> 2.7'
end

# help Bundler as its having a hard-time resolving a working state :
gem 'celluloid-io', '~> 0.15.0'

group :development do
  gem 'ci_reporter', '~> 2.0.0', require: false
  gem 'ci_reporter_rspec', '~> 1.0.0', require: false
  gem 'ci_reporter_cucumber', '~> 1.0.0', require: false
end
