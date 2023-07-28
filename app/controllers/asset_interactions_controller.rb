# frozen_string_literal: true

class AssetInteractionsController < ApplicationController
  include Authentication

  # PUT /asset_interactions/pid
  # {"thumbs": true}
  def update
    ai = AssetInteraction.find_by(pid: params[:id])
    if ai
      ai.update(thumbs: params[:thumbs])
      render json: {pid: ai.pid, thumbs: ai.thumbs}
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  private

    def asset_interactions_params
      params.require(:asset_interaction).permit(:thumbs)
    end

end