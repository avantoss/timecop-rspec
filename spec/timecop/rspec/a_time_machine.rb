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
RSpec.shared_examples 'a time machine' do
  subject(:time_machine) { described_class.new }

  let(:example_procsy) do
    instance_double(
      RSpec::Core::Example::Procsy,
      example:  some_example,
      metadata: {}
    )
  end

  let(:some_example) { instance_double(RSpec::Core::Example) }

  let(:us_tz) { ActiveSupport::TimeZone['Central Time (US & Canada)'] }
  let(:gb_tz) { ActiveSupport::TimeZone['London'] }

  describe '#run' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GLOBAL_TIME_TRAVEL_TIME').and_return(global_travel_time)
      allow(Time).to receive_messages(zone: us_tz, zone_default: us_tz)
    end

    context 'global time travel disabled' do
      let(:global_travel_time) { nil }

      it 'runs the example in real time when no time travel specified' do
        original_time = Time.now

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to be_within(1).of(original_time)
        end

        time_machine.run(example_procsy)
      end

      it 'runs the example in travelled time with a date/time' do
        travel_date = Date.new(2016, 12, 15)
        example_procsy.metadata[:travel] = travel_date

        expect(example_procsy).to receive(:run) do
          expect(Date.current).to eq travel_date
        end

        time_machine.run(example_procsy)
      end

      it 'runs the example in frozen time with a date/time' do
        travel_time = Time.new(2016, 12, 15, 3, 2, 1)
        example_procsy.metadata[:freeze] = travel_time

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to eq travel_time
        end

        time_machine.run(example_procsy)
      end

      it 'advances example and context level time travel time when executing successive examples with the same travel start value' do
        travel_date = Date.new(2016, 12, 15)
        example_procsy.metadata[:travel] = travel_date

        allow(Time).to receive_messages(zone: us_tz, zone_default: us_tz)
        expect(example_procsy).to receive(:run) do
          expect(Time.current).to be_within(2.seconds).of(Time.new(2016,12,15,0,0,0,'-06:00'))
        end
        time_machine.run(example_procsy)

        allow(Time).to receive_messages(zone: gb_tz, zone_default: gb_tz)
        expect(example_procsy).to receive(:run) do
          expect(Time.current).to be_within(2.seconds).of(Time.new(2016,12,15,0,0,0,'+00:00'))
        end
        time_machine.run(example_procsy)

        allow(Time).to receive_messages(zone: us_tz, zone_default: us_tz)
        expect(example_procsy).to receive(:run) do
          expect(Time.current).to be_within(2.seconds).of(Time.new(2016,12,15,0,0,0,'-06:00'))
        end
        time_machine.run(example_procsy)
      end

      it 'accepts string date/time values' do
        travel_date = '2015-7-14 12:00:00'
        example_procsy.metadata[:travel] = travel_date

        expect(example_procsy).to receive(:run) do
          expect(Time.current).to be_within(1.second).of(Time.new(2015,7,14,12,0,0,'-05:00'))
        end
        time_machine.run(example_procsy)
      end

      it 'works correctly with DateTime objects' do
        travel_date = DateTime.new(2016, 7, 15, 16, 28)
        example_procsy.metadata[:travel] = travel_date

        expect(example_procsy).to receive(:run) do
          # The assertion is time shifted in CST, because DateTime.new uses UTC zone if none is specified
          # and will be coerced into local time zone when timecop mutates time.  The lesson here is to be sure
          # your specified DateTime zone matches your test's effective timezone when using timecop.
          expect(Time.current).to be_within(1.second).of(Time.new(2016, 7, 15, 11, 28, 0,'-05:00'))
        end
        time_machine.run(example_procsy)
      end

      it 'does not continue time when Date follows similar DateTime' do
        travel_date   = DateTime.new(2016, 7, 15)
        travel_date_2 = Date.new(2016, 7, 15)

        # Ruby considers a DateTime at start of day to be equal to a Date on the same day
        expect(travel_date).to eql travel_date_2

        example_procsy.metadata[:travel] = travel_date
        expect(example_procsy).to receive(:run) do
          # The assertion is time shifted in CST, because DateTime.new uses UTC zone if none is specified
          # and will be coerced into local time zone when timecop mutates time.  The lesson here is to be sure
          # your specified DateTime zone matches your test's effective timezone when using timecop.
          expect(Time.current).to be_within(1.second).of(Time.new(2016, 7, 14, 19, 0, 0,'-05:00'))
        end
        time_machine.run(example_procsy)

        example_procsy.metadata[:travel] = travel_date_2
        expect(example_procsy).to receive(:run) do
          expect(Time.current).to be_within(1.second).of(Time.new(2016, 7, 15, 0, 0, 0,'-05:00'))
        end
        time_machine.run(example_procsy)
      end

      it 'does not advance example or context level time travel time when executing successive examples with the same freeze start value' do
        travel_date = Time.new(2016, 12, 15, 0, 0, 0).getlocal
        example_procsy.metadata[:freeze] = travel_date

        expect(example_procsy).to receive(:run) do
          expect(Time.current).to eq travel_date
        end
        time_machine.run(example_procsy)

        expect(example_procsy).to receive(:run) do
          expect(Time.current).to eq travel_date
        end
        time_machine.run(example_procsy)

        expect(example_procsy).to receive(:run) do
          expect(Time.current).to eq travel_date
        end
        time_machine.run(example_procsy)
      end

      context 'specifying a proc for time travel' do
        it 'runs the example in travelled time with a proc evaluated against the example' do
          some_example.instance_variable_set(:@my_date, Date.new(2016, 6, 1))
          travel_date = -> { @my_date }
          example_procsy.metadata[:travel] = travel_date

          expect(example_procsy).to receive(:run) do
            expect(Date.current).to eq Date.new(2016, 6, 1)
          end

          time_machine.run(example_procsy)
        end

        it 'runs the example in frozen time with a proc evaluated against the example' do
          some_example.instance_variable_set(:@my_time, Time.new(2016, 12, 15, 3, 2, 1))
          travel_time = -> { @my_time }
          example_procsy.metadata[:freeze] = travel_time

          expect(example_procsy).to receive(:run) do
            expect(Time.now).to eq Time.new(2016, 12, 15, 3, 2, 1)
          end

          time_machine.run(example_procsy)
        end
      end
    end

    context 'global time travel enabled' do
      let(:global_travel_time) { '2015-02-09' }

      it 'runs the example in global time travel time' do
        expect(example_procsy).to receive(:run) do
          expect(Date.current).to eq Date.new(2015, 2, 9)
        end

        time_machine.run(example_procsy)
      end

      it 'runs the example in real time when :skip_global_timecop specified' do
        original_time = Time.now
        example_procsy.metadata[:skip_global_timecop] = true

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to be_within(1).of(original_time)
        end

        time_machine.run(example_procsy)
      end

      it 'runs the example in travelled example time when :travel specified' do
        travel_date = Date.new(2016, 12, 15)
        example_procsy.metadata[:travel] = travel_date

        expect(example_procsy).to receive(:run) do
          expect(Date.current).to eq travel_date
        end

        time_machine.run(example_procsy)
      end

      it 'runs the example in frozen example time when :freeze specified' do
        travel_time = Time.new(2016, 12, 15, 3, 2, 1)
        example_procsy.metadata[:freeze] = travel_time

        expect(example_procsy).to receive(:run) do
          expect(Time.now).to eq travel_time
        end

        time_machine.run(example_procsy)
      end
    end
  end
end
