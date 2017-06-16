# The MIT License (MIT)

# Copyright (c) 2014-2017 Avant

# Author Zach Taylor

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
require 'timecop/rspec'

require_relative 'a_time_machine'

RSpec.describe Timecop::Rspec::SequentialTimeMachine do
  it_behaves_like 'a time machine'

  subject(:time_machine) { described_class.new }

  let(:example_procsy) do
    instance_double(
      RSpec::Core::Example::Procsy,
      example:  some_example,
      metadata: {}
    )
  end

  let(:some_example) { instance_double(RSpec::Core::Example) }

  it 'advances example and context level time travel time when executing successive examples with the same travel start value' do
    travel_date = Date.new(2016, 12, 15)
    example_procsy.metadata[:travel] = travel_date

    time_1, time_2, time_3 = nil, nil, nil
    expect(example_procsy).to receive(:run) do
      time_1 = Time.now
    end
    time_machine.run(example_procsy)

    expect(example_procsy).to receive(:run) do
      time_2 = Time.now
    end
    time_machine.run(example_procsy)

    expect(example_procsy).to receive(:run) do
      time_3 = Time.now
    end
    time_machine.run(example_procsy)

    expect([time_1, time_2, time_3].map(&:to_date)).to all eq(Date.new(2016, 12, 15))
    expect(time_1).to be < time_2
    expect(time_2).to be < time_3
  end

  context 'global time travel enabled' do
    let(:global_travel_time) { '2015-02-09' }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GLOBAL_TIME_TRAVEL_TIME').and_return(global_travel_time)
    end

    it 'advances global time travel time when executing successive examples' do
      time_1, time_2, time_3 = nil, nil, nil
      expect(example_procsy).to receive(:run) do
        time_1 = Time.now
      end
      time_machine.run(example_procsy)

      expect(example_procsy).to receive(:run) do
        time_2 = Time.now
      end
      time_machine.run(example_procsy)

      expect(example_procsy).to receive(:run) do
        time_3 = Time.now
      end
      time_machine.run(example_procsy)

      expect([time_1, time_2, time_3].map(&:to_date)).to all eq(Date.new(2015, 2, 9))
      expect(time_1).to be < time_2
      expect(time_2).to be < time_3
    end
  end
end
