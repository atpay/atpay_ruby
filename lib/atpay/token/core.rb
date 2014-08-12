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

      def email_address
        if @email_address.is_a? String
          email_address = EmailAddress.new
          email_address.address = @email_address
          email_address
        else
          @email_address
        end
      end

      def name=(name)
        self.user_data.name = name
      end

      def name
        self.user_data.name
      end

      def url=(url)
        self.user_data.signup_url = url
        @url = url
      end

      def expires_in_seconds=(seconds)
        self.expires = Time.now.to_i + seconds
      end

      def estimated_fulfillment_days=(days)
        if days.to_i > 0
          self.auth_only!
        else
          self.capture!
        end

        self.user_data.fulfillment = days
      end

      def requires_shipping_address?
        address_options.include?('shipping')
      end

      def requires_shipping_address=(v)
        v ? add_address_option('shipping') : remove_address_option('shipping')
      end

      def requires_billing_address?
        address_options.include?('billing')
      end

      def requires_billing_address=(v)
        v ? add_address_option('billing') : remove_address_option('billing')
      end

      def custom_user_data=(str)
        self.user_data.custom_user_data = str
      end

      def item_details=(item_details)
        self.user_data.item_details = item_details
      end

      def item_quantity=(qty)
        self.user_data.quantity = qty
      end

      def request_custom_data!(name, options={})
        self.user_data.custom_fields ||= []
        self.user_data.custom_fields << { name: name, required: !!options[:required] }
      end

      def auth_only!
        self.version = 2
      end

      def capture!
        self.version = 0
      end

      def register!
        AtPay::Token::Registration.new(session, to_s)
      end

      def to_s
        AtPay::Token::Encoder.new(session, version, amount, email_address, expires, url, encoded_user_data, group).email
      end

      private
      def address_options
        self.user_data.address.split(',')
      rescue
        []
      end

      def remove_address_option(address_option)
        options = (address_options - [address_option])
        self.user_data.address = options.uniq.join(',')
      end

      def add_address_option(address_option)
        options = (address_options << address_option)
        self.user_data.address = options.uniq.join(',')
      end

      def encoded_user_data
        MultiJson.dump(user_data.to_h)
      end
    end
  end
end
