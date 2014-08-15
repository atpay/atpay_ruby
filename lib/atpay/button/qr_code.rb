# Note: You'll need qrencoder (https://rubygems.org/gems/qrencoder)
# and rasem (https://rubygems.org/gems/rasem) for this functionality.

require 'qrencoder'
require 'rasem'
require 'cgi'

class AtPay::Button::QRCode
  attr_reader :qr

  def initialize(button)
    content = CGI.unescape(button.default_mailto)
    @qr     = QREncoder.encode(content, correction: :low)
  end

  def png(pixels_per_module=6)
    @qr.png(pixels_per_module: pixels_per_module).to_blob
  end

  def svg
    points = @qr.points
    scale  = 10

    Rasem::SVGImage.new(@qr.width * scale, @qr.height * scale) do
      points.each do |point|
        rectangle point[0] * scale, point[1] * scale, scale, scale
      end
    end.output
  end
end
