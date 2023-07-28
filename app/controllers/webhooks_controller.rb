# frozen_string_literal: true

class WebhooksController < ApplicationController
  include Stripe

  before_action :set_stripe_test_api
  # before_action :set_stripe_live_api

  # POST /webhooks/stripe_checkout
  def stripe_checkout
    if params[:type] == 'checkout.session.completed'
    end
    head 200
  end

  # POST /webhooks/stripe_payment_success
  def stripe_payment_success
    HookLog.create(raw_event: params, event_id: params[:id], event_type: params[:type])
  end
  
  # POST /webhooks/stripe_cancel
  # customer.subscription.deleted
  def stripe_cancel
    HookLog.create(raw_event: params, event_id: params[:id], event_type: params[:type])
  end
  
  # POST /webhooks/stripe_payment_failure
  def stripe_payment_failure
    HookLog.create(raw_event: params, event_id: params[:id], event_type: params[:type])
  end
  
  private 

    def set_stripe_test_api
      Stripe.api_key  = ENV['STRIPE_SECRET_TEST']
    end

    def set_stripe_live_api
      Stripe.api_key  = ENV['STRIPE_SECRET_LIVE']
    end

end