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
    # This class defines service monitoring status and APIs for remotely
    # querying service status data for a server, as well as managing monitoring
    # settings.
    class Service < Storm::Base::Model
      attr_accessor :can_monitor
      attr_accessor :enabled
      attr_accessor :services
      attr_accessor :unmonitored
      attr_accessor :uniq_id

      def from_hash(h)
        @can_monitor = h[:can_monitor]
        @enabled = h[:enabled].to_i == 1 ? true : false
        @services = h[:services]
        @unmonitored = h[:unmonitored].to_i == 1 ? true : false
        @uniq_id = h[:uniq_id]
      end

      # Get the current monitoring settings for a server
      #
      # @param server [Server] the specified server
      # @return [Service] a Service object
      def self.get(server)
        data = Storm::Base::SODServer.remote_call '/Monitoring/Services/get',
                                                  :uniq_id => server.uniq_id
        serv = Service.new
        serv.from_hash data
        serv
      end

      # Get a list of IPs that our monitoring system runs from
      #
      # @return [Array] an array of IPs
      def self.monitoring_IPs
        Storm::Base::SODServer.remote_call '/Monitoring/Services/monitoringIps'
      end

      # Get the current service status for each monitored service on a server
      #
      # @param server [Server] the specified server
      # @return [Hash] a hash of service status
      def self.status(server)
        Storm::Base::SODServer.remote_call '/Monitoring/Services/status',
                                           :uniq_id => server.uniq_id
      end

      # Update service monitoring settings for a server
      #
      # @param server [Server] the specified server
      # @param options [Hash] optional keys:
      #   :enabled [Bool] if it's enabled,
      #   :services [Array] an array of strings
      # @return [Service] a new Service object
      def self.update(server, options={})
        param = { :uniq_id => server.uniq_id }.merge options
        param[:enabled] = param[:enabled] ? 1 : 0
        data = Storm::Base::SODServer.remote_call \
                     '/Monitoring/Services/update', param
        serv = Service.new
        serv.from_hash data
        serv
      end
    end
  end
end
