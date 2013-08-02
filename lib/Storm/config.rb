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
  # This class define server configuration and APIs for listing them
  class Config < Storm::Base::Model
    attr_accessor :active
    attr_accessor :available
    attr_accessor :category
    attr_accessor :cpu_cores
    attr_accessor :cpu_count
    attr_accessor :cpu_hyperthreading
    attr_accessor :cpu_model
    attr_accessor :cpu_speed
    attr_accessor :description
    attr_accessor :disk
    attr_accessor :disk_count
    attr_accessor :disk_total
    attr_accessor :disk_type
    attr_accessor :featured
    attr_accessor :id
    attr_accessor :memory
    attr_accessor :raid_level
    attr_accessor :ram_available
    attr_accessor :ram_total
    attr_accessor :vcpu
    attr_accessor :zone_availability

    def from_hash(h)
      @active = h[:active].to_i == 1 ? true : false
      @available = h[:available]
      @category = h[:category]
      @cpu_cores = h[:cpu_cores]
      @cpu_count = h[:cpu_count]
      @cpu_hyperthreading = h[:cpu_hyperthreading].to_i == 1 ? true : false
      @cpu_model = h[:cpu_model]
      @cpu_speed = h[:cpu_speed]
      @description = h[:description]
      @disk = h[:disk]
      @disk_count = h[:disk_count]
      @disk_total = h[:disk_total]
      @disk_type = h[:disk_type]
      @featured = h[:featured].to_i == 1 ? true : false
      @id = h[:id]
      @raid_level = h[:raid_level]
      @ram_available = h[:ram_available]
      @ram_total = h[:ram_total]
      @vcpu = h[:vcpu]
      @zone_availability = h[:zone_availability]
    end

    # Get information about a specific config
    def details
      data = Storm::Base::SODServer.remote_call '/Storm/Config/details',
                                                :id => @id
      self.from_hash data
    end

    # Get a list of available server configurations
    #
    # @param options [Hash] optional keys:
    #  :available [Bool] if the config is available,
    #  :category [String] config category ('storm' by default),
    #  :page_num [Int] page number,
    #  :page_size [Int] page size
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Config objects)
    def self.list(options={})
      Storm::Base::SODServer.remote_list '/Storm/Config/list', options do |i|
        conf = Config.new
        conf.from_hash i
        conf
      end
    end
  end
end
