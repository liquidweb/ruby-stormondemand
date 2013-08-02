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

module Storm
  module Base
    # This module defines the basic exception types used
    module Exception
      # Exception type for all Storm exceptions/errors we get from the API server
      class StormException < StandardError
      end

      # Exception type for all HTTP level errors
      class HttpException < StandardError
      end
    end
  end
end