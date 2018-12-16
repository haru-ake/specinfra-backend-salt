# Specinfra::Backend::Salt

[![Gem Version](https://badge.fury.io/rb/specinfra-backend-salt.svg)](https://badge.fury.io/rb/specinfra-backend-salt)
[![CircleCI](https://circleci.com/gh/haru-ake/specinfra-backend-salt.svg?style=svg)](https://circleci.com/gh/haru-ake/specinfra-backend-salt)

This backend execute command on salt-minion from salt-master using `salt cmd.run` command.

So, this backend work on ***only salt-master*** .

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'specinfra-backend-salt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install specinfra-backend-salt

## Usage

An example for using [Serverspec](https://serverspec.org/).

```ruby:spec_helper.rb
require 'serverspec'
require 'specinfra/backend/salt'

set :backend, :salt

if ENV['ASK_SALT_SUDO_PASSWORD']
  begin
    require 'highline/import'
  rescue LoadError
    fail "highline is not available. Try installing it."
  end
  set :salt_sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
else
  set :salt_sudo_password, ENV['SALT_SUDO_PASSWORD']
end

# :host should be a minion ID.
set :host, ENV['TARGET_HOST']
```

## Optional options

- `:salt_user` Specify the username who executes command on salt-minion. (default: `root`)
- `:salt_sudo_user` Specify the username who executes `salt run.cmd` on salt-master. (default: `root`)
- `:salt_sudo_password` Specify the password of `:salt_sudo_user` user.
- `:salt_sudo_path` Specify the path of the directory where the `sudo` is placed on salt-master.
- `:salt_sudo_disable` If set `true`, do not use `sudo` when running `salt run.cmd` on salt-master.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/haru-ake/specinfra-backend-salt. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Specinfra::Backend::Salt project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/haru-ake/specinfra-backend-salt/blob/master/CODE_OF_CONDUCT.md).
