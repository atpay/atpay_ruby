require 'spec_helper'
require 'atpay/session'
require 'atpay/token/targeted'

describe AtPay::Token::Targeted do
  let(:partner_id)        { 1 }
  let(:private_key)       { 'xx5okSjkqJu30biXEFI/y05B68JRCr7ReSdufmtrILY=' }
  let(:public_key)        { 'gOVRRMKRwCHD0nkGiQ1/1EKcSUjO/einHq7MZ/AMkzQ=' }
  let(:atpay_public_key)  { 'x3iJge6NCMx9cYqxoJHmFgUryVyXqCwapGapFURYh18=' }
  let(:atpay_private_key) { '' }

  let(:session)       { AtPay::Session.new(partner_id, public_key, private_key) }
  let(:amount)        { 20.0 }
  let(:email_address) { 'http://example.com/' }
  let(:user_data)     { 'sku-123' }

  it 'creates a new token without exception' do
    AtPay::Token::Targeted.new(session, amount, email_address, user_data).to_s
  end
end
