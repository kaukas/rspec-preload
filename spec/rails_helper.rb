# frozen_string_literal: true

# For verification purposes.
RSpec.configure do |config|
  config.before(:suite) { puts 'before suite' }
end

puts 'rails_helper loaded'
