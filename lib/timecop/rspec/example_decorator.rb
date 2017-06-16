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
    class ExampleDecorator < SimpleDelegator
      def timecop?
        local_timecop? || global_timecop?
      end

      def timecop_method
        local_timecop_method || global_timecop_method
      end

      def timecop_time
        local_timecop_time || global_timecop_time
      end

      def local_timecop?
        local_timecop_method.present?
      end

      def global_timecop?
        Rspec.global_time_configured? && !skip_global_timecop?
      end

      def skip_global_timecop?
        metadata.key?(:skip_global_timecop)
      end

      private

      def local_timecop_method
        metadata.keys.find do |key|
          key == :freeze || key == :travel
        end
      end

      def local_timecop_time
        time = metadata[timecop_method]
        return if time.nil?
        time.respond_to?(:call) ? example.instance_exec(&time) : time
      end

      def global_timecop_method
        :travel if global_timecop?
      end

      def global_timecop_time
        Rspec.global_time if global_timecop?
      end
    end
  end
end
