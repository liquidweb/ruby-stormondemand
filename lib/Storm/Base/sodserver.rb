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

require 'json'
require 'base64'
require 'excon'
require 'Storm/Base/exception'
require 'Storm/Account/auth'

module Storm
  module Base
    STORM_BASE_URL = 'https://api.stormondemand.com'
    STORM_API_VERSION = 'v1'

    # This is the class to manage network connection and JSON encode/decode
    class SODServer
      # Call an API method with parameters
      #
      # @param path [String] the API method path
      # @param parameter [Hash] optional parameters
      # @return [Hash]
      def self.remote_call(path, parameter={})
        real_path = "/#{STORM_API_VERSION}#{path}"
        param = {}
        param[:params] = parameter
        resp = Excon.post STORM_BASE_URL,
                          :path => real_path,
                          :body => param.to_json,
                          :headers => self.build_auth_header
        if resp.status == 200
          data = JSON.parse resp.body, :symbolize_names => true
          if data[:error_class]
            e_msg = "#{ data[:error_class] } : #{ data[:full_message] }"
            raise Storm::Base::Exception::StormException, e_msg
          else
            data
          end
        else
          e_msg = "HTTP Error: #{ resp.status.to_s } => #{ resp.body }"
          raise Storm::Base::Exception::HttpException, e_msg
        end
      end

      # Call an API that return a list of items
      #
      # @param path [String] API method path
      # @param parameter [Hash] optional parameter
      # @return [Hash]
      def self.remote_list(path, parameter={})
        real_path = "/#{STORM_API_VERSION}#{path}"
        param = {}
        param[:params] = parameter
        resp = Excon.post STORM_BASE_URL,
                          :path => real_path,
                          :body => param.to_json,
                          :headers => self.build_auth_header
        if resp.status == 200
          data = JSON.parse resp.body, :symbolize_names => true
          if data[:error_class]
            e_msg = "#{ data[:error_class] } : #{ data[:full_message] }"
            raise Storm::Base::Exception::StormException, e_msg
          else
            res = {}
            res[:item_count] = data[:item_count].to_i
            res[:item_total] = data[:item_total].to_i
            res[:page_num] = data[:page_num].to_i
            res[:page_size] = data[:page_size].to_i
            res[:page_total] = data[:page_total].to_i
            res[:items] = data[:items].map { |e| yield e }
            res
          end
        else
          e_msg = "HTTP Error: #{ resp.status.to_s } => #{ resp.body }"
          raise Storm::Base::Exception::HttpException, e_msg
        end
      end

      # A helper function to build the Authentication HTTP Header
      #
      # @return [String]
      def self.build_auth_header
        username = Storm::Account::Auth.username
        password = Storm::Account::Auth.password
        token = Storm::Account::Auth.token_string
        if username == nil and password == nil
          raise Storm::Base::Exception::StormException,
                'Please setup your username and password first.'
        end
        credential = token ? token : password
        str = Base64.encode64("#{ username }:#{ credential }").chomp
        {'Content-Type' => 'application/json',
         'Authorization' => "Basic #{ str }"
        }
      end
    end
  end
end
