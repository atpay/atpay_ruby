require 'atpay/token/encoder'

module AtPay
  module Token
    class Bulk < Struct.new(:session, :amount, :url, :user_data)
      def auth_only!
        @version = 2
      end

      def to_s
        AtPay::Token::Encoder.new(session, @version, amount, nil, 60 * 60 * 24 * 14, url, user_data).email
      end
    end
  end
end
