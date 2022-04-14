# frozen_string_literal: true

require 'benchmark'
require 'rspec/core'

spec_folder = File.join(Dir.pwd, 'spec')
$LOAD_PATH << spec_folder unless $LOAD_PATH.include?(spec_folder)
%w[spec_helper.rb rails_helper.rb].each do |helper|
  file = File.join(spec_folder, helper)
  require(file) if File.exist?(file)
end

config = RSpec.configuration
rspec_version = Gem::Version.create(RSpec::Core::Version::STRING)
# Run the before(:suite) hooks. Note that no after(:suite) hooks are ever run!
if rspec_version < Gem::Version.new('3.2')
  # From
  # https://github.com/rspec/rspec-core/blob/v3.0.4/lib/rspec/core/runner.rb#L110.
  hook_context = RSpec::Core::SuiteHookContext.new
  config.hooks.run(:before, :suite, hook_context)
  config.hooks[:before][:suite].clear
elsif rspec_version < Gem::Version.new('3.5.1')
  hook_context = RSpec::Core::SuiteHookContext.new
  hooks = config.instance_variable_get('@before_suite_hooks')
  config.send(:run_hooks_with, hooks, hook_context)
  hooks.clear
elsif rspec_version < Gem::Version.new('3.11')
  hooks = config.instance_variable_get('@before_suite_hooks')
  config.send(:run_suite_hooks, 'a `before(:suite)` hook', hooks)
  hooks.clear
else
  # From
  # https://github.com/rspec/rspec-core/blob/v3.11.0/lib/rspec/core/configuration.rb#L2066.
  hooks = config.instance_variable_get('@before_suite_hooks')
  RSpec.current_scope = :before_suite_hook
  config.send(:run_suite_hooks, 'a `before(:suite)` hook', hooks)
  hooks.clear
end

# Factories will be reloaded when modified.
def latest_factories_mod_time
  mtimes = Dir[File.join(Dir.pwd, 'spec/factories/**')]
           .select(&File.method(:file?))
           .map(&File.method(:mtime))
  mtimes << Time.new(2000, 1, 1, 1, 1, 1) # default
  mtimes.max
end

def reload_factories
  print('Reloading factories...')
  time = Benchmark.realtime do
    if defined?(FactoryBot)
      FactoryBot.reload
    elsif defined?(FactoryGirl)
      FactoryGirl.reload
    end
  end
  puts(format(' done in %.5fs', time))
end

last_mtime = latest_factories_mod_time

loop do
  print('(rspec_preload) $ ')
  cmd = gets
  if cmd.nil?
    break
  elsif cmd.include?('rspec')
    new_mtime = latest_factories_mod_time
    reload_factories if new_mtime > last_mtime

    argv = cmd.split.slice_after(/rspec\z/).drop(1).flatten
    time = Benchmark.realtime do
      fork { RSpec::Core::Runner.run(argv) }
      Process.wait
    end

    last_mtime = new_mtime
    puts format('Preloaded RSpec run took %.5fs', time)
  elsif cmd.include?(%(echo -en "\\ec\\e[3J"))
    # Clear screen.
    print("\ec\e[3J")
  else
    puts 'Not an RSpec command, ignoring\n'
  end
end
