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
  # Templates are OS images created and maintained by LiquidWeb.
  # This class defines APIs for remote interaction with those images.
  class Template < Storm::Base::Model
    attr_accessor :deprecated
    attr_accessor :description
    attr_accessor :id
    attr_accessor :manage_level
    attr_accessor :name
    attr_accessor :os
    attr_accessor :zone_availability

    def from_hash(h)
      @deprecated = h[:deprecated].to_i == 0 ? false : true
      @description = h[:description]
      @id = h[:id]
      @manage_level = h[:manage_level]
      @name = h[:name]
      @os = h[:os]
      @zone_availability = h[:zone_availability]
    end

    # Get information about a specific template
    #
    # @param template [String] template name
    # @return [Template] a new template object
    def self.details(template)
      data = Storm::Base::SODServer.remote_call '/Storm/Template/details',
                                                :template => template
      tpl = Template.new
      tpl.from_hash data
      tpl
    end

    # Get information about the current template
    def details
      data = Storm::Base::SODServer.remote_call '/Storm/Template/details',
                                                :id => @id
      self.from_hash data
    end

    # Get a list of useable templates
    #
    # @param options [Hash] optional keys:
    #  :page_num [Int] page number,
    #  :page_size [Int] page size
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Template objects)
    def self.list(options={})
      Storm::Base::SODServer.remote_list '/Storm/Template/list', options do |i|
        tpl = Template.new
        tpl.from_hash i
        tpl
      end
    end

    # Re-images a server with the template requested
    #
    # @param server [Server] an existing server object
    # @param template [String] template name
    # @param options [Hash] optional keys:
    #  :force [Bool] if true it will rebuild the filesystem on the server
    #                     before restoring
    # @return [String] a result message
    def self.restore(server, template, options={})
      param = {
        :uniq_id => server.uniq_id,
        :template => template
        }.merge options
      param[:force] = param[:force] ? 1 : 0
      data = Storm::Base::SODServer.remote_call '/Storm/Template/restore',
                                                param
      data[:reimaged]
    end

    # Re-images a server with the current template
    #
    # @param server [Server] an existing server object
    # @param options [Hash] optional keys:
    #  :force [Bool] if true it will rebuild the filesystem on the server
    #                     before restoring
    # @return [String] a result message
    def restore(server, options={})
      param = {
        :id => @id,
        :uniq_id => server.uniq_id
        }.merge options
      param[:force] = param[:force] ? 1 : 0
      data = Storm::Base::SODServer.remote_call '/Storm/Template/restore',
                                                param
      data[:reimaged]
    end
  end
end
