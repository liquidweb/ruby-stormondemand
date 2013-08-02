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
  module Utilities
    # This module defines basic methods for getting the version and state of the api.
    module Info
      # This method can be used as a basic check to see if communication with
      # the api is possible
      #
      # @return [String] a ping message
      def self.ping
        data = Storm::Base::SODServer.remote_call '/Utilities/Info/ping'
        data[:ping]
      end

      # Returns the version of the api you are using
      #
      # @return [String] version
      def self.version
        data = Storm::Base::SODServer.remote_call '/Utilities/Info/version'
        data[:version]
      end
    end
  end
end
