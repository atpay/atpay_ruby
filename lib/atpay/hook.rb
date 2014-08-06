require 'openssl'
require 'multi_json'

module AtPay
  class Hook
    def initialize(session, details, signature)
      @session   = session
      @details   = details
      @signature = signature

      verify_signature!
      verify_success!
    end

    def details
      MultiJson.load(@details)
    end

    private
    def verify_signature!
      unless OpenSSL::HMAC.hexdigest('sha1', @session.private_key, @details) == @signature
        raise InvalidSignatureError
      end
    end

    def verify_success!
      if @details['type'] == 'error'
        raise Error.new(@details['error'])
      elsif @details['type'] == 'fatal'
        raise FatalError.new(@details['error'])
      end
    end
  end
end
