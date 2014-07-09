module AtPay
  class Session < Struct.new(:partner_id, :public_key, :private_key)
  end
end
