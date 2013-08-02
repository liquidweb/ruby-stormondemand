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
  module Support
    class Transaction < Storm::Base::Model
      attr_accessor :body
      attr_accessor :email_address
      attr_accessor :feedback
      attr_accessor :full_address
      attr_accessor :old_ticket_id
      attr_accessor :remote_ip
      attr_accessor :reply_body
      attr_accessor :subject
      attr_accessor :ticket_id
      attr_accessor :time
      attr_accessor :truncated
      attr_accessor :type

      def from_hash(h)
        @body = h[:body]
        @email_address = h[:email_address]
        if h[:feedback]
          @feedback = Feedback.new
          @feedback.from_hash h[:feedback]
        end
        @full_address = h[:full_address]
        @old_ticket_id = h[:old_ticket_id]
        @remote_ip = h[:remote_ip]
        @reply_body = h[:reply_body]
        @subject = h[:subject]
        @ticket_id = h[:ticket_id]
        @time = self.get_datetime h, :time
        @truncated = h[:truncated].to_i == 0 ? false : truncated
        @type = h[:type]
      end
    end

    class Feedback < Storm::Base::Model
      attr_accessor :attributes
      attr_accessor :close_date
      attr_accessor :comment
      attr_accessor :create_date
      attr_accessor :id
      attr_accessor :memo
      attr_accessor :rating
      attr_accessor :status
      attr_accessor :ticket_id
      attr_accessor :ttime

      def from_hash(h)
        @attributes = h[:attributes]
        @close_date = self.get_datetime h, :close_date
        @comment = h[:comment]
        @create_date = self.get_datetime h, :create_date
        @id = h[:id]
        @memo = h[:memo]
        @rating = h[:rating]
        @status = h[:status]
        @ticket_id = h[:ticketid]
        @ttime = self.get_datetime h, :ttime
      end
    end

    # This class defines API methods for creating and fetching support tickets.
    class Ticket < Storm::Base::Model
      attr_accessor :account
      attr_accessor :authenticated
      attr_accessor :brand
      attr_accessor :body
      attr_accessor :close_date
      attr_accessor :domain
      attr_accessor :email
      attr_accessor :emergency
      attr_accessor :feedback
      attr_accessor :handler
      attr_accessor :haswarned
      attr_accessor :id
      attr_accessor :lastresponse
      attr_accessor :opened
      attr_accessor :secid
      attr_accessor :status
      attr_accessor :subject
      attr_accessor :transactions
      attr_accessor :type


      def from_hash(h)
        @account = h[:accnt]
        @authenticated = h[:authenticated].to_i == 0 ? false : true
        @brand = h[:brand]
        @body = h[:body]
        @close_date = self.get_datetime h, :closedate
        @domain = h[:domain]
        @email = h[:email]
        @emergency = h[:emergency].to_i == 0 ? false : true
        @feedback = Feedback.new
        if h[:feedback]
          @feedback.from_hash h[:feedback]
        end
        @handler = h[:handler]
        @id = h[:id]
        @haswarned = h[:haswarned].to_i == 0 ? false : true
        @lastresponse = self.get_datetime h, :lastresponse
        @opened = self.get_datetime h, :opened
        @secid = h[:secid]
        @status = h[:status]
        @subject = h[:subject]
        if h[:transactions]
          @transactions = h[:transactions].map do |t|
            tran = Transaction.new
            tran.from_hash t
            tran
          end
        end
        @type = h[:type]
      end

      # Adds or replaces customer feedback for a closed ticket
      #
      # @param comments [String]
      # @param future [String]
      # @param rating [Int]
      # @return [Bool] 
      def add_feedback(comments, future, rating)
        param = {}
        param[:comments] = comments
        param[:future] = future
        param[:rating] = rating
        param[:id] = @id
        param[:secid] = @secid
        data = Storm::Base::SODServer.remote_call \
                    '/Support/Ticket/addFeedback', param
        data[:feedback].to_i == 0 ? false : true
      end

      # Add customer feedback for a specific ticket transaction. The
      # transaction is specified by the time key, which is the time of 
      # the transaction to which feedback is being added.
      #
      # @param time [Datetime]
      # @param rating [String] 'good' or 'poor'
      # @param options [Hash] optional keys:
      #  :attributes [Array] an array of strings,
      #  :comment [String]
      # @return [Transaction] a new Transaction object
      def add_transaction_feedback(time, rating, options={})
        param = {
          :time => time,
          :rating => rating,
          :secid => @secid,
          :ticket_id => @id
        }.merge options
        data = Storm::Base::SODServer.remote_call \
                    '/Support/Ticket/addTransactionFeedback', param
        tran = Transaction.new
        tran.from_hash data
        tran
      end

      # Links a ticket to a given account, setting appropriate attributes and
      # adding a transaction authentication message to the ticket
      #
      # @param username [String]
      # @param password [String]
      # @return [Bool] if it's authenticated
      def authenticate(username, password)
        param = {}
        param[:id] = @id
        param[:secid] = @secid
        param[:username] = username
        param[:password] = password
        data = Storm::Base::SODServer.remote_call \
                    '/Support/Ticket/authenticate', param
        data[:authenticated].to_i == 0 ? false : true
      end

      # Closes a ticket
      #
      # @return [Bool]
      def close
        data = Storm::Base::SODServer.remote_call \
                    '/Support/Ticket/close', :id => @id,
                    :secid => @secid
        data[:closed].to_i == 0 ? false : true
      end

      # Makes a new ticket in the given account
      #
      # @param subject [String]
      # @param body [String]
      # @param type [String]
      # @param email [String]
      # @return [Ticket] a new ticket object
      def self.create(subject, body, type, email)
        data = Storm::Base::SODServer.remote_call \
                    '/Support/Ticket/create', param
        ticket = Ticket.new
        ticket.from_hash data
        ticket
      end

      # Get details information of a ticket
      def details
        data = Storm::Base::SODServer.remote_call '/Support/Ticket/details',
                                                  :id => @id,
                                                  :secid => @secid
        self.from_hash data
      end

      # Get a list of tickets
      #
      # @param options [Hash] optional keys:
      #  :page_num [Int] page number,
      #  :page_size [Int] page size,
      #  :status [String] one of 'open', 'recent', 'closed', 'archived'
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Ticket objects)
      def self.list(options={})
        Storm::Base::SODServer.remote_list \
              '/Support/Ticket/list', options do |t|
          ticket = Ticket.new
          ticket.from_hash t
          ticket
        end
      end

      # Reopens a closed ticket
      #
      # @return [Bool] if it's reopened
      def reopen
        data = Storm::Base::SODServer.remote_call '/Support/Ticket/reopen',
                                                  :id => @id,
                                                  :secid => @secid
        data[:reopened].to_i == 0 ? false : true
      end

      # Add a customer transaction to the ticket
      #
      # @param from [String]
      # @param subject [String]
      # @param body [String]
      # @param options [Hash] optional keys:
      #  :wrap [Bool]
      # @return [Bool] if it's replied
      def reply(from, subject, body, options={})
        param = {
          :from => from,
          :subject => subject,
          :body => body,
          :id => @id,
          :secid => @secid
          }.merge options
        param[:wrap] = param[:wrap] ? 1 : 0
        data = Storm::Base::SODServer.remote_call '/Support/Ticket/reply',
                                                  param
        data[:reply].to_i == 0 ? false : true
      end

      # Returns the list of valid ticket types
      #
      # @return [Array] an array type names
      def self.types
        data = Storm::Base::SODServer.remote_call '/Support/Ticket/types'
        data[:types]
      end
    end
  end
end
