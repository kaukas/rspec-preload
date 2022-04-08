# frozen_string_literal: true

appraise 'rspec-3.0' do
  gem 'rspec', '3.0.0'
  gem 'factory_girl', '4.9.0'
end

1.upto(11).each do |minor|
  appraise "rspec-3.#{minor}" do
    gem 'rspec', "3.#{minor}.0"
    gem 'factory_bot', '6.2.1'
  end
end

# vi: filetype=ruby
