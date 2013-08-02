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

require "Storm/Base/sodserver"

module Storm
  module Network
    module DNS
      # This module defines methods to manage Reverse DNS
      module Reverse
        # Remove a reverse DNS record
        #
        # @param ip [String]
        # @param options [Hash] optional keys:
        #  :hostname [String]
        # @return [String] the deleted IP address
        def self.delete(ip, options={})
          param = { :ip => ip }.merge options
          data = Storm::Base::SODServer.remote_call \
                      '/Network/DNS/Reverse/delete', param
          data[:deleted]
        end

        # Update a record
        #
        # @param ip [String]
        # @param hostname [String]
        # @return [Hash] a hash with IP as keys and domain name as values
        def self.update(ip, hostname)
          Storm::Base::SODServer.remote_call \
               '/Network/DNS/Reverse/update', :ip => ip, :hostname => hostname
        end
      end
    end
  end
end
