# frozen_string_literal: true

class AssetGeneratorsController < ApplicationController
  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # GET /asset_generators
  def index
    o = Org.find(@current_user.org.id)
    # this to eliminate private generators from the global array
    pri_gen_ids = OrgAssetGenerator.pluck(:asset_generator_id)
    
    private_g = o.private_generators  # the method is scoped active state
    prarr = []
    if private_g
      private_g.each do |g|
        prarr << {scope: 'private', pid: g.pid, name: g.name, card_description: g.card_description, asset_instruction: g.asset_instruction}
      end
    end
    
    ord_g = AssetGenerator.ordered.excluding(private_g)
    ordarr = []
    if ord_g
      ord_g.each do |g|
        ordarr << {scope: 'global', pid: g.pid, display_order: g.display_order, name: g.name, card_description: g.card_description, asset_instruction: g.asset_instruction} unless pri_gen_ids.include? g.id
      end
    end
    
    unord_g = AssetGenerator.unordered.excluding(private_g)
    unordarr = []
    if unord_g
      unord_g.each do |g|
        unordarr << {scope: 'global', pid: g.pid, display_order: g.display_order, name: g.name, card_description: g.card_description, asset_instruction: g.asset_instruction} unless pri_gen_ids.include? g.id
      end
    end
    
    payload = {private_generators: prarr, generators: ordarr + unordarr}
    render json: payload
  end
end
