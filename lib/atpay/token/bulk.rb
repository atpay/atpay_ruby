require 'atpay/token/encoder'

module AtPay
  module Token
    class Bulk < Struct.new(:session, :amount, :url, :user_data)
      def auth_only!
        @version = 2
      end

      def expires_in_seconds=(v)
        @expires_in_seconds = v
      end

      def expires_in_seconds
        @expires_in_seconds || (60 * 60 * 24 * 14)
      end

      def to_s
        AtPay::Token::Encoder.new(session, @version, amount, nil, expires_in_seconds, url, user_data).email
      end
    end
  end
end
