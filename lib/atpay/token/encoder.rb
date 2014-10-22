require 'atpay'
require 'rbnacl'
require 'base64'
require 'securerandom'
require 'atpay/email_address'
require 'atpay/card'

module AtPay
  module Token
    class Encoder < Struct.new(:session, :version, :amount, :target, :expires, :url, :user_data, :group)
      def email
        version_and_encode(nonce, partner_frame, body_frame)
      end

      def site(remote_addr, headers)
        version_and_encode(nonce, partner_frame, site_frame(remote_addr, headers), body_frame)
      end

      private
      def version_and_encode(*frames)
        "@#{version_tag}#{Base64.urlsafe_encode64(frames.join)}@"
      ensure
        @nonce = nil
      end

      def version_tag
        version ? (Base64.urlsafe_encode64([version].pack("Q>")) + '~') : nil
      end

      def site_frame(remote_addr, headers)
        message = boxer.box(nonce, Digest::SHA1.hexdigest([
          headers["HTTP_USER_AGENT"],
          headers["HTTP_ACCEPT_LANGUAGE"],
          headers["HTTP_ACCEPT_CHARSET"],
          remote_addr
        ].join))

        [[message.length].pack("l>"), message,
          [remote_addr.length].pack("l>"), remote_addr].join
      end

      def partner_frame
        [session.partner_id].pack("Q>")
      end

      def body_frame
        boxer.box(nonce, crypted_frame)
      end

      def crypted_frame
        unless user_data.blank?
          user_data.force_encoding('ASCII-8BIT')
        end

        [target_tag, options_group, '/', options_frame.force_encoding('ASCII-8BIT'), '/', user_data].flatten.compact.join
      end

      def options_frame
        [amount, expires].pack("g l>")
      end

      def options_group
        ":#{group || SecureRandom.hex(5)}"
      end

      def target_tag
        if target.is_a? EmailAddress
          "email<#{target.address}>"
        elsif target.is_a? Card
          "card<#{target.token}>"
        else
          "url<#{self.url}>"
        end
      end

      def boxer
        RbNaCl::Box.new(session.atpay_public_key, Base64.decode64(session.private_key))
      end

      def nonce
        @nonce ||= SecureRandom.random_bytes(24)
      end
    end
  end
end
