# Timecop::Rspec

[Timecop::Rspec](https://github.com/avantcredit/timecop-rspec) provides [Timecop](https://github.com/travisjeffery/timecop) time-machines for [RSpec](https://github.com/rspec/rspec) that allow you to time-travel test examples, context/describes, and/or your entire test suite.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'timecop-rspec'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install timecop-rspec

## Configuration

#### Regular Time Machine

```ruby
# spec_helper.rb or some configuration file loaded by spec_helper.rb

require 'timecop/rspec'

RSpec.configure do |config|
  config.around(:example) do |example|
    Timecop::Rspec.time_machine.run(example)
  end
end
```

The regular time machine will run each example at the time specified by the
RSpec metadata, or the global travel time.

#### Sequential Time Machine

```ruby
# spec_helper.rb or some configuration file loaded by spec_helper.rb

require 'timecop/rspec'

RSpec.configure do |config|
  config.around(:example) do |example|
    Timecop::Rspec.time_machine(sequential: true).run(example)
  end
end
```

The sequential time machine is almost the same as the regular time machine,
except that it will sometimes resume time travel.

Global travel will always resume from when the previous global traveled
example ended. E.g.
```ruby
# GLOBAL_TIME_TRAVEL_TIME=2014-11-15 bundle exec rspec some_spec.rb

it 'example 1' do
  Time.now # => 2014-11-15 00:00:00
  sleep 6
end

it 'example 2' do
  Time.now # => 2014-11-15 00:00:06 (resumed from end of previous example)
end
```

Following local travel will resume when specified time is the same as the
previous examples specified time. If the time is different, it will
start from the current examples specified time.
```ruby
describe SomeUnit, travel: Time.new(2014, 11, 15) do
  it 'example 1' do
    Time.now # => 2014-11-15 00:00:00
    sleep 6
  end

  it 'example 2' do
    Time.now # => 2014-11-15 00:00:06 (resumed from end of previous example)
  end

  it 'example 3', travel: Time.new(1982, 6, 16) do
    Time.now # => 1982-06-16 00:00:00
  end
end
```


## Usage

#### Local Time Travel

Timecop.travel/freeze any RSpec (describe|context|example) with
`:travel` or `:freeze` metadata.

```ruby
# Timecop.travel
it 'some description', travel: Time.new(2014, 11, 15) do
  Time.now # 2014-11-15 00:00:00
  sleep 6
  Time.now # 2014-11-15 00:00:06 (6 seconds later)
end

# Timecop.freeze
it 'some description', freeze: Time.new(2014, 11, 15) do
  Time.now # 2014-11-15 00:00:00
  sleep 6
  Time.now # 2014-11-15 00:00:00 (Ruby's time hasn't advanced)
end
```

#### Global Time Travel

Using global time travel will Timecop.travel any example that isn't
already time traveling. I.e. example level timecop metadata will take
precedence.

```sh
GLOBAL_TIME_TRAVEL_TIME=2014-11-15 bundle exec rspec spec/some_directory/
```

The global time travel can also be skipped. You may want to skip
time travel when testing with some external service, such as redis,
where you can't modify time the same way as within ruby.

```ruby
it 'some example that can't time travel', :skip_global_travel do
  # Time.now will be real time
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/avantcredit/timecop-rspec.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

