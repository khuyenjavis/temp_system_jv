# frozen_string_literal: true

require 'stripe'
module PaymentProcessor
  module PaymentIntentService
    def self.create_payment_intent(invoice)
      Stripe::PaymentIntent.create({
                                     amount: invoice.total,
                                     currency: 'jpy',
                                     automatic_payment_methods: { enabled: true },
                                     description: "Invoice #{invoice.id}"
                                   })
    end

    def self.get_payment_intent(invoice)
      Stripe::PaymentIntent.retrieve(invoice.payment_intent_id)
    end
  end
end
