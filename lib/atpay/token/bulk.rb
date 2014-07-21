require 'atpay/token/core'
require 'atpay/token/encoder'

module AtPay
  module Token
    class Bulk < Core
      def initialize(session, amount, custom_data = {})
        super

        self.session               = session
        self.amount                = amount
        self.user_data.custom_data = custom_data
      end
    end
  end
end
