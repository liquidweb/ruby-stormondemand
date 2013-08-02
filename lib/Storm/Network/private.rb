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
require "Storm/server"
require "Storm/Network/zone"

module Storm
  module Network
    # Helper class for zone in private network
    class PrivateZone < Storm::Base::Model
      attr_accessor :attached
      attr_accessor :id
      attr_accessor :name
      attr_accessor :region
      attr_accessor :unattached

      def from_hash(h)
        if h[:attached]
          @attached = h[:attached].map do |s|
            server = Storm::Server.new
            server.from_hash s
            server
          end
        end
        @id = h[:id]
        @name = h[:name]
        if h[:region]
          @region = Storm::Network::ZoneRegion.new
          @region.from_hash h[:region]
        end
        if h[:unattached]
          @unattached = h[:unattached].map do |s|
            server = Storm::Server.new
            server.from_hash s
            server
          end
        end
      end
    end

    # This class defines APIs methods for attaching and detaching
    # a server to a private network, and for querying information about an
    # existing private network.
    class Private
      # Attach a given server to your private network
      #
      # @param server [Server] the specified server
      # @return [String] a result message
      def self.attach(server)
        data = Storm::Base::SODServer.remote_call '/Network/Private/attach',
                                                  :uniq_id => server.uniq_id
        data[:attached]
      end

      # Detach a given server from your private network
      #
      # @param server [Server] the specified server
      # @return [String] a result message
      def self.detach(server)
        data = Storm::Base::SODServer.remote_call '/Network/Private/detach',
                                                  :uniq_id => server.uniq_id
        data[:detached]
      end

      # Get all servers attached to your private network, which zones they are
      # in and what IPs they are assigned
      #
      # @return [Array] an array of PrivateZone objects
      def self.get
        data = Storm::Base::SODServer.remote_call '/Network/Private/get'
        data[:zones].map do |z|
          pz = PrivateZone.new
          pz.from_hash z
          pz
        end
      end

      # Get the current private IP for a particular server, if it has one
      #
      # @param server [Server] the specified server
      # @return [String] the IP address
      def self.get_ip(server)
        data = Storm::Base::SODServer.remote_call '/Network/Private/getIP',
                                                  :uniq_id => server.uniq_id
        data[:ip]
      end

      # Determine whether a given server is currently attached to your private
      # network.
      #
      # @param server [Server] the specific server
      # @return [Bool] whether the server is attached
      def self.is_attached(server)
        data = Storm::Base::SODServer.remote_call '/Network/Private/isAttached',
                                                  :uniq_id => server.uniq_id
        data[:is_attached].to_i == 0 ? false : true
      end
    end
  end
end
