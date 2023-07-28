# frozen_string_literal: true

class StaticController < ApplicationController

  def root
    render json: {message: 'Procurement Sciences API'}
  end

  # GET /psci_echo
  def psci_echo
    render json: {}
  end

end