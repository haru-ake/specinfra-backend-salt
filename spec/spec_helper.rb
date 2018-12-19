require "bundler/setup"
require 'specinfra'
require 'specinfra/helper/set'
require "specinfra/backend/salt"

include Specinfra::Helper::Set

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # reset `salt_*` options before each tests.
  config.before(:each) do
    %w(salt_user
       salt_become_method
       salt_sudo_user
       salt_sudo_password
       salt_sudo_path
       salt_su_user
       salt_su_password
       salt_su_path
     ).each do |option|
      Specinfra.configuration.instance_variable_set("@#{option}", nil)
    end
  end
end
