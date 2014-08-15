begin
  require 'qrencoder'
  require 'rasem'
rescue LoadError
  puts %(WARN: Skipping AtPay::Button::QRCode specs - requires 'qrencoder' and 'rasem')
else
  require 'spec_helper'
  require 'atpay/button'
  require 'atpay/button/qr_code'

  describe AtPay::Button::QRCode do
    subject { described_class.new(button) }
    let(:button) { instance_double('AtPay::Button', :default_mailto => button_content) }
    let(:button_content) { 'abcd' }

    it 'produces a valid png' do
      png     = subject.png
      File.write('tmp.png', png)
      expect(`sips -g all tmp.png`).to match(/pixelWidth:/)
    end

    it 'produces svg data' do
      svg     = subject.svg
      expect(svg).to match(%r{<svg\s})
      expect(svg).to match(%r{</svg>})
    end
  end
end
