require 'rubygems'
require 'liquid'
require 'cgi'
require 'uri'

module AtPay
  class Button
    OPTIONS = {
      subject:            'Email Order Form',
      title:              'Pay',
      background_color:   '#6dbe45',
      foreground_color:   '#ffffff',
      image:              'https://www.atpay.com/wp-content/themes/atpay/images/bttn_cart.png',
      processor:          ENV['ATPAY_PAYMENT_ADDRESS'] || 'payment@transaction-l4.atpay.com',
      templates:          File.join(File.dirname(__FILE__), '..', '..', 'assets', 'button', 'templates'),
      analytic_url:       nil,
      wrap:               false,
      wrap_text:          'Made for Mobile'
    }

    def initialize(token, amount, merchant_name, options={})
      @token = token
      @amount = amount
      @merchant_name = merchant_name
      @options = OPTIONS.merge(options)
      @options[:image] = nil if @options[:image] == ''
    end

    def default_mailto
      "mailto:#{@options[:processor]}?subject=#{mailto_subject}&body=#{mailto_body}"
    end

    def render(args={})
      @options.update args

      template.render({
        'url'          => default_mailto,
        'outlook_url'  => outlook_mailto,
        'yahoo_url'    => yahoo_mailto,
        'content'      => amount,
        'dollar'       => amount.match(/\$\d+(?=\.)/).to_s,
        'cents'        => ".#{amount.match(/(?<=\.)[^.]*/).to_s}",
      }.update(string_hash @options))
    end

    private
    def amount
      "$%.2f" % @amount.to_f
    end

    def string_hash(hsh)
      hsh.inject({}) do |result, key|
        result[key[0].to_s] = key[1]
        result
      end
    end

    def provider
      return :default if @options[:email].nil?

      if ["yahoo.com", "ymail.com", "rocketmail.com"].any? { |c| @options[:email].include? c }
        :yahoo
      else
        :default
      end
    end

    def token
      @token.chars.each_slice(50).map(&:join).join("\n")
    end

    def mailto_subject
      URI.encode(@options[:subject])
    end

    def yahoo_mailto
      "http://compose.mail.yahoo.com/?to=#{@options[:processor]}&subject=#{mailto_subject}&body=#{mailto_body}"
    end

    def outlook_mailto
      "https://www.hotmail.com/secure/start?action=compose&to=#{@options[:processor]}&subject=#{mailto_subject}&body=#{mailto_body}"
    end

    # Load the mailto body template from the specified location
    def mailto_body_template
      Liquid::Template.parse(File.read(File.join(@options[:templates], "mailto_body.liquid")))
    end

    # Parse the mailto body, this is where we inject the token, merchant_name and amount values we received in
    # the options.
    #
    # @return [String]
    def mailto_body
      part_a = URI.encode(mailto_body_template.render({
        'amount' => amount,
        'merchant_name' => @merchant_name}))
      part_b = CGI.escape(token)
      part_z = "#{part_a}%0A%0A#{part_b}"
      return part_z
    end

    # This is processed as liquid - in the future we can allow overwriting the
    # template here and creating custom buttons.
    def template
      Liquid::Template.parse(template_content(template_name))
    end

    def template_name
      wrap_prefix = @options[:wrap] ? "wrap_" : ""

      case provider
        when :yahoo
          "#{wrap_prefix}yahoo.liquid"
        when :default
          "#{wrap_prefix}default.liquid"
      end
    end

    # Determine which template to load based on the domain of the email address.
    # This preserves the mailto behavior across email environments.
    def template_content(template_name)
      File.read(File.join(@options[:templates], template_name))
    end
  end
end
