require 'ostruct'
require 'multi_json'
require 'atpay/token/registration'

module AtPay
  module Token
    class Core
      attr_accessor :session          # AtPay::Session instance
      attr_accessor :version          # nil: Auth + Capture / 1: Validation (deprecated) / 2: Authorization Only
      attr_accessor :amount           # Dollar amount to capture
      attr_accessor :url
      attr_accessor :email_address
      attr_accessor :user_data
      attr_accessor :expires
      attr_accessor :group

      def initialize(*args)
        self.version            = nil
        self.expires_in_seconds = (86400*14)        # two weeks
        self.user_data          = OpenStruct.new
      end

      def name=(name)
        self.user_data.name = name
      end

      def name
        self.user_data.name
      end

      def url=(url)
        self.user_data.url = url
        @url = url
      end

      def expires_in_seconds=(seconds)
        self.expires = Time.now.to_i + seconds
      end

      def estimated_fulfillment_days=(days)
        self.auth_only!
        self.user_data.fulfillment = days
      end

      def collect_address=(address)
        if address == "shipping_only"
          self.user_data = "ship"
        elsif address == "billing_and_shipping"
          self.user_data = "both"
        else
          self.user_data == address
        end
      end

      def custom_user_data=(str)
        self.user_data.custom_user_data = str
      end

      def set_item_details=(item_details)
        self.user_data.item_details = item_details
      end

      def set_item_quantity=(qty)
        self.user_data.quantity = qty
      end

      def request_custom_data!(name, options={})
        self.user_data.custom_fields ||= []
        self.user_data.custom_fields << { name: name, required: !!options[:required] }
      end

      def auth_only!
        self.version = 2
      end

      def register!
        AtPay::Token::Registration.new(session, to_s)
      end

      def to_s
        AtPay::Token::Encoder.new(session, version, amount, email_address, expires, url, encoded_user_data, group).email
      end

      private
      def encoded_user_data
        MultiJson.dump(user_data.to_h)
      end
    end
  end
end
