# @Pay Ruby Bindings

@Pay API bindings for Ruby and a full implementation of @Pay's
[**Token Protocol**](http://developer.atpay.com/v3/tokens/protocol/) and **Email Button**
generation system. See the [@Pay Developer Site](http://developer.atpay.com/)
for additional information.

## Installation

  `gem install atpay_ruby`

If you're using Bundler, you can add `atpay_ruby` to your application's Gemfile.

## Configuration

You'll need a **Session** object configured with your API credentials from
from `https://dashboard.atpay.com/` (API Settings):

```ruby
require 'atpay'
ATPAY_SESSION = AtPay::Session.new(partner_id, public_key, private_key)
```

The **Session** is thread-safe and read-only. You can safely use a single instance from
a configuration initializer.

## Web Hook Verification

Configure **Web Hooks** on the [@Pay Merchant Dashboard](https://dashboard.atpay.com)
under "API Settings." Use the **Hook** class to parse incoming requests and
verify the **Hook Request Signature**. Requests with an invalid signature should
be discarded.

`params` is expected to contain the two url-encoded POST variables sent to your
**Web Hook Endpoint** from @Pay's servers. See the [Web Hook Developer
Documentation](http://developer.atpay.com/v3/hooks/) for additional information.

A sample Rails **Web Hook Endpoint**:

```ruby
# app/controllers/transactions_controller.rb
class TransactionsController < ApplicationController
  def create
    hook = AtPay::Hook.new(ATPAY_SESSION, params['details'], params['signature'])
    render text: hook.details.inspect
  rescue AtPay::InvalidSignatureError
    head 403
  end
end

# config/routes.rb
resources :transactions, only: [:create]
```

## Token Overview

A **Token** is a value that contains information about a financial transaction (an invoice
or a product sales offer, for instance). When a **Token** is sent to
`transaction@processor.atpay.com` from an address associated with a **Payment Method**,
it will create a **Transaction**.

There are two classes of **Token** @Pay processes - the **Targeted Token**, which should
be used for sending transactions applicable to a single
recipient, and the **Bulk Token**, which is suitable for email marketing lists.

An **Email Button** is a link embedded in an email message. When activated, this link
opens a new outgoing email with a recipient, subject, and message body
prefilled. By default this email contains one of the two token types. Clicking
'Send' delivers the email to @Pay and triggers **Transaction** processing. The sender will
receive a receipt or further instructions.

## Targeted Tokens

A **targeted** token is ideal for sending invoices or for transactions that are
only applicable to a single recipient (specialized offers, etc).

The following creates a token for a 20 dollar transaction specifically for the
credit card @Pay has associated with 'test@example.com':

```ruby
token = AtPay::Token::Targeted.new(session, 20.00, 'test@example.com')
registration = token.register!

registration.url
=> "https://example.secured.atpay.com/{token_identifier}"

registration.short
=> "atpay://{token_identifier}"

registration.id
=> "{token_identifier}"

registration.qrcode_url
=> "https://dashboard.atpay.com/offers/{token_identifier}.png"
```
Note: **Targeted** tokens used to be known as **Invoice** tokens. Please use **Targeted** tokens, as **Invoice** tokens will be deprecated.


## Bulk Tokens

Most merchants will be fine generating **Bulk Email Buttons** manually on the [@Pay Merchant
Dashboard](https://dashboard.atpay.com), but for cases where you need to
automate the generation of these messages, you can create **Bulk Tokens** without
communicating directly with @Pay's servers.

A **Bulk Token** is designed for large mailing lists. You can send the same token
to any number of recipients. It's ideal for 'deal of the day' type offers, or
general marketing.

To create a **Bulk Token** for a 30 dollar offer:

```ruby
token = AtPay::Token::Bulk.new(session, 30.00)
registration = token.register!
```

If a recipient of this token attempts to purchase the product via email but
hasn't configured a credit card, they'll receive a message asking them to
complete their transaction. You should integrate [@PayJS](http://developer.atpay.com/v3/javascript/)
on that page to enable Customers' two-click email transactions in the future.

## General Token Attributes

These attributes have to be set before calling the register function on the token.

### Auth Only

A **Token** will trigger a funds authorization and a funds capture
simultaneously. If you're shipping a physical good, or for some other reason
want to delay the capture, use the `auth_only!` method to adjust this behavior:

```ruby
token = AtPay::Token::Targeted.new(session, 20.00, 'test@example.com')
token.auth_only!
```

### Expiration

A **Token** expires in 2 weeks unless otherwise specified. Trying to use the **Token**
after the expiration results in a polite error message being sent to the sender.
To adjust the expiration:

```ruby
token = AtPay::Token::Targeted.new(session, 20.00, 'test@example.com')
token.expires_in_seconds = 60 * 60 * 24 * 7 # 1 week
 ```

### Signup Page

When a new Customer or a Customer with expired or invalid credit card details
attempts to purchase from an Email, they will be redirected to a Token's **Payment Capture Page**,
where they can enter new Credit Card details. By default @Pay will host the
**Payment Capture Page**, but you may wish to direct the Customer to a product page on
your own site (Enable @Pay Card tokenization on your own page with the
[@PayJS](http://developer.atpay.com/v3/javascript/)). To specify a custom
URL:

```ruby
token     = AtPay::Token::Targeted.new(session, 20.00, 'test@example.com')
token.url = 'https://example.com/invoices/123'
```

#### Requesting Custom Information on a Hosted Signup Page

If you opt to use the **Hosted Payment Capture Page** (by not specifying a URL above), you
can request further information from your Customer during the purchase on the
Web. For instance, the following requests an optional Gift Message:

```ruby
token     = AtPay::Token::Bulk.new(session, 20.00)
token.request_custom_data!('gift_message', required: false)
```

#### Item Name

You can set an **item name** that will display on the **Hosted Payment Capture Page**.

```ruby
token = AtPay::Token::Targeted.new(session, 20.00, 'test@example.com')
token.name = "A Cool Offer"
 ```

#### Item Details

You can set an **item details** that will display on the **Hosted Payment Capture Page**.


```ruby
token = AtPay::Token::Targeted.new(session, 20.00, 'test@example.com')
token.item_details = "Lorem Ipsum ..."
 ```


#### Address Collection

Request the **Hosted Payment Capture Page** collect any combination
of shipping or billing address with `requires_shipping_address=` and
`requires_billing_address=`:

```
token = AtPay::Token::Targeted.new(session, 20.00, 'test@example.com')
token.requires_shipping_address = true
token.requires_billing_address  = true
```

### Set Item Quantity

If you are using @Pay's webhook for inventory control, you can specify an initial quantity for the offer you are creating.

```ruby
token = AtPay::Token::Targeted.new(session, 20.00, 'test@example.com')
token.item_quantity = 3
 ```


### Fulfillment Time

**Transaction Details** from @Pay may include an **Estimated Fulfillment Time**.
@Pay expects **Auth Only** transactions when fulfillment is required.
A Transaction should be Captured only when fulfillment is completed.

```ruby
token = AtPay::Token::Targeted.new(session, 20.00, 'test@example.com')
token.estimated_fulfillment_days = 3
```

### Custom User Data

**Custom User Data** is a token attribute that contains any string that you wish to get back in @Pay’s
response on processing the token. It has a limit of 2500 characters.

```ruby
token = AtPay::Token::Targeted.new(session, 20.00, 'test@example.com')
token.custom_user_data = 'some-value'
```


## Button Generation

To create a friendly button that wraps your token:

```ruby
token = AtPay::Token::Targeted.new(session, 20.00, 'test@example.com')
registration = token.register!
button = AtPay::Button.new(registration.short, registration.id, 20.00, 'My Company', wrap: true).render
email(button, recipient_address)
```

Default options are [AtPay::Button::OPTIONS](lib/atpay/button.rb).

## QR Code Generation

NOTE: These functions require independent installation of the `qrencoder` and
`rasem` gems.

As an alternative to the standard Button presentation, a QR code can trigger an
outgoing email on a Customer's device. To create a QR code, first create
a button, and then use `AtPay::Button::QRCode`:

```ruby
token  = AtPay::Token::Bulk.new(session, 20.00)
button = AtPay::Button.new(token.to_s, 20.00, 'My Company').render
qr     = AtPay::Button::QRCode.new(button)

File.write("code.png", qr.png)      # Export PNG
File.write("code.svg", qr.svg)      # Export SVG
```

<!-- ## Command Line Usage

The `atpay` utility generates **Targeted Tokens**, **Bulk Tokens**, and **Email Buttons**
that you can embed in outgoing email. Run `atpay help` for more details.

```bash
$ atpay token targeted --partner_id=X --private_key=X --amount=20.55 --target=test@example.com --user-data=sku-123
=> @...@

$ atpay token bulk --partner_id=X --private-key=X --amount=20.55 --url="http://example.com/product"
=> @...@

$ atpay token targeted --partner_id=X --private_key=X --amount=20.55 --target=test@example.com --user-data=sku-123 | atpay button generic --amount=20.55 --merchant="Mom's"
=> <p>...</p>
``` -->
