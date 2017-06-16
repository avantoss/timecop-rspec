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

class Timecop
  module Rspec
    class TravelLog
      def initialize(travel_method = nil, start_time = nil)
        new_trip(travel_method, start_time)
      end

      def resume_or_new_trip(travel_method, start_time)
        if resume_trip?(travel_method, start_time)
          resume_trip
        else
          new_trip(travel_method, start_time)
        end
      end

      def pause_trip
        self.trip_duration = Time.current - coalesced_start_time
      end

      private

      attr_accessor :travel_method, :start_time, :trip_duration

      def new_trip(travel_method, start_time)
        reset_duration
        self.travel_method = travel_method
        self.start_time    = start_time
      end

      def resume_trip?(other_travel_method, other_start_time)
        travel_method == other_travel_method &&
          start_time == other_start_time &&
          start_time.class == other_start_time.class
      end

      def resume_trip
        coalesced_start_time + trip_duration.seconds
      end

      def coalesced_start_time
        case start_time
        when DateTime
          start_time
        when Date
          start_time.at_beginning_of_day
        when String
          Time.parse(start_time)
        else
          start_time
        end
      end

      def reset_duration
        self.trip_duration = 0
      end
    end
  end
end
