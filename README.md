# @Pay Ruby Bindings

Ruby implementation of @Pay's *Token Protocol* and *Email Button* generation system.

A **Token** is a value that contains information about a financial transaction (an invoice
or a product sales offer, for instance). When a **Token** is sent to
`transaction@processor.atpay.com` from an address associated with a **Payment Method**, 
it will create a **Transaction**.

There are two classes of **Token** @Pay processes - the **Invoice Token**, which should
be used for sending invoices or transactions applicable to a single
recipient, and the **Bulk Token**, which is suitable for email marketing lists.

A **Button** is a link embedded in an email message. When activated, this link
opens a new outgoing email with a recipient, subject, and message body
prefilled. By default this email contains one of the two token types. Clicking
'Send' delivers the email to @Pay and triggers **Transaction** processing. The sender will
receive a receipt or further instructions.

## Installation

  `gem install atpay_ruby`

If you're using Bundler, you can add `atpay_ruby` to your application's Gemfile.

## Command Line Usage

This SDK ships with two command line utilities - `atpay_button` and
`atpay_token`.

The `atpay_token` utility generates **Invoice Tokens** and **Bulk Tokens**, and the
`atpay_button` utility can be used to wrap those tokens with a simple, easy to
use **Email Button** that you can embed in outgoing emails. Run these commands with
a `--help` flag to get more information on their usage.

```bash
$ atpay token invoice --partner_id=X --private_key=X --amount=20.55 --target=test@example.com --user-data=sku-123
=> @...@

$ atpay token bulk --partner_id=X --private-key=X --amount=20.55 --url="http://example.com/product"
=> @...@

$ atpay token invoice --partner_id=X --private_key=X --amount=20.55 --target=test@example.com --user-data=sku-123 | atpay button generic --amount=20.55 --merchant="Mom's"
=> <p>...</p>
```

## Configuration

All **Token** generation functions require a **Session** object. Just grab
your API credentials from `https://dashboard.atpay.com/` (API Settings):

```ruby
require 'atpay'
session = AtPay::Session.new(partner_id, public_key, private_key)
```

## Invoice Tokens

An **Invoice** token is ideal for sending invoices or for transactions that are
only applicable to a single recipient (shopping cart abandonment, specialized
offers, etc).

The following creates a token for a 20 dollar transaction specifically for the
credit card @Pay has associated with 'test@example.com':

```ruby
token = AtPay::Token::Invoice.new(session, 20.00, 'test@example.com', 'sku-123')
puts token.to_s
```

## Bulk Tokens

Most merchants will be fine generating **Bulk Email Buttons** manually on the [@Pay Merchant
Dashboard](https://dashboard.atpay.com), but for cases where you need to
automate the generation of these messages, you can create **Bulk Tokens** without
communicating directly with @Pay's servers.

A **Bulk Token** is designed for large mailing lists. You can send the same token
to any number of recipients. It's ideal for 'deal of the day' type offers, or
general marketing.

To create a **Bulk Token** for a 30 dollar blender:

```ruby
token = AtPay::Token::Bulk.new(session, 30.00, 'http://example.com/blender-30', 'blender-30')
```

If a recipient of this token attempts to purchase the product via email but
hasn't configured a credit card, they'll receive a message asking them to
complete their transaction at http://example.com/blender-30. You should
integrate the @Pay JS SDK on that page if you want to allow them to create
a two-click email transaction in the future.

## General Token Attributes

### Auth Only

A **Token** will trigger a funds authorization and a funds capture
simultaneously. If you're shipping a physical good, or for some other reason
want to delay the capture, use the `auth_only!` method to adjust this behavior:

```ruby
token = AtPay::Token::Invoice.new(session, 20.00, 'test@example.com', 'sku-123')
token.auth_only!
email(token.to_s)
```

### Expiration

A **Token** expires in 2 weeks unless otherwise specified. Trying to use the **Token**
after the expiration results in a polite error message being sent to the sender.
To adjust the expiration:

```ruby
token = AtPay::Token::Invoice.new(session, 20.00, 'test@example.com', 'sku-123')
token.expires_in_seconds = 60 * 60 * 24 * 7 # 1 week
email(token.to_s, receipient_address)
 ``` 

## Button Generation

To create a friendly button that wraps your token:

```ruby
token = AtPay::Token::Invoice.new(session, 20.00, 'test@example.com', 'sku-123')
button = AtPay::Button.new(token.to_s, 20.00, 'My Company', wrap: true).render
email(button, recipient_address)
```

Default options are [AtPay::Button::OPTIONS](lib/atpay/button.rb).
