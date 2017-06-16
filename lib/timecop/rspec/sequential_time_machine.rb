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

require_relative 'example_decorator'
require_relative 'traveler'
require_relative 'travel_log'

class Timecop
  module Rspec
    class SequentialTimeMachine
      def self.instance
        @instance ||= new
      end

      def run(example)
        example = ExampleDecorator.new(example)

        runner_for(example).run
      end

      private

      def runner_for(example)
        if example.local_timecop?
          Traveler.new(example, local_travel_log)
        elsif example.global_timecop?
          Traveler.new(example, global_travel_log)
        else
          example
        end
      end

      def local_travel_log
        @local_travel_log ||= TravelLog.new
      end

      def global_travel_log
        @global_travel_log ||= TravelLog.new(:travel, Rspec.global_time)
      end
    end
  end
end
