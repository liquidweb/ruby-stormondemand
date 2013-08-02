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
    # This class defines network assignments in a pool
    class Assignment < Storm::Base::Model
      attr_accessor :begin_range
      attr_accessor :broadcast
      attr_accessor :end_range
      attr_accessor :gateway
      attr_accessor :netmask
      attr_accessor :id
      attr_accessor :zone

      def from_hash(h)
        @begin_range = h[:begin_range]
        @broadcast = h[:broadcast]
        @end_range = h[:end_range]
        @gateway = h[:gateway]
        @netmask = h[:netmask]
        @id = h[:id]
        @zone = Storm::Network::Zone.new
        @zone.id = h[:zone_id]
      end
    end

    # This class defines API methods that manage IP pools
    class Pool < Storm::Base::Model
      attr_accessor :account
      attr_accessor :assignments
      attr_accessor :id
      attr_accessor :uniq_id
      attr_accessor :zone

      def from_hash(h)
        @account = h[:accnt]
        if h[:assignments]
          @assignments = h[:assignments].map do |as|
            assign = Assignment.new
            assign.from_hash as
            assign
          end
        end
        @id = h[:id]
        @uniq_id = h[:uniq_id]
        @zone = Storm::Network::Zone.new
        @zone.id = h[:zone_id]
      end

      # Create a new IP Pool
      #
      # @param add_ips [Array] an array of IP addresses
      # @param new_ips [Int] number of new IPs
      # @param zone [Zone] a network zone
      # @return [Pool] a new Pool object
      def self.create(add_ips, new_ips, zone)
        if add_ips == nil and new_ips == 0
          raise 'Either add_ips or new_ips must be provided'
        end
        param = {}
        param[:add_ips] = add_ips if add_ips
        param[:new_ips] = new_ips if new_ips
        param[:zone_id] = zone.id
        data = Storm::Base::SODServer.remote_call '/Network/Pool/create', param
        pool = Pool.new
        pool.from_hash data
        pool.zone = zone
        pool
      end

      # Delete the current pool and all the assignments that are only in the
      # pool.
      #
      # @return [String] a result message
      def delete
        data = Storm::Base::SODServer.remote_call '/Network/Pool/delete',
                                                  :uniq_id => @uniq_id
        data[:deleted]
      end

      # Delete a pool and all the assignments that are only in the pool
      #
      # @param subaccnt [Int] sub account number
      # @return [String] a result message
      def self.delete(subaccnt)
        data = Storm::Base::SODServer.remote_call '/Network/Pool/delete',
                                                  :subaccnt => subaccnt
        data[:deleted]
      end

      # Get the details of the IP Pool
      #
      # @param options [Hash] optional keys:
      #  :free_only [Bool]
      def details(options={})
        param = {
          :id => @id,
          :uniq_id => @uniq_id,
          :free_only => false
        }.merge options
        param[:free_only] = param[:free_only] ? 1 : 0
        data = Storm::Base::SODServer.remote_call '/Network/Pool/details',
                                                  param
        self.from_hash data
      end

      # Get a list of network assignments for a particular IP pool
      #
      # @param options [Hash] optional keys:
      #  :zone [Zone] a zone object,
      #  :alsowith [String/Array] one or an array of strings,
      #  :page_num [Int] page number,
      #  :page_size [Int] page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Assignment objects)
      def self.list(options={})
        if options[:zone]
          options[:zone_id] = options[:zone].id
          options.delete :zond
        end
        Storm::Base::SODServer.remote_list '/Network/Pool/list', options do |i|
          asgnm = Assignment.new
          asgnm.from_hash i
          asgnm
        end
      end

      # Update the IP Pool
      #
      # @param options [Hash] optional keys:
      #  :add_ips [Array] an array of IPs to add,
      #  :remove_ips [Array] an array of IPs to remove,
      #  :new_ips [Int] number of new IPs
      def update(options={})
        param = { :id => @id, :uniq_id => @uniq_id }.merge options
        data = Storm::Base::SODServer.remote_call '/Network/Pool/update', param
        self.from_hash data
      end
    end
  end
end
