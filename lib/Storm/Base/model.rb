#   Copyright 2013 Liquid Web, Inc.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

require 'date'

module Storm
  module Base
    # This is the base class for all Storm objects, this base class provide
    # some basic helper functions
    class Model

      # Build up the object with data in a hash
      #
      # @param h [Hash] the hash data
      def from_hash(h)
      end

      # Get a DateTime object in YYYY-MM-DD HH:MM:SS format from the hash
      #
      # @param h [Hash] the hash data
      # @param name [Symbol] the name of the key
      # @return [DateTime] A DateTime object or nil
      def get_datetime(h, name)
        value = h[name]
        if value
          if self.long_datetime_str? value
            return DateTime.strptime(value, '%Y-%m-%d %H:%M:%S')
          else
            return DateTime.strptime(value, '%Y-%m-%d %H:%M')
          end
        end
        nil
      end

      # Get a Date object in YYYY-MM-DD HH:MM:SS format from the hash
      #
      # @param h [Hash] the hash data
      # @param name [Symbol] the name of the key
      # @return [Date] A Date object or nil
      def get_date(h, name)
        value = h[name]
        if value
          return Date.strptime(value, '%Y-%m-%d')
        end
        nil
      end

      def long_datetime_str?(s)
        idx1 = s.index ':'
        if idx1
          idx2 = s[(idx1+1)..-1].index ':'
          if idx2
            return true
          end
        end
        false
      end
    end
  end
end