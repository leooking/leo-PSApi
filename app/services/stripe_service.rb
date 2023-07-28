# frozen_string_literal: true

class StripeService

  def initialize(payload)
    @logger         = Logger.new(STDOUT)
    @hash           = hash
    Stripe.api_key  = ENV['STRIPE_SECRET_TEST']
    # Stripe.api_key  = ENV['STRIPE_SECRET_LIVE']
  end

  def checkout
    handle_checkout
  end
  
  def cancel
    handle_cancel
  end
  
  def payment_failure
    handle_payment_failure
  end

  private

  def handle_checkout
  end
  
  def handle_cancel
  end

  def handle_payment_failure
  end
  
end