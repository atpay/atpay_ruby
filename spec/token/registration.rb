require 'spec_helper'
require 'pry'
require 'atpay/session'
require 'atpay/token/invoice'

describe AtPay::Token::Registration do
  let(:partner_id)        { 1 }
  let(:private_key)       { 'xx5okSjkqJu30biXEFI/y05B68JRCr7ReSdufmtrILY=' }
  let(:public_key)        { 'gOVRRMKRwCHD0nkGiQ1/1EKcSUjO/einHq7MZ/AMkzQ=' }
  let(:atpay_public_key)  { 'x3iJge6NCMx9cYqxoJHmFgUryVyXqCwapGapFURYh18=' }
  let(:atpay_private_key) { '' }

  let(:session)       { AtPay::Session.new(partner_id, public_key, private_key) }
  let(:amount)        { 20.0 }
  let(:email_address) { 'http://example.com/' }
  let(:user_data)     { 'sku-123' }

  it 'registers a token' do
    response = double()
    expect(response).to receive(:body).and_return('{"url":"http://example.com/123","id":"123"}')
    expect(HTTPI).to receive(:post).and_return(response)

    registration = AtPay::Token::Registration.new(session, 'ex-token-123')

    expect(registration.short).to      eq('atpay://123')
    expect(registration.url).to        eq('http://example.com/123')
    expect(registration.qrcode_url).to eq('https://dashboard.atpay.com/offers/123.png')
  end
end
