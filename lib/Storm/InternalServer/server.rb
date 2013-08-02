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

require 'Storm/Base/model'
require 'Storm/Base/sodserver'
require 'Storm/notification'

module Storm
  module InternalServer
    # Class for managing servers. This is for internal use.
    class Server < Storm::Base::Model
      attr_accessor :account
      attr_accessor :active
      attr_accessor :capabilities
      attr_accessor :categories
      attr_accessor :description
      attr_accessor :domain
      attr_accessor :features
      attr_accessor :ip
      attr_accessor :region_id
      attr_accessor :type
      attr_accessor :uniq_id
      attr_accessor :username
      attr_accessor :valid_source_hvs

      def from_hash(h)
        @account = h[:accnt]
        @active = h[:active]
        @capabilities = h[:capabilities]
        @categories = h[:categories]
        @description = h[:description]
        @domain = h[:domain]
        @features = h[:features]
        @ip = h[:ip]
        @region_id = h[:region_id]
        @type = h[:type]
        @uniq_id = h[:uniq_id]
        @username = h[:username]
        @valid_source_hvs = h[:valid_source_hvs]
      end

      # Checks if a given domain is free.  Will return an adjusted domain
      # name if there was a conflict with another domain on your account.
      #
      # @param domain [String] A fully-qualified domain name
      # @return [String] A fully-qualified domain name
      def self.available(domain)
        data = Storm::Base::SODServer.remote_call '/Server/available',
                                                  :domain => domain
        data[:domain]
      end

      # Clone the current server. Returns the information about the newly
      # created clone.
      #
      # @param domain [String] domain name
      # @param password [String] a password of 7-30 characters
      # @param options [Hash] optional keys:
      #  :config [Config] an optional Config object,
      #  :p_count [Int] a positive integer,
      #  :zone [Zone] the zone you want to clone
      # @return [Server] the newly created Server object
      def clone(domain, password, options={})
        param = {
          :uniq_id => @uniq_id,
          :domain => domain,
          :password => password,
        }.merge options
        if param[:config]
          param[:config_id] = param[:config].id
          param.delete :config
        end
        if param[:zone]
          param[:zone] = param[:zone].id
        end
        data = Storm::Base::SODServer.remote_call '/Server/clone', param
        cloned_server = Server.new
        cloned_server.from_hash data
        cloned_server
      end

      # Provision a new server. This fires off the build process, which does
      # the actual provisioning of a new server. 
      #
      # @param domain [String] a fully-qualified domain name
      # @param features [Hash] an associative array of product features
      # @param password [String] the root password for the server (7-30 chars)
      # @param type [String] the product code for the provisioned server to
      #                      create
      # @param options [Hash] optional keys:
      #  :backup [Backup] an optional Backup object,
      #  :image [Image] you can specify a user-created image object,
      #  :public_ssh_key [String] optional public ssh key you want added,
      #  :zone [Zone] the zone you wish to deploy the server in
      # @return [Server] a newly created Server object
      def self.create(domain, features, password, type, options={})
        param = {
          :domain => domain,
          :features => features,
          :password => password,
          :type => type
        }.merge options
        if param[:backup]
          param[:backup_id] = param[:backup].id
          param.delete :backup
        end
        if param[:image]
          param[:image_id] = param[:image].id
          param.delete :image
        end
        if param[:zone]
          param[:zone] = param[:zone].id
        end
        data = Storm::Base::SODServer.remote_call '/Server/create', param
        server = Server.new
        server.from_hash data
        server
      end

      # Kills a server.  It will refund for any remaining time that has been
      # prepaid, charge any outstanding bandwidth charges, and then start the
      # workflow to tear down the server.
      #
      # @return [String] A six-character identifier
      def destroy
        data = Storm::Base::SODServer.remote_call '/Server/destroy',
                                                  :uniq_id => @uniq_id
        data[:destroyed]
      end

      # Gets data relevant to a provisioned server
      def details
        data = Storm::Base::SODServer.remote_call '/Server/details',
                                                  :uniq_id => @uniq_id
        self.from_hash data
      end

      # Get a list of notifications for a specific server
      #
      # @param options [Hash] optional keys:
      #  :page_num [Int] a positive number of page number,
      #  :page_size [Int] a positive number of page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Notification objects)
      def history(options={})
        param = { :uniq_id => @uniq_id }.merge options
        Storm::Base::SODServer.remote_list '/Server/history', param do |i|
          notification = Notification.new
          notification.from_hash i
          notification
        end
      end

      # Get a list of servers, services, and devices on your account
      #
      # @param options [Hash] optional keys:
      #  :category [String] service category, valid options: Dedicated,
      #                     Provisioned, LoadBalancer, HPBS
      #  :page_num [Int] page number,
      #  :page_size [Int] page size,
      #  :type [String] a valid subaccnt type descriptor
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Server objects)
      def self.list(options={})
        Storm::Base::SODServer.remote_list '/Server/list', param do |i|
          server = Server.new
          server.from_hash i
          server
        end
      end

      # Reboot the server
      #
      # @param options [Hash] optional keys:
      #  :force [Bool] whether forcing a hard reboot of the server
      # @return [Hash] a hash with key :rebooted and :requested, both value
      #                are strings.
      def reboot(options={})
        param = { :uniq_id => @uniq_id }.merge options
        param[:force] = param[:force] ? 1 : 0
        Storm::Base::SODServer.remote_call '/Server/reboot', param
      end

      # Resize the current server to a new configuration
      #
      # @param new_size [Int] the new size
      # @param options [Hash] optional keys:
      #  :skip_fs_resize [Bool] whether skip filesystem resizing
      def resize(new_size, options={})
        param = {
          :uniq_id => @uniq_id,
          :new_size => new_size
          }.merge options
        options[:skip_fs_resize] = options[:skip_fs_resize] ? 1 : 0
        data = Storm::Base::SODServer.remote_call '/Server/resize', param
        self.from_hash data
      end

      # Shutdown the current server
      #
      # @param options [Hash] optional keys:
      #  :force [Bool] whether forcing a hard shutdown of the server
      # @return [String] a string identifier
      def shutdown(options={})
        param = { :uniq_id => @uniq_id }.merge options
        param[:force] = param[:force] ? 1 : 0
        data = Storm::Base::SODServer.remote_call '/Server/shutdown', param
        data[:shutdown]
      end

      # Boot the server.  If the server is already running, this will do nothing.
      #
      # @return [String] a string identifier
      def start
        data = Storm::Base::SODServer.remote_call '/Server/start',
                                                  :uniq_id => @uniq_id
        data[:started]
      end

      # Update the details of the server
      #
      # @param options [Hash] optional keys:
      #  :domain [String] a fully-qualified domain name,
      #  :features [Hash] a hash of features
      def update(options={})
        param = { :uniq_id => @uniq_id }.merge options
        data = Storm::Base::SODServer.remote_call '/Server/update', param
        self.from_hash data
      end
    end
  end
end