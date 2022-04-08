# frozen_string_literal: true

require 'fileutils'

describe 'TestSpec' do
  it('works') { expect(1).to eq(1) }

  it('updates factories') do
    FileUtils.touch(File.join(__dir__, 'factories', 'test.rb'), nocreate: true)
  end
end
