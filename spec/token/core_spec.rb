require 'spec_helper'
require 'atpay/session'
require 'atpay/token/core'

describe AtPay::Token::Core do
  let(:partner_id)        { 1 }
  let(:private_key)       { 'DW93ArFKshINPeZOCfYer3riymL+HoRlZj92BNjek+Y=' }
  let(:public_key)        { 'qIcshFT1NEh2JWPEp7+wVV8ibUFHKNew5apbNLGVqgI=' }
  let(:atpay_public_key)  { 'DjnbXwK20VZpir+RLWsrLVwUinAkdeAmvla4M509GXQ=' }
  let(:atpay_private_key) { 'sS70ekGtxHIlzDhcogTECaJyjGJAzHUpVzM/d/M2ixA=' }

  let(:session)   { AtPay::Session.new(partner_id, public_key, private_key) }
  let(:amount)    { 20.0 }
  let(:url)       { 'http://example.com/' }
  let(:user_data) { 'sku-123' }

  it 'configures no address by default' do
    token = described_class.new

    expect(token.requires_shipping_address?).to eq(false)
    expect(token.requires_billing_address?).to eq(false)
  end

  it 'configures standalone billing address' do
    token = described_class.new
    token.requires_billing_address = true

    expect(token.requires_billing_address?).to eq(true)
    expect(token.user_data.address).to eq('billing')
  end

  it 'configures standalone shipping address' do
    token = described_class.new
    token.requires_shipping_address = true

    expect(token.requires_shipping_address?).to eq(true)
    expect(token.user_data.address).to eq('shipping')

  end

  it 'configures combined billing and shipping address' do
    token = described_class.new
    token.requires_shipping_address = true
    token.requires_billing_address = true

    expect(token.requires_shipping_address?).to eq(true)
    expect(token.requires_billing_address?).to eq(true)
    expect(token.user_data.address).to eq('shipping,billing')
  end

  it 'allows removing configured billing or shipping address' do
    token = described_class.new
    token.requires_shipping_address = true
    token.requires_billing_address = true

    token.requires_shipping_address = false

    expect(token.requires_shipping_address?).to eq(false)
    expect(token.requires_billing_address?).to eq(true)
    expect(token.user_data.address).to eq('billing')
  end
end
