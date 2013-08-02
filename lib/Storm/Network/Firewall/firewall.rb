require "Storm/Base/model"
require "Storm/Base/sodserver"

module Storm
  module Network
    module Firewall
      # This class defines methods for manipulating the firewall of a storm
      # server.
      class Firewall < Storm::Base::Model
        attr_accessor :allow
        attr_accessor :rules
        attr_accessor :ruleset
        attr_accessor :type

        def from_hash(h)
          @allow = h[:allow]
          @rules = h[:rules]
          @ruleset = h[:ruleset]
          @type = h[:type]
        end

        # Get details about the current firewall settings for a particular
        # server
        #
        # @param server [Server] the specified server
        # @return [Firewall] a new Firewall object
        def self.details(server)
          data = Storm::Base::SODServer.remote_call \
                      '/Network/Firewall/details', :uniq_id => server.uniq_id
          fw = Firewall.new
          fw.from_hash data
          fw
        end

        # Returns a list of options that the basic firewall accepts
        #
        # @param server [Server] the specified server
        # @return [Array] an array of option strings
        def self.get_basic_options(server)
          data = Storm::Base::SODServer.remote_call \
                      '/Network/Firewall/getBasicOptions',
                      :uniq_id => server.uniq_id
          data[:options]
        end

        # Returns the rules for the given server, regardless of type
        #
        # @param server [Server] the specified server
        # @return [Array] an array of firewall rules
        def self.rules(server)
          data = Storm::Base::SODServer.remote_call \
                      '/Network/Firewall/rules', :uniq_id => server.uniq_id
          data[:rules]
        end

        # Updates the firewall setting for a given server
        #
        # @param server [Server] the specified server
        # @param type [String] one of 'basic', 'saved', 'advanced' or none
        # @param allow [Array]
        # @param rules [Array]
        # @param ruleset [String]
        def self.update(server, type, allow, rules, ruleset)
          param = {}
          param[:uniq_id] = server.uniq_id
          param[:type] = type if type
          param[:allow] = allow if allow
          param[:rules] = rules if rules
          param[:ruleset] = ruleset if ruleset
          data = Storm::Base::SODServer.remote_call \
                      '/Network/Firewall/update', param
          data[:modified]
        end
      end
    end
  end
end
