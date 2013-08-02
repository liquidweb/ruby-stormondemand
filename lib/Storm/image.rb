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
  # This class defines APIs to manage server images.
  class Image < Storm::Base::Model
    attr_accessor :account
    attr_accessor :features
    attr_accessor :hv_type
    attr_accessor :id
    attr_accessor :name
    attr_accessor :size
    attr_accessor :source_hostname
    attr_accessor :source_uniq_id
    attr_accessor :template
    attr_accessor :template_description
    attr_accessor :time_taken

    def from_hash(h)
      @id = h[:id]
      @account = h[:accnt]
      @features = h[:features]
      @hv_type = h[:hv_type]
      @name = h[:name]
      @size = h[:size]
      @source_hostname = h[:source_hostname]
      @source_uniq_id = h[:source_uniq_id]
      @template = h[:template]
      @template_description = h[:template_description]
      @time_taken = self.get_datetime h, :time_taken
    end

    # Fires off a process to image the server right now
    #
    # @param name [String] a name for the image
    # @param server [Server] an existing server object
    # @return [String] a string permitting tabs, carriage returns and newlines
    def self.create(name, server)
      data = Storm::Base::SODServer.remote_call '/Storm/Image/create',
                                                :name => name,
                                                :uniq_id => server.uniq_id
      data[:created]
    end

    # Fires off a process to delete the requested image from the image server
    # that stores it
    #
    # @return [Int] a positive integer value
    def delete
      data = Storm::Base::SODServer.remote_call '/Storm/Image/delete',
                                                :id => @id
      data[:deleted]
    end

    # Get information about a specific image
    def details
      data = Storm::Base::SODServer.remote_call '/Storm/Image/details',
                                                :id => @id
      self.from_hash data
    end

    # Get a paginated list of previously-created images for your account
    #
    # @param options [Hash] optional keys:
    #  :page_num [Int] page number,
    #  :page_size [Int] page size
    # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
    #                :page_size, :page_total and :items (an array of
    #                Image objects)
    def self.list(options={})
      Storm::Base::SODServer.remote_list '/Storm/Image/list', options do |i|
        img = Image.new
        img.from_hash i
        img
      end
    end

    # Re-images a server with the image requested
    #
    # @param server [Server] an existing server object
    # @param options [Hash] optional keys:
    #  :force [Bool] whether forcing the restore
    # @return [String] a string message
    def restore(server, options={})
      param = {
        :id => @id,
        :uniq_id => server.uniq_id
        }.merge options
      param[:force] = param[:force] ? 1 : 0
      data = Storm::Base::SODServer.remote_call '/Storm/Image/restore', param
      data[:reimaged]
    end

    # Update an existing image.  Currently, only renaming the image is
    # supported.
    #
    # @param name [String] the new image name
    def update(name)
      data = Storm::Base::SODServer.remote_call '/Storm/Image/restore',
                                                :id => @id,
                                                :name => name
      self.from_hash data
    end
  end
end
