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
    # Helper class defines service data in a LoadBalancer object
    class Service < Storm::Base::Model
      attr_accessor :dest_port
      attr_accessor :protocol
      attr_accessor :src_port

      def from_hash(h)
        @dest_port = h[:dest_port]
        @protocol = h[:protocol]
        @src_port = h[:src_port]
      end

      def to_hash
        res = {}
        res[:dest_port] = @dest_port
        res[:protocol] = @protocol
        res[:src_port] = @src_port
        res
      end
    end

    # Helper class defines strategy data in a LoadBalancer object
    class Strategy < Storm::Base::Model
      attr_accessor :description
      attr_accessor :name
      attr_accessor :strategy

      def from_hash(h)
        @description = h[:description]
        @name = h[:name]
        @strategy = h[:strategy]
      end
    end

    # This class defines APIs that provide access for creating, adjusting,
    # and removing load balancers from an account.
    class LoadBalancer < Storm::Base::Model
      attr_accessor :capabilities
      attr_accessor :name
      attr_accessor :nodes
      attr_accessor :region
      attr_accessor :services
      attr_accessor :session_persistence
      attr_accessor :ssl_includes
      attr_accessor :ssl_termination
      attr_accessor :strategy
      attr_accessor :vip
      attr_accessor :uniq_id

      def from_hash(h)
        @capabilities = h[:capabilities]
        @name = h[:name]
        if h[:nodes]
          @nodes = h[:nodes].map do |n|
            node = Storm::Server.new
            node.from_hash n
            node
          end
        end
        @region = Storm::Network::ZoneRegion.new
        @region.id = h[:region_id]
        if h[:services]
          @services = h[:services].map do |s|
            service = Storm::Network::Service.new
            service.from_hash s
            service
          end
        end
        @session_persistence = h[:session_persistence].to_i == 0 ? false : true
        @ssl_includes = h[:ssl_includes].to_i == 0 ? false : true
        @ssl_termination = h[:ssl_termination].to_i == 0 ? false : true
        @strategy = h[:strategy]
        @vip = h[:vip]
        @uniq_id = h[:uniq_id]
      end

      # Add a single node to an existing loadbalancer
      #
      # @param node [String] a node's IP address
      def add_node(node)
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/addNode',
                    :uniq_id => @uniq_id,
                    :node => node
        self.from_hash data
      end

      # Add a service to an existing loadbalancer
      #
      # @param dest_port [Int] a valid destination port
      # @param src_port [Int] a valid source port
      def add_service(dest_port, src_port)
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/addService',
                    :uniq_id => @uniq_id,
                    :dest_port => dest_port,
                    :src_port => src_port
        self.from_hash data
      end

      # Find out if a loadbalancer name is already in use on an account
      #
      # @param name [String]
      # @return [Bool] whether the name is available
      def self.available(name)
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/available', :name => name
        data[:available].to_i == 0 ? false : true
      end

      # Create a new loadbalancer
      #
      # @param name [String] loadbalancer name
      # @param services [Array] an array of service objects
      # @param strategy [String]
      # @param options [Hash] optional keys:
      #  :nodes [Array] an array of node IPs,
      #  :region [Int] region id,
      #  :session_persistence [Bool],
      #  :ssl_cert [String] ssl certificate string,
      #  :ssl_includes [Bool],
      #  :ssl_int [String] ssl public certificate string,
      #  :ssl_key [String] a private key string,
      #  :ssl_termination [Bool]
      # @return [LoadBalancer] a new LoadBalancer object
      def self.create(name, services, strategy, options={})
        param = {
          :name => name,
          :services => services.map { |s| s.to_hash },
          :strategy => strategy
        }.merge options
        param[:session_persistence] = param[:session_persistence] ? 1 : 0
        param[:ssl_includes] = param[:ssl_includes] ? 1 : 0
        param[:ssl_termination] = param[:ssl_termination] ? 1 : 0
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/create', param
        lb = LoadBalancer.new
        lb.from_hash data
        lb
      end

      # Delete the LoadBalancer
      #
      # @return [String] a result message
      def delete
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/delete', :uniq_id => @uniq_id
        data[:deleted]
      end

      # Get details information about the current LoadBalancer
      def details
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/details', :uniq_id => @uniq_id
        self.from_hash data
      end

      # Get a list of all LoadBalancers
      #
      # @param options [Hash] optional keys:
      #  :page_num [Int] page number,
      #  :page_size [Int] page size,
      #  :region [Int] region id
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                LoadBalancer objects)
      def self.list(options={})
        Storm::Base::SODServer.remote_list \
                    '/Network/LoadBalancer/list', options do |i|
          lb = LoadBalancer.new
          lb.from_hash i
          lb
        end
      end

      # Gets a list of all possible Loadbalancer Nodes on an account,
      # regardless of whether or not they are currently loadbalanced.
      #
      # @param region [Int] region id
      # @return [Array] an array of Server objects
      def self.possible_nodes(region=nil)
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/possibleNodes',
                    :region => region
        data[:items].map { |i|
          server = Storm::Server.new
          server.from_hash i
          server
        }
      end

      # Remove a single node from the current loadbalancer
      #
      # @param node [String] node IP address
      def remove_node(node)
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/removeNode',
                    :node => node,
                    :uniq_id => @uniq_id
        self.from_hash data
      end

      # Remove a single service from the current loadbalancer
      #
      # @param src_port [Int] source port of the service
      def remove_service(src_port)
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/removeService',
                    :src_port => src_port,
                    :uniq_id => @uniq_id
        self.from_hash data
      end

      # Get a list of available strategies
      #
      # @return [Array] an array of Strategy object
      def self.strategies
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/strategies'
        data[:strategies].map { |s|
          strat = Strategy.new
          strat.from_hash s
          strat
        }
      end

      # Update an existing loadbalancer
      #
      # @param options [Hash] optional keys:
      #  :name [String] loadbalancer name,
      #  :nodes [Array] an array of node IPs,
      #  :services [Array] an array of Service object,
      #  :nodes [Array] an array of node IPs,
      #  :region [Int] region id,
      #  :session_persistence [Bool],
      #  :ssl_cert [String] ssl certificate string,
      #  :ssl_includes [Bool],
      #  :ssl_int [String] ssl public certificate string,
      #  :ssl_key [String] a private key string,
      #  :ssl_termination [Bool],
      #  :strategy [String] strategy name
      def update(options={})
        param = { :uniq_id => @uniq_id }.merge options
        if param[:services]
          param[:services] = param[:services].map { |s| s.to_hash }
        end
        param[:session_persistence] = param[:session_persistence] ? 1 : 0
        param[:ssl_includes] = param[:ssl_includes] ? 1 : 0
        param[:ssl_termination] = param[:ssl_termination] ? 1 : 0
        data = Storm::Base::SODServer.remote_call \
                    '/Network/LoadBalancer/update', param
        self.from_hash data
      end
    end
  end
end
