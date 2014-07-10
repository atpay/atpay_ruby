module AtPay
  module Token
    class Invoice < Struct.new(:session, :amount, :email_address, :user_data)
      def to_s
        Token::Encoder.new(session, nil, amount, email_address, 60 * 60 * 24 * 14, nil, user_data).email
      end
    end
  end
end
