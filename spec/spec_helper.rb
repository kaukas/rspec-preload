# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

rspec_version = Gem::Version.create(RSpec::Core::Version::STRING)
begin
  if rspec_version >= Gem::Version.new('3.1')
    require 'factory_bot'
  else
    require 'factory_girl'
  end
rescue LoadError
  nil
end

# For verification purposes.
puts 'spec_helper loaded'
