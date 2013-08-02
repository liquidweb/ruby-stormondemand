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
  module Storage
    # This class defines block storage volumes and provides APIs for managing
    # and attaching to/detaching from servers
    class Volume < Storm::Base::Model
      attr_accessor :attached_to
      attr_accessor :cross_attach
      attr_accessor :domain
      attr_accessor :label
      attr_accessor :size
      attr_accessor :status
      attr_accessor :uniq_id
      attr_accessor :zone

      def from_hash(h)
        @attached_to = h[:attachedTo]
        @cross_attach = h[:cross_attach].to_i == 0 ? false : true
        @domain = h[:domain]
        @label = h[:label]
        @size = h[:size]
        @status = h[:status]
        @uniq_id = h[:uniq_id]
        @zone = h[:zone]
      end

      # Attach a volume to a particular instance
      #
      # @param server [Server] an server object
      # @return [Hash] a Hash with :attached and :to keys to indicate
      #                the volume and server id
      def attach(server)
        Storm::Base::SODServer.remote_call '/Storage/Block/Volume/attach',
                                           :to => server.uniq_id,
                                           :uniq_id => @uniq_id
      end

      # Create a new volume
      #
      # @param domain [String] domain name
      # @param size [Int] volume size
      # @param options [Hash] optional keys:
      #  :attach [String] a string identifier,
      #  :cross_attach [Bool] if enabling cross_attach,
      #  :zone [Zone] zone object
      # @return [Volume] a new volume object
      def self.create(domain, size, options={})
        param = {
          :domain => domain,
          :size => size
          }.merge options
        param[:cross_attach] = param[:cross_attach] ? 1 : 0
        param[:zone] = param[:zone].id if param[:zone]
        data = Storm::Base::SODServer.remote_call \
                    '/Storage/Block/Volume/create', param
        vol = Volume.new
        vol.from_hash data
        vol
      end

      # Delete a volume, including any and all data stored on it.  The volume
      # must not be attached to any instances to call this method
      #
      # @return [String] a result message
      def delete
        data = Storm::Base::SODServer.remote_call \
                    '/Storage/Block/Volume/delete', :uniq_id => @uniq_id
        data[:deleted]
      end

      # Detach a volume from an instance
      #
      # @param options [Hash] optional keys:
      #  :server [Server] a server object
      # @return [Hash] a hash with keys :detached and :detached_from
      def detach(options={})
        param = { :uniq_id => @uniq_id }.merge options
        if param[:server]
          param[:detach_from] = param[:server].uniq_id
          param.delete :server
        end
        Storm::Base::SODServer.remote_call '/Storage/Block/Volume/detach',
                                           param
      end

      # Retrieve information about a specific volume
      def details
        data = Storm::Base::SODServer.remote_call \
                      '/Storage/Block/Volume/details', :uniq_id => @uniq_id
        self.from_hash data
      end

      # Get a paginated list of block storage volumes for your account
      #
      # @param options [Hash] optional keys:
      #  :attached_to [Server] a server object,
      #  :page_num [Int] page number,
      #  :page_size [Int] page size
      # @return [hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Volume objects)
      def self.list(options={})
        if options[:attached_to]
          options[:attached_to] = options[:attached_to].uniq_id
        end
        Storm::Base::SODServer.remote_list \
                      '/Storage/Block/Volume/list', options do |i|
          vol = Volume.new
          vol.from_hash i
          vol
        end
      end

      # Resize a volume.  Volumes can currently only be resized larger
      #
      # @param size [Int] new size
      # @return [Hash] a hash with keys :old_size, :new_size and :uniq_id
      def resize(size)
        Storm::Base::SODServer.remote_call '/Storage/Block/Volume/resize',
                                           :new_size => size,
                                           :uniq_id => @uniq_id
      end

      # Update an existing volume.  Currently, only renaming the volume is
      # supported
      #
      # @param options [Hash] optional keys:
      #  :domain [String] domain name,
      #  :cross_attach [Bool] if enabling cross_attach
      def update(options={})
        param = { :uniq_id => @uniq_id }.merge options
        param[:cross_attach] = param[:cross_attach] ? 1 : 0
        data = Storm::Base::SODServer.remote_call \
                      '/Storage/Block/Volume/update', param
        self.from_hash data
      end
    end
  end
end
