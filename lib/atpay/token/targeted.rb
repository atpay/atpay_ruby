require 'atpay/token/core'
require 'atpay/token/encoder'

module AtPay
  module Token
    class Targeted < Core
      def initialize(session, amount, email_address, custom_data={})
        super

        self.session               = session
        self.amount                = amount
        self.email_address         = email_address
        self.user_data.custom_data = custom_data
      end
    end
  end
end
