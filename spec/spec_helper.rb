require 'webmock/rspec'
require 'vcr'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = [:should, :expect]
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  
  config.mock_with :rspec do |mocks|
    mocks.syntax = [:should, :expect]
    mocks.verify_partial_doubles = true
  end

  config.tty = true
  config.color = true
  config.formatter = :documentation

  config.around(:each) do |example|
    $redis.flushall
    example.run
  end
end
