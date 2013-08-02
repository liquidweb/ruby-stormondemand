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
    module DNS
      # This class defines basic zone data used when creating a new DNS zone
      class ZoneData < Storm::Base::Model
        attr_accessor :contact
        attr_accessor :ip
        attr_accessor :primary
        attr_accessor :secondary

        def from_hash(h)
          @contact = h[:contact]
          @ip = h[:ip]
          @primary = h[:primary]
          @secondary = h[:secondary]
        end

        def to_hash
          res = {}
          res[:contact] = @contact
          res[:ip] = @ip
          res[:primary] = @primary
          res[:secondary] = @secondary
          res
        end
      end

      # This class defines the API methods for creating and deleting
      # zones from our DNS system, as well as getting information about what
      # zones we are currently serving for you.
      class Zone < Storm::Base::Model
        attr_accessor :active
        attr_accessor :delegation_checked
        attr_accessor :delegation_status
        attr_accessor :id
        attr_accessor :master
        attr_accessor :name
        attr_accessor :notified_serial
        attr_accessor :region_support
        attr_accessor :registering
        attr_accessor :type

        def from_hash(h)
          @active = h[:active] == 0 ? false : true
          @delegation_checked = self.get_datetime h, :delegation_checked
          @delegation_status = h[:delegation_status]
          @id = h[:id]
          @master = h[:master]
          @name = h[:name]
          @notified_serial = h[:notified_serial]
          @region_support = h[:region_support].to_i == 1 ? true : false
          @registering = h[:registering]
          @type = h[:type]
        end

        # Add a new DNS Zone
        #
        # @param name [String]
        # @param options [Hash] optional keys:
        #  :region_support [Bool],
        #  :register [Bool],
        #  :zone_data [ZoneData]
        # @return [Zone] a new Zone object
        def self.create(name, options={})
          param = { :name => name }.merge options
          param[:region_support] = param[:region_support] ? 1 : 0
          param[:register] = param[:register] ? 1 : 0
          param[:zone_data] = param[:zone_data].to_hash if param[:zone_data]
          data = Storm::Base::SODServer.remote_call '/Network/DNS/Zone/create',
                                                    param
          z = Zone.new
          z.from_hash data
          z
        end

        # Check if a DNS zone is properly delegated to our nameservers
        #
        # @return [String] result message
        def delegation
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Zone/delegation', :id => @id
          data[:delegation]
        end

        # Delete a DNS Zone
        #
        # @return [String] a domain name
        def delete
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Zone/delete', :id => @id
          data[:deleted]
        end

        # Get details information on a particular Zone
        def details
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Zone/details', :id => @id
          self.from_hash data
        end

        # Get a list of zones
        #
        # @param options [Hash] optional keys:
        #  :page_num [Int] page number,
        #  :page_size [Int] page size
        # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
        #                :page_size, :page_total and :items (an array of
        #                Zone objects)
        def self.list(options={})
          Storm::Base::SODServer.remote_list '/Network/DNS/Zone/list',
                                             options do |z|
                                              zone = Zone.new
                                              zone.from_hash z
                                              zone
                                            end
        end

        # Update the zone features
        #
        # @param options [Hash] optional keys:
        #  :DNSRegionSupport [Bool]
        def update(options={})
          param = { :id => @id }.merge options
          param[:DNSRegionSupport] = param[:DNSRegionSupport] ? 1 : 0
          data = Storm::Base::SODServer.remote_call '/Network/DNS/Zone/update',
                                                    param
          self.from_hash data
        end
      end
    end
  end
end
