require 'spec_helper'
require 'atpay/button'

describe AtPay::Button do
  let(:token) { 'xyz' }
  let(:amount) { 20.00 }
  let(:merchant_name) { 'Toys for Code' }
  let(:yahoo_providers) { %w(test@yahoo.com test@ymail.com test@rocketmail.com) }
  
  it 'renders without exception' do
    button = AtPay::Button.new(token, amount, merchant_name)
    expect(button.render).to_not be_nil
  end
  
  context 'when using a yahoo provider email address' do
    it 'renders the wrap_yahoo template with the wrap' do
      button = AtPay::Button.new(token, amount, merchant_name, wrap:true)
      allow(button).to receive(:provider).and_return(:yahoo)
      expect(button.send(:template_name)).to eq('wrap_yahoo.liquid')
    end

    it 'renders the yahoo template without the wrap' do
      button = AtPay::Button.new(token, amount, merchant_name, wrap:false)
      allow(button).to receive(:provider).and_return(:yahoo)
      expect(button.send(:template_name)).to eq('yahoo.liquid')
    end
  end

  context 'when using a standard email address' do
    it 'renders the wrap_yahoo template with the wrap' do
      button = AtPay::Button.new(token, amount, merchant_name, wrap:true)
      allow(button).to receive(:provider).and_return(:default)
      expect(button.send(:template_name)).to eq('wrap_default.liquid')
    end

    it 'renders the yahoo template without the wrap' do
      button = AtPay::Button.new(token, amount, merchant_name, wrap:false)
      allow(button).to receive(:provider).and_return(:default)
      expect(button.send(:template_name)).to eq('default.liquid')
    end
  end
end
