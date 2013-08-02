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
  module Network
    # This class defines methods for listing and manipulating the IPs
    # assigned to a server
    class IPNetwork < Storm::Base::Model
      attr_accessor :broadcast
      attr_accessor :gateway
      attr_accessor :id
      attr_accessor :ip
      attr_accessor :netmask
      attr_accessor :reverse_dns

      def from_hash(h)
        @broadcast = h[:broadcast]
        @gateway = h[:gateway]
        @id = h[:id]
        @ip = h[:ip]
        @netmask = h[:netmask]
        @reverse_dns = h[:reverse_dns]
      end

      # Add a number of IPs to an existing server
      #
      # @param server [Server] the specified server
      # @param ip_count [Int] ip count
      # @param options [Hash] optional keys:
      # :reboot [Bool] if true, the server will be stopped, configured
      #                      the new IPs and then be rebooted
      # @return [String] a result message
      def self.add(server, ip_count, options={})
        param = {
          :uniq_id => server.uniq_id,
          :ip_count => ip_count
          }.merge options
        param[:reboot] = param[:reboot] ? 1 : 0
        data = Storm::Base::SODServer.remote_call '/Network/IP/add', param
        data[:adding]
      end

      # Get information about a particular IP.
      #
      # @param server [Server] the specified server
      # @param ip [String] IP address
      # @return [IPNetwork] a new IPNetwork object
      def self.details(server, ip)
        data = Storm::Base::SODServer.remote_call '/Network/IP/details',
                                                  :ip => ip,
                                                  :uniq_id => server.uniq_id
        ipnet = IPNetwork.new
        ipnet.from_hash data
        ipnet
      end

      # Get a list of all IPs for a particular server
      #
      # @param server [Server] the specified server
      # @param options [Hash] optional keys:
      #  :alsowith [String] one or an array of strings,
      #  :page_num [Int] page number,
      #  :page_size [Int] page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                IPNetwork objects)
      def self.list(server, options={})
        param = { :uniq_id => server.uniq_id }.merge options
        Storm::Base::SODServer.remote_list '/Network/IP/list', param do |i|
          ipnet = IPNetwork.new
          ipnet.from_hash i
          ipnet
        end
      end

      # Gets a list of public network asssignments for all subaccounts for a
      # particular account, optionally for a specific zone only.
      #
      # @param options [Hash] optional keys:
      #   :include_pools [Bool],
      #   :page_num [Int] page number,
      #   :page_size [Int] page size,
      #   :zone [Zone] zone
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                IPNetwork objects)
      def self.list_account_public(options={})
        options[:include_pools] = options[:include_pools] ? 1 : 0
        if options[:zone]
          options[:zone_id] = options[:zone].id
          options.delete :zone
        end
        Storm::Base::SODServer.remote_list \
                    '/Network/IP/listAccntPublic', options do |i|
          ipnet = IPNetwork.new
          ipnet.from_hash i
          ipnet
        end
      end

      # Gets a paginated list os all public IPs for a particular server
      #
      # @param server [Server] the specified server
      # @param options [Hash] optional keys:
      #  :alsowith [String] one or an array of strings,
      #  :page_num [Int] page number,
      #  :page_size [Int] page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                IPNetwork objects)
      def self.list_public(server, options={})
        param = { :uniq_id => server.uniq_id }.merge options
        Storm::Base::SODServer.remote_list '/Network/IP/listPublic',
                                           param do |i|
          ipnet = IPNetwork.new
          ipnet.from_hash i
          ipnet
        end
      end

      # Remove a specific IP from a server
      #
      # @param server [Server] the specified server
      # @param ip [String] the sepecified IP
      # @param options [Hash] optional keys:
      #  :reboot [Bool] if true, the server will be stopped, with the IP
      #                      removed and then be rebooted
      # @return [String] a result meessage
      def self.remove(server, ip, options={})
        param = {
          :uniq_id => server.uniq_id,
          :ip => ip
        }.merge options
        options[:reboot] = options[:reboot] ? 1 : 0
        data = Storm::Base::SODServer.remote_call '/Network/IP/remove', param
        data[:removing]
      end

      # Request additional IPs for a server
      #
      # @param server [Server] the specified server
      # @param ip_count [Int] ip count
      # @param options [Hash] optional keys:
      #  :usage_justification [String] optional
      # @return [String] a result message
      def self.request(server, ip_count, options={})
        param = {
          :uniq_id => server.uniq_id,
          :ip_count => ip_count
        }.merge options
        data = Storm::Base::SODServer.remote_call '/Network/IP/request', param
        data[:adding]
      end
    end
  end
end
