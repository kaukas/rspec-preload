# frozen_string_literal: true

require 'spec_helper'

# For verification purposes.
RSpec.configure do |config|
  config.before(:suite) { puts 'before suite' }
end

puts 'rails_helper loaded'
