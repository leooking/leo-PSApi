# frozen_string_literal: true

class NotesController < ApplicationController
  include Authentication

  before_action :require_api_key
  before_action :require_sign_in

  # PUT /notes/abc123
  # {"text": "Now even more special"}
  def update
    n = Note.find_by(pid: params[:id], user_id: @current_user.id)
    if n
      n.update(note_params)
      created_at = n.created_at ? n.created_at.strftime('%m/%d/%Y') : nil
      payload = {user_pid: n.user.pid, pid: n.pid, text: n.text, created_at: created_at}
      render json: payload, status: 200
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end
  
  # DELETE /notes/abc123
  def destroy
    n = Note.find_by(pid: params[:id], user_id: @current_user.id)
    if n
      n.destroy
      head :ok
    else
      render json: {error: 'Not found.'}, status: 404
    end
  end

  private

    def note_params
      params.permit(:text)
    end

end
