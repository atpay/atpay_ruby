module AtPay
  module Token
    class Invoice < Struct.new(:session, :amount, :email_address, :user_data)
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
        Token::Encoder.new(session, @version, amount, email_address, expires_in_seconds, nil, user_data).email
      end
    end
  end
end
