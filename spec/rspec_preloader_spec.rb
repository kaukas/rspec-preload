# frozen_string_literal: true

require 'spec_helper'
require 'open3'

describe 'RspecPreloader' do
  include Open3

  def preload(appraisal, &block)
    popen2e('bundle', 'exec',
            'appraisal', appraisal,
            'ruby', './bin/rspec_preload.rb',
            &block)
  end

  0.upto(11).map { |v| "rspec-3.#{v}" }.each do |appraisal|
    context appraisal do
      it 'runs specs' do
        preload(appraisal) do |stdin, stdout, wait_thr|
          stdin.puts('rspec --format documentation --example works spec/test_spec.rb')
          stdin.close

          expect(wait_thr.value).to be_success
          out = stdout.read
          expect(out).to match(/TestSpec.*works/m)
          expect(out).not_to include('Fail')
        end
      end

      it 'clears the screen' do
        preload(appraisal) do |stdin, stdout, wait_thr|
          stdin.puts(%(echo -en "\\ec\\e[3J"))
          stdin.close

          expect(wait_thr.value).to be_success
          out = stdout.read
          expect(out).to include("\ec\e[3J")
          expect(out).not_to include('Fail')
        end
      end

      it 'preloads the spec_helper.rb file' do
        preload(appraisal) do |stdin, stdout, wait_thr|
          stdin.close
          out = stdout.read
          expect(out).to include('spec_helper loaded')
          expect(wait_thr.value).to be_success
        end
      end

      it 'preloads the rails_helper.rb file' do
        preload(appraisal) do |stdin, stdout, wait_thr|
          stdin.close
          out = stdout.read
          expect(out).to include('rails_helper loaded')
          expect(wait_thr.value).to be_success
        end
      end

      it 'runs before-suite hooks during preload' do
        preload(appraisal) do |stdin, stdout, wait_thr|
          stdin.close
          out = stdout.read
          expect(out).to include('before suite')
          expect(wait_thr.value).to be_success
        end
      end

      it 'does not run before-suite hooks after preload' do
        preload(appraisal) do |stdin, stdout, wait_thr|
          # One of these specs touches factories.
          stdin.puts('rspec spec/test_spec.rb')
          stdin.close
          out = stdout.read
          expect(out).to include('before suite')
          expect(out.split('(rspec_preload)', 2).last)
            .not_to include('before suite')
          expect(wait_thr.value).to be_success
        end
      end

      it 'reloads FactoryBot factories if they change before running specs' do
        preload(appraisal) do |stdin, stdout, wait_thr|
          # One of these specs touches factories.
          stdin.puts('rspec spec/test_spec.rb')
          # Another run to trigger factory reload.
          stdin.puts('rspec spec/test_spec.rb')
          stdin.close
          out = stdout.read
          expect(out).to include('factories loaded')
          expect(wait_thr.value).to be_success
        end
      end
    end
  end
end
