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
  # This class defines methods to manage the VPN service of an account
  class VPN < Storm::Base::Model
    attr_accessor :active
    attr_accessor :active_status
    attr_accessor :current_users
    attr_accessor :domain
    attr_accessor :max_users
    attr_accessor :network_range
    attr_accessor :region_id
    attr_accessor :uniq_id
    attr_accessor :vpn

    def from_hash(h)
      @active = h[:active].to_i == 0 ? false : true
      @active_status = h[:active_status]
      @current_users = h[:current_users]
      @domain = h[:domain]
      @max_users = h[:max_users]
      @network_range = h[:network_range]
      @region_id = h[:region_id]
      @uniq_id = h[:uniq_id]
      if h[:vpn]
        @vpn = VPN.new
        @vpn.from_hash h[:vpn]
      end
    end

    # Create a new VPN service
    #
    # @param domain [String]
    # @param features [Hash]
    # @param region_id [Int]
    # @param type [String]
    # @return [VPN] a new VPN object
    def self.create(domain, features, region_id, type)
      param = {}
      param[:domain] = domain
      param[:features] = features
      param[:region_id] = region_id
      param[:type] = type
      data = Storm::Base::SODServer.remote_call '/VPN/create', param
      vpn = VPN.new
      vpn.from_hash data
      vpn
    end

    # Get details information
    def details
      data = Storm::Base::SODServer.remote_call '/VPN/details',
                                                :uniq_id => @uniq_id
      self.from_hash data
    end

    # Lists the authorized VPN users for a given account
    #
    # @param options [Hash] optional keys:
    #  :page_num [Int] page number,
    #  :page_size [Int] page size
    # @return [Hash]  a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                VPNUser objects)
    def list(options={})
      param = { :uniq_id => @uniq_id }.merge options
      Storm::Base::SODServer.remote_list '/VPN/list', param do |u|
        user = VPNUser.new
        user.from_hash u
        user
      end
    end

    # Update the features of a VPN service
    #
    # @param options [Hash] optional keys:
    #  :domain [String],
    #  :features [Hash]
    def update(options={})
      param = { :uniq_id => @uniq_id }.merge options
      data = Storm::Base::SODServer.remote_call '/VPN/update', param
      self.from_hash data
    end
  end

  class VPNUser < Storm::Base::Model
    attr_accessor :ip
    attr_accessor :netmask
    attr_accessor :user_id
    attr_accessor :username

    def from_hash(h)
      @ip = h[:ip]
      @netmask = h[:netmask]
      @user_id = h[:user_id]
      @username = h[:username]
    end
  end
end

