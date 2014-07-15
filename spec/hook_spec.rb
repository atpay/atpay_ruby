require 'spec_helper'
require 'atpay'
require 'multi_json'
require 'securerandom'

describe AtPay::Hook do
  let(:partner_private_key)       { '1ED8952DAA4B863DA9EECDFBE8F1FA' }
  let(:params)                    { { 'details' => details, 'signature' => signature } }
  let(:details)                   { '{"type":"charge.sale","transaction":"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX","partner":"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX","balance":0.0,"unit_price":50.0,"quantity":1,"date":1373388625,"user":null,"card":"Yjc0YzA1ZDkxZFHbuNyMpQA=","email":"johnsmith@example.com","name":"John Smith","user_data":null,"referrer_context":"my-data-ref-50"}' }
  let(:signature)                 { '28b91cf0482304c6bfe36fc2b84d2c50867a3e05' }

  context 'when the signature is invalid' do
    it 'should raise an exception' do
      session = AtPay::Session.new('', '', '1234BADKEY')

      expect {
        AtPay::Hook.new(session, params)
      }.to raise_error(AtPay::InvalidSignatureError)
    end
  end

  context 'when the signature is valid' do
    it 'make the details available' do
      session = AtPay::Session.new('', '', partner_private_key)
      hook = AtPay::Hook.new(session, params)
      expect(hook.details).to be_a_kind_of(Hash)
    end
  end
end
