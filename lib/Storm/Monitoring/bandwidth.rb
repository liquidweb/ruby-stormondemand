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

require 'Storm/Base/model'
require 'Storm/Base/sodserver'

module Storm
  module Monitoring
    # This Class defines basic speed in KB, MB and GB
    class BasicSpeed < Storm::Base::Model
      attr_accessor :byte
      attr_accessor :kilobyte
      attr_accessor :megabyte
      attr_accessor :gigabyte

      def from_hash(h)
        @byte = h[:B]
        @kilobyte = h[:KB]
        @megabyte = h[:MB]
        @gigabyte = h[:GB]
      end
    end

    # This class defines duplex speed in both direction
    class DuplexSpeed < Storm::Base::Model
      attr_accessor :both
      attr_accessor :in
      attr_accessor :out

      def from_hash(h)
        @both = BasicSpeed.new
        @both.from_hash h[:both]
        @in = BasicSpeed.new
        @in.from_hash h[:in]
        @out = BasicSpeed.new
        @out.from_hash h[:out]
      end
    end

    # This class defines average speeds within different time slice
    class AverageSpeed < Storm::Base::Model
      attr_accessor :day
      attr_accessor :hour
      attr_accessor :minute
      attr_accessor :month
      attr_accessor :second
      attr_accessor :week
      attr_accessor :year

      def from_hash(h)
        @day = DuplexSpeed.new
        @day.from_hash h[:day]
        @hour = DuplexSpeed.new
        @hour.from_hash h[:hour]
        @minute = DuplexSpeed.new
        @minute.from_hash h[:minute]
        @month = DuplexSpeed.new
        @month.from_hash h[:month]
        @second = DuplexSpeed.new
        @second.from_hash h[:second]
        @week = DuplexSpeed.new
        @week.from_hash h[:week]
        @year = DuplexSpeed.new
        @year.from_hash h[:year]
      end
    end

    class BandwidthCost < Storm::Base::Model
      attr_accessor :current
      attr_accessor :projected

      def from_hash(h)
        @current = h[:current]
        @projected = h[:projected]
      end
    end

    class BandwidthPricing < Storm::Base::Model
      attr_accessor :per_gb_over
      attr_accessor :price
      attr_accessor :quota

      def from_hash(h)
        @per_gb_over = h[:per_gb_over]
        @price = h[:price]
        @quota = h[:quota]
      end
    end

    # This class defines bandwidth usage properties and API methods for
    # statistics
    class Bandwidth < Storm::Base::Model
      attr_accessor :actual
      attr_accessor :averages
      attr_accessor :cost
      attr_accessor :domain
      attr_accessor :pricing
      attr_accessor :projected

      def from_hash(h)
        @actual = DuplexSpeed.new
        @actual.from_hash h[:actual]
        @averages = AverageSpeed.new
        @averages.from_hash h[:averages]
        @cost = BandwidthCost.new
        @cost.from_hash h[:cost]
        @domain = h[:domain]
        @pricing = BandwidthPricing.new
        @pricing.from_hash h[:pricing]
        @projected = DuplexSpeed.new
        @projected.from_hash h[:projected]
      end

      # Get a bandwidth usage graph for a server
      #
      # @param server [Server] a specific server
      # @param options [Hash] optional keys:
      #   :frequency [String] one of 'daily', 'weekly', 'monthly', 'yearly',
      #   :height [Int] image height,
      #   :width [Int] image width,
      #   :small [Bool] whether need small image
      # @return [Hash] a hash with keys: :content and :content_type
      def self.graph(server, options={})
        param = { :uniq_id => server.uniq_id }.merge options
        param[:small] = param[:small] ? 1 : 0
        Storm::Base::SODServer.remote_call '/Monitoring/Bandwidth/graph', param
      end

      # Get bandwidth usage stats for a server
      #
      # @param server [Server] specify the server
      # @return [Bandwidth] a new Bandwidth object
      def self.stats(server)
        data = Storm::Base::SODServer.remote_call \
                    '/Monitoring/Bandwidth/stats', :uniq_id => server.uniq_id
        bw = Bandwidth.new
        bw.from_hash data
        bw
      end
    end
  end
end
