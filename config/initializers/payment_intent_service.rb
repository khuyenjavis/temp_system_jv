# frozen_string_literal: true

require 'packages/payment_processor/payment_intent_service'
Rails.application.configure do
  config.payment_intent_service = PaymentProcessor::PaymentIntentService
end
