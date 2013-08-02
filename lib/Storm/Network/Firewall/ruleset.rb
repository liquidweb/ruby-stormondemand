require "Storm/Base/model"
require "Storm/Base/sodserver"
require "Storm/server"

module Storm
  module Network
    module Firewall
      # This class defines APIs that give you access to saving and querying
      # your saved rulesets.
      class Ruleset < Storm::Base::Model
        attr_accessor :account
        attr_accessor :destination_ips
        attr_accessor :rules
        attr_accessor :ruleset
        attr_accessor :server

        def from_hash(h)
          @account = h[:accnt]
          @destination_ips = h[:destination_ips]
          @rules = h[:rules]
          @ruleset = h[:ruleset]
          @server = Storm::Server.new
          @server.uniq_id = h[:uniq_id]
        end

        # Saves the ruleset that the given server is using under the given name
        #
        # @param name [String] ruleset name
        # @param server [Server] the specified server object
        # @return [Ruleset] a new Ruleset object
        def self.create(name, server)
          data = Storm::Base::SODServer.remote_call \
                      '/Network/Firewall/Ruleset/create',
                      :name => name, :uniq_id => server.uniq_id
          rs = Ruleset.new
          rs.from_hash data
          rs
        end

        # Get details information of the current ruleset
        def details
          data = Storm::Base::SODServer.remote_call \
                      '/Network/Firewall/Ruleset/details',
                      :ruleset => @ruleset
          self.from_hash data
        end

        # Returns an array reference of rulesets that have been saved for use
        # by this account.
        #
        # @param options [Hash] optional keys:
        #  :page_num [Int] page number,
        #  :page_size [Int] page_size
        # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
        #                :page_size, :page_total and :items (an array of
        #                Ruleset objects)
        def self.list(options={})
          Storm::Base::SODServer.remote_list \
                        '/Network/Firewall/Ruleset/list', options do |i|
            rs = Ruleset.new
            rs.from_hash i
            rs
          end
        end

        # Updates the ruleset with the given ruleset.  Returns a list of
        # affected servers.
        #
        # @param rules [Array] an array of fireware rules
        # @return [Array] an array of affected server ids
        def update(rules)
          data = Storm::Base::SODServer.remote_call \
                        '/Network/Firewall/Ruleset/update',
                        :rules => rules, :ruleset => @ruleset
          data[:updated]
        end
      end
    end
  end
end
