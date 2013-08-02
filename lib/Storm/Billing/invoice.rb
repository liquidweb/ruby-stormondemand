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

module Storm
  module Billing
    # This class defines methods for fetching the billing history of the
    # logged in account
    class Invoice < Storm::Base::Model
      attr_accessor :account
      attr_accessor :bill_date
      attr_accessor :due
      attr_accessor :end_date
      attr_accessor :id
      attr_accessor :lineitem_groups
      attr_accessor :payments
      attr_accessor :start_date
      attr_accessor :status
      attr_accessor :total
      attr_accessor :type

      def from_hash(h)
        @account = h[:accnt]
        @bill_date = self.get_datetime h, :bill_date
        @due = h[:due]
        @end_date = self.get_datetime h, :end_date
        @id = h[:id]
        if h[:lineitem_groups]
          @lineitem_groups = h[:lineitem_groups].map do |group|
            bg = BillGroup.new
            bg.from_hash group
            bg
          end
        end
        if h[:payments]
          @payments = h[:payments].map do |p|
            pm = Payment.new
            pm.from_hash p
            pm
          end
        end
        @start_date = self.get_datetime h, :start_date
        @status = h[:status]
        @total = h[:total]
        @type = h[:type]
      end

      # Returns data specific to one invoice. In addition to what is returned
      # in the list method, additional details about the specific lineitems
      # are included in this method.
      def details
        raise 'id is not set for the current object' unless self.id
        data = Storm::Base::SODServer.remote_call '/Billing/Invoice/details',
                                                  :id => self.id
        self.from_hash data
      end

      # Returns a list of all the invoices for the logged in account.
      # Invoices are created at your regular billing date, but are also
      # created for one-off items like creating or cloning a server.
      #
      # @param options [Hash] optional keys:
      #  :page_num [Int] a positive integer for page number,
      #  :page_size [Int] a positive integer for page size
      # @return [Hash] a hash with keys: :item_count, :item_total, :page_num,
      #                :page_size, :page_total and :items (an array of
      #                Invoice objects)
      def self.list(options={})
        params = {
          :page_num => 1,
          :page_size => 10
        }.merge options
        Storm::Base::SODServer.remote_list '/Billing/Invoice/list',
                                    :page_num => params[:page_num],
                                    :page_size => params[:page_size] do |i|
          item = Invoice.new
          item.from_hash i
          item
        end
      end

      # Returns a projection of what current account's next bill will look
      # like at their next bill date.
      # @return [Invoice] an Invoice object
      def self.next
        data = Storm::Base::SODServer.remote_call '/Billing/Invoice/next'
        inv = Invoice.new
        inv.from_hash data
        inv
      end
    end

    class BillItem < Storm::Base::Model
      attr_accessor :charged_amount
      attr_accessor :end_date
      attr_accessor :description
      attr_accessor :quantity
      attr_accessor :start_date

      def from_hash(h)
        @charged_amount = h[:charged_amount]
        @end_date = self.get_datetime h, :end_date
        @description = h[:item_description]
        @quantity = h[:quantity]
        @start_date = self.get_datetime h, :start_date
      end
    end

    class BillGroup < Storm::Base::Model
      attr_accessor :description
      attr_accessor :end_date
      attr_accessor :line_items
      attr_accessor :overdue
      attr_accessor :start_date
      attr_accessor :subtotal

      def from_hash(h)
        @description = h[:description]
        @end_date = self.get_date h, :end_date
        if h[:line_items]
          @line_items = h[:line_items].map do |l|
            item = BillItem.new
            item.from_hash l
            item
          end
        end
        @overdue = h[:overdue]
        @start_date = self.get_date h, :start_date
        @subtotal = h[:subtotal]
      end
    end

    class Payment < Storm::Base::Model
      attr_accessor :account
      attr_accessor :amount
      attr_accessor :paid_date
      attr_accessor :type

      def from_hash(h)
        @account = h[:account]
        @amount = h[:amount]
        @paid_date = self.get_datetime h, :paid_date
        @type = h[:type]
      end

      # Charges the credit card on file for the current account the given
      # amount, and applies those new funds to the account.  Currently this
      # method is only useful for credit card accounts.  A forbidden
      # exception will be thrown if used with a check account.
      #
      # @param amount [Int] A positive monetary value
      # @param options [Hash] optional keys:
      #       :card_code [String] The cvv code of a credit card, consisting of
      #           a number at least 3 digits and up to 4 digits in length]
      # @return [Int] A positive monetary value
      def self.make(amount, options={})
        raise 'amount should be positive' unless amount > 0
        param = { :amount => amount }.merge options
        data = Storm::Base::SODServer.remote_call '/Billing/Payment/make',
                                                  param
        data[:amount]
      end
    end
  end
end
