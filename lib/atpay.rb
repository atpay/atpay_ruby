$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'atpay/session'
require 'atpay/error'
require 'atpay/button'
require 'atpay/token/invoice'
require 'atpay/token/bulk'
require 'atpay/token/targeted'
require 'atpay/hook'
require 'atpay/railtie' if defined?(Rails)
require 'base64'

module AtPay
  PUBLIC_KEY = Base64.decode64(ENV["ATPAY_PUB_KEY"] || ENV["ATPAY_PUBLIC_KEY"] || "QZuSjGhUz2DKEvjule1uRuW+N6vCOoMuR2PgCl57vB0=")
end
