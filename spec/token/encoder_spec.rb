require 'spec_helper'
require 'atpay/token/encoder'
require 'pry'

describe AtPay::Token::Encoder do
  let(:partner_id)        { 1 }
  let(:private_key)       { 'DW93ArFKshINPeZOCfYer3riymL+HoRlZj92BNjek+Y=' }
  let(:public_key)        { 'qIcshFT1NEh2JWPEp7+wVV8ibUFHKNew5apbNLGVqgI=' }
  let(:atpay_public_key)  { 'DjnbXwK20VZpir+RLWsrLVwUinAkdeAmvla4M509GXQ=' }
  let(:atpay_private_key) { 'sS70ekGtxHIlzDhcogTECaJyjGJAzHUpVzM/d/M2ixA=' }
 
  let(:session)            { AtPay::Session.new(partner_id, public_key, private_key) }
  let(:version)            { nil }
  let(:amount)             { 20.0 }
  let(:target)             { nil }
  let(:expires_in_seconds) { nil }
  let(:url)                { 'http://example.com/' }
  let(:user_data)          { 'sku-123' }
  let(:email_address)      { 'test@example.com' }

  let(:ip)        { '172.16.0.15' }
  let(:headers)   { { 'HTTP_USER_AGENT' => 'agent', 'HTTP_ACCEPT_LANGUAGE' => 'lang', 'HTTP_ACCEPT_CHARSET' => 'charset'} }

  before do
    # Remove all randomness and constantize current state so we get the same tokens based on our input
    lazy_boxer = double('boxer')
    allow(lazy_boxer).to receive(:box) { |_, data| data }
    allow(RbNaCl::Box).to receive(:new).and_return(lazy_boxer)
    allow(SecureRandom).to receive(:hex).and_return('abc')
    allow(SecureRandom).to receive(:random_bytes).and_return('cba')
    allow(Time).to receive(:now).and_return(0)
  end

  it 'generates an expected token' do
    token = AtPay::Token::Encoder.new(session, version, amount, target, expires_in_seconds, url, user_data)
    expect(token.email).to eq('@Y2JhAAAAAAAAAAF1cmw8aHR0cDovL2V4YW1wbGUuY29tLz5hYmMvQaAAAAAJOoAvc2t1LTEyMw==@')
    expect(token.site(ip, headers)).to eq('@Y2JhAAAAAAAAAAEAAAAoNzliZGUyNjg1MmFmNDFiMjliZTdkMzQ2ZjBlZGMyNjEyNTdlZWFiOAAAAAsxNzIuMTYuMC4xNXVybDxodHRwOi8vZXhhbXBsZS5jb20vPmFiYy9BoAAAAAk6gC9za3UtMTIz@')
  end

  it 'creates a token that expires when we tell it to' do
    token = AtPay::Token::Encoder.new(session, version, amount, target, 5, url, user_data)
    expect(token.email).to eq('@Y2JhAAAAAAAAAAF1cmw8aHR0cDovL2V4YW1wbGUuY29tLz5hYmMvQaAAAAAAAAUvc2t1LTEyMw==@')
    expect(token.site(ip, headers)).to eq('@Y2JhAAAAAAAAAAEAAAAoNzliZGUyNjg1MmFmNDFiMjliZTdkMzQ2ZjBlZGMyNjEyNTdlZWFiOAAAAAsxNzIuMTYuMC4xNXVybDxodHRwOi8vZXhhbXBsZS5jb20vPmFiYy9BoAAAAAAABS9za3UtMTIz@')
  end

  it 'creates a token with a version if given' do
    token = AtPay::Token::Encoder.new(session, 2, amount, target, expires_in_seconds, url, user_data)
    expect(token.email).to eq('@AAAAAAAAAAI=~Y2JhAAAAAAAAAAF1cmw8aHR0cDovL2V4YW1wbGUuY29tLz5hYmMvQaAAAAAJOoAvc2t1LTEyMw==@')
    expect(token.site(ip, headers)).to eq('@AAAAAAAAAAI=~Y2JhAAAAAAAAAAEAAAAoNzliZGUyNjg1MmFmNDFiMjliZTdkMzQ2ZjBlZGMyNjEyNTdlZWFiOAAAAAsxNzIuMTYuMC4xNXVybDxodHRwOi8vZXhhbXBsZS5jb20vPmFiYy9BoAAAAAk6gC9za3UtMTIz@')
  end

  context 'when a target is an EmailAddress' do
    it 'generates a valid one-to-one token' do
      token = AtPay::Token::Encoder.new(session, version, amount, AtPay::EmailAddress.new('John Doe', 'test@example.com'), expires_in_seconds, url, user_data)
      expect(token.email).to eq('@Y2JhAAAAAAAAAAFlbWFpbDx0ZXN0QGV4YW1wbGUuY29tPmFiYy9BoAAAAAk6gC9za3UtMTIz@')
      expect(token.site(ip, headers)).to eq('@Y2JhAAAAAAAAAAEAAAAoNzliZGUyNjg1MmFmNDFiMjliZTdkMzQ2ZjBlZGMyNjEyNTdlZWFiOAAAAAsxNzIuMTYuMC4xNWVtYWlsPHRlc3RAZXhhbXBsZS5jb20-YWJjL0GgAAAACTqAL3NrdS0xMjM=@')
    end
  end  

  context 'when a target is a Card' do
    it 'generates a valid one-to-one token' do
      card = AtPay::Card.new
      card.token = '123'
      token = AtPay::Token::Encoder.new(session, version, amount, card, expires_in_seconds, url, user_data)
      expect(token.email).to eq('@Y2JhAAAAAAAAAAFjYXJkPDEyMz5hYmMvQaAAAAAJOoAvc2t1LTEyMw==@')
      expect(token.site(ip, headers)).to eq('@Y2JhAAAAAAAAAAEAAAAoNzliZGUyNjg1MmFmNDFiMjliZTdkMzQ2ZjBlZGMyNjEyNTdlZWFiOAAAAAsxNzIuMTYuMC4xNWNhcmQ8MTIzPmFiYy9BoAAAAAk6gC9za3UtMTIz@')
    end
  end

  context 'when a target is unspecified' do
    it 'generates a valid one-to-many token' do
      token = AtPay::Token::Encoder.new(session, version, amount, target, expires_in_seconds, url, user_data)
      expect(token.email).to eq('@Y2JhAAAAAAAAAAF1cmw8aHR0cDovL2V4YW1wbGUuY29tLz5hYmMvQaAAAAAJOoAvc2t1LTEyMw==@')
      expect(token.site(ip, headers)).to eq('@Y2JhAAAAAAAAAAEAAAAoNzliZGUyNjg1MmFmNDFiMjliZTdkMzQ2ZjBlZGMyNjEyNTdlZWFiOAAAAAsxNzIuMTYuMC4xNXVybDxodHRwOi8vZXhhbXBsZS5jb20vPmFiYy9BoAAAAAk6gC9za3UtMTIz@')
    end
  end
end
