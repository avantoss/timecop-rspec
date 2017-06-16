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

require 'timecop/rspec/version'
require 'active_support/all'

Dir.glob(File.join(__dir__, 'rspec', '**', '*.rb')).each { |file| require file }

class Timecop
  module Rspec
    class << self
      def time_machine(sequential: false)
        if sequential
          SequentialTimeMachine.instance
        else
          TimeMachine.instance
        end
      end

      def global_time_configured?
        global_time_travel_string.present?
      end

      def global_time
        @global_time ||= Time.parse(global_time_travel_string)
      end

      private

      def global_time_travel_string
        ENV['GLOBAL_TIME_TRAVEL_TIME'] || ENV['GLOBAL_TIME_TRAVEL_DATE']
      end
    end
  end
end
