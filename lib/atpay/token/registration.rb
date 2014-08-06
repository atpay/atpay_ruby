require 'httpi'

module AtPay
  module Token
    class Registration < Struct.new(:session, :token)
      def initialize(*args)
        super(*args)
        registration  # The registration should occur even if we don't access a url or id
      end

      def url
        registration['url']
      end

      def qrcode_url
        "#{session.endpoint}/offers/#{registration['id']}.png"
      end

      def id
        registration['id']
      end

      def short
        "atpay://#{id}"
      end

      private
      def registration
        @registration ||= (
          request = HTTPI::Request.new("#{session.endpoint}/token/registrations")
          request.body = { token: self.token }

          response = HTTPI.post(request)
          MultiJson.load(response.body)
        )
      end
    end
  end
end
