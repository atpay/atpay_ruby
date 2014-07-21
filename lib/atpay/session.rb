module AtPay
  class Session < Struct.new(:partner_id, :public_key, :private_key)
    attr_accessor :endpoint

    def atpay_public_key=(atpay_public_key)
      @atpay_public_key = Base64.decode64(atpay_public_key)
    end

    def atpay_public_key
      @atpay_public_key || PUBLIC_KEY
    end

    def endpoint
      @endpoint || "https://dashboard.atpay.com"
    end
  end
end
