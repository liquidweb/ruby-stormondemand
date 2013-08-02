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

require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  module Monitoring
    # This class defines basic system load
    class BasicLoad < Storm::Base::Model
      attr_accessor :percent
      attr_accessor :total
      attr_accessor :used

      def from_hash(h)
        @percent = h[:percent]
        @total = h[:total]
        @used = h[:used]
      end
    end

    # This class defines average system load in different time slice
    class AverageLoad < Storm::Base::Model
      attr_accessor :fifteen
      attr_accessor :five
      attr_accessor :one

      def from_hash(h)
        @fifteen = h[:fifteen]
        @five = h[:five]
        @one = h[:one]
      end
    end

    # This class defines system memory load
    class MemoryLoad < Storm::Base::Model
      attr_accessor :physical
      attr_accessor :virtual

      def from_hash(h)
        @physical = BasicLoad.new
        @physical.from_hash h[:physical]
        @virtual = BasicLoad.new
        @virtual.from_hash h[:virtual]
      end
    end

    # This class defines system process load
    class ProcessLoad < Storm::Base::Model
      attr_accessor :running
      attr_accessor :total

      def from_hash(h)
        @running = h[:running]
        @total = h[:total]
      end
    end

    # This class defines system load properties and APIs to get
    # statistics
    class Load < Storm::Base::Model
      attr_accessor :disk
      attr_accessor :domain
      attr_accessor :loadavg
      attr_accessor :memory
      attr_accessor :proc
      attr_accessor :uptime

      def from_hash(h)
        @disk = BasicLoad.new
        @disk.from_hash h[:disk]
        @domain = h[:domain]
        @loadavg = AverageLoad.new
        @loadavg.from_hash h[:loadavg]
        @memory = MemoryLoad.new
        @memory.from_hash h[:memory]
        @proc = ProcessLoad.new
        @proc.from_hash h[:proc]
        @uptime = h[:uptime]
      end

      # Get a load graph for a server as a base64 encoded blob
      #
      # @param server [Server] the specified server
      # @param stat [String] options:
      #                   'load1'      - 1 minute load average,
      #                   'load5'      - 5 minute load average,
      #                   'load15'     - 15 minute load average,
      #                   'rproc'      - running process count,
      #                   'tproc'      - total process count,
      #                   'pmem'       - physical memory usage,
      #                   'smem'       - swap (virtual) memory usage,
      #                   'diskroot'   - /root volume usage,
      #                   'diskbackup' - /backup volume usage,
      #                   'diskhome'   - /home volume usage,
      #                   'disktmp'    - /tmp volume usage,
      #                   'diskusr'    - /usr volume usage,
      #                   'diskvar'    - /var volume usage
      # @param options [Hash] optional keys:
      #   :duration [String] options:
      #              '6hour', '12hour', 'day', '3day', 'week', '2week',
      #   :compact [Bool] if need compact image,
      #   :height [Int] image height,
      #   :width [Int] image width
      # @return [Hash] a hash with keys: :content and :content_type
      def self.graph(server, stat, options={})
        param = {
          :uniq_id => server.uniq_id,
          :stat => stat,
          :duration => 'day'
        }.merge options
        param[:compact] = param[:compact] ? 1 : 0
        Storm::Base::SODServer.remote_call '/Monitoring/Load/graph', param
      end

      # Get load stats for a server, memory is returned in unit of MB, whereas
      # disk usage is in terms of GB.
      #
      # @param server [Server] the specified server
      # @return [Load] a Load object
      def self.stats(server)
        data = Storm::Base::SODServer.remote_call '/Monitoring/Load/stats',
                                                  :uniq_id => server.uniq_id
        load = Load.new
        load.from_hash data
        load
      end
    end
  end
end
