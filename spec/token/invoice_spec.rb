require 'spec_helper'
require 'atpay/session'
require 'atpay/token/invoice'

describe AtPay::Token::Invoice do
  let(:partner_id)        { 1 }
  let(:private_key)       { 'DW93ArFKshINPeZOCfYer3riymL+HoRlZj92BNjek+Y=' }
  let(:public_key)        { 'qIcshFT1NEh2JWPEp7+wVV8ibUFHKNew5apbNLGVqgI=' }
  let(:atpay_public_key)  { 'DjnbXwK20VZpir+RLWsrLVwUinAkdeAmvla4M509GXQ=' }
  let(:atpay_private_key) { 'sS70ekGtxHIlzDhcogTECaJyjGJAzHUpVzM/d/M2ixA=' }
 
  let(:session)       { AtPay::Session.new(partner_id, public_key, private_key) }
  let(:amount)        { 20.0 }
  let(:email_address) { 'http://example.com/' }
  let(:user_data)     { 'sku-123' }

  it 'creates a new token without exception' do
    token = AtPay::Token::Invoice.new(session, amount, email_address, user_data)
    expect(token.to_s).to match(/\A@.*@\z/)
  end
end
