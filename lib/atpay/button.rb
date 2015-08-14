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
      processor:          ENV['ATPAY_PAYMENT_ADDRESS'] || 'payments.atpay.com',
      templates:          File.join(File.dirname(__FILE__), '..', '..', 'assets', 'button', 'templates'),
      analytic_url:       nil,
      wrap:               false,
      wrap_text:          'Made for Mobile',
      is_non_profit:      false
    }

    def initialize(token, short_token, amount, merchant_name, options={})
      @token            = token
      @short_token      = short_token
      @amount           = amount
      @merchant_name    = merchant_name
      @options          = OPTIONS.merge(options)
      @options[:image]  = nil if @options[:image] == ''
      @is_non_profit    = @options[:is_non_profit]
    end

    def default_mailto
      "mailto:#{mailto_processor}?subject=#{mailto_subject}&body=#{mailto_body}"
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
      if @is_non_profit
        # not sure if that trailing space is significant or not. was in the original version (#mailto_subject), so I kept it.
        URI.encode("Press send to give #{amount} to #{@merchant_name} ")
      else
        URI.encode("Press send to pay #{amount} to #{@merchant_name} ")
      end
    end

    def yahoo_mailto
      "http://compose.mail.yahoo.com/?to=#{mailto_processor}&subject=#{mailto_subject}&body=#{mailto_body}"
    end

    def outlook_mailto
      "https://www.hotmail.com/secure/start?action=compose&to=#{mailto_processor}&subject=#{mailto_subject}&body=#{mailto_body}"
    end

    # Load the mailto body template from the specified location
    def mailto_body_template
      if @is_non_profit
        Liquid::Template.parse(File.read(File.join(@options[:templates], "non_profit_mailto_body.liquid")))
      else 
        Liquid::Template.parse(File.read(File.join(@options[:templates], "mailto_body.liquid")))
      end
    end

    def mailto_processor
      "payment-id-#{@short_token}@#{@options[:processor]}"
    end

    # Parse the mailto body, this is where we inject the token, merchant_name and amount values we received in
    # the options.
    #
    # @return [String]
    def mailto_body
      URI.encode(mailto_body_template.render({
        'amount' => amount,
        'merchant_name' => @merchant_name}))
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
