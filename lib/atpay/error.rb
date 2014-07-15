module AtPay
  # TODO: differentiation on the transaction errors

  class Error                   < RuntimeError; end;
  class FatalError              < Error; end;
  class InvalidSignatureError   < Error; end;
  class TransactionError        < Error; end;
  class ProcessorError          < TransactionError; end;
  class EmailReservedError      < TransactionError; end;
  class EmailNotRegisteredError < TransactionError; end;
  class AddressMismatch         < TransactionError; end;
  class OfferExpiredError       < TransactionError; end;
  class DuplicateTokenError     < TransactionError; end;
  class DuplicateGroupError     < TransactionError; end;
end
