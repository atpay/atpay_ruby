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
      processor:          ENV['ATPAY_PAYMENT_ADDRESS'] || 'payments.atpay.com',
      templates:          File.join(File.dirname(__FILE__), '..', '..', 'assets', 'button', 'templates'),
      locale:             :en
    }

    def initialize(token, short_token, amount, merchant_name, options={})
      @token            = token
      @short_token      = short_token
      @amount           = amount
      @merchant_name    = merchant_name
      @options          = OPTIONS.merge(options)
      @options[:image]  = nil if @options[:image] == ''
      @options[:mailto_template] ||= 'pay'
      @mailto_template  = @options[:mailto_template].to_sym
      @locale           = @options[:locale].to_sym
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
        'amount'      => amount
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
      case @mailto_template
      when :donate
        if @locale == :es
          URI.encode("Por favor envíe a dar #{amount} a #{@merchant_name} ")
        else
          # not sure if that trailing space is significant or not. was in the original version (#mailto_subject), so I kept it.
          URI.encode("Send This Message To Complete Your Donation of #{amount} ")
        end
      when :pay
        URI.encode("Send This Message To Complete Your Payment of #{amount} ")
      when :buy
        URI.encode("Send This Message To Complete Your Purchase of #{amount} ")
      when :give
        URI.encode("Send This Message To Complete Your Offering of #{amount} ")
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
      case @mailto_template
      when :donate
        if @locale == :es
          Liquid::Template.parse(File.read(File.join(@options[:templates], "spanish_donate_mailto_body.liquid")))
        else
          Liquid::Template.parse(File.read(File.join(@options[:templates], "donate_mailto_body.liquid")))
        end
      when :pay
        Liquid::Template.parse(File.read(File.join(@options[:templates], "pay_mailto_body.liquid")))
      when :buy
        Liquid::Template.parse(File.read(File.join(@options[:templates], "buy_mailto_body.liquid")))
      when :give
        Liquid::Template.parse(File.read(File.join(@options[:templates], "give_mailto_body.liquid")))
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
      "default.liquid"
    end

    # Determine which template to load based on the domain of the email address.
    # This preserves the mailto behavior across email environments.
    def template_content(template_name)
      File.read(File.join(@options[:templates], template_name))
    end
  end
end
