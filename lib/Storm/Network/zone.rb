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
    class ZoneRegion < Storm::Base::Model
      attr_accessor :id
      attr_accessor :name

      def from_hash(h)
        @id = h[:id]
        @name = h[:name]
      end
    end

    class ZoneHVS < Storm::Base::Model
      attr_accessor :kvm
      attr_accessor :xen

      def from_hash(h)
        @kvm = h[:kvm].to_i == 1 ? true : false
        @xen = h[:xen].to_i == 1 ? true : false
      end
    end

    # This class defines APIs for listing network zones.
    class Zone < Storm::Base::Model
      attr_accessor :id
      attr_accessor :is_default
      attr_accessor :name
      attr_accessor :region
      attr_accessor :status
      attr_accessor :valid_source_hvs

      def from_hash(h)
        @id = h[:id]
        @is_default = h[:is_default].to_i == 1 ? true : false
        @name = h[:name]
        @region = ZoneRegion.new
        if h[:region]
          @region.from_hash h[:region]
        end
        @status = h[:status]
        @valid_source_hvs = ZoneHVS.new
        if h[:valid_source_hvs]
          @valid_source_hvs.from_hash h[:valid_source_hvs]
        end
      end

      # Get details of a the current zone
      def details
        data = Storm::Base::SODServer.remote_call '/Network/Zone/details',
                                                  :id => @id
        self.from_hash data
      end

      # Get a list of Zones
      #
      # @param options [Hash] optional keys:
      #  :page_num [Int] page number,
      #  :page_size [Int] page size,
      #  :region [String] region name
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Zone objects)
      def self.list(options={})
        Storm::Base::SODServer.remote_list '/Network/Zone/list', options do |i|
          zone = Zone.new
          zone.from_hash i
          zone
        end
      end

      # Set the current zone as the default
      def set_default
        Storm::Base::SODServer.remote_call '/Network/Zone/setDefault',
                                           :id => @id
      end
    end
  end
end
