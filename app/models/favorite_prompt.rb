# frozen_string_literal: true

class FavoritePrompt < ApplicationRecord
  belongs_to :user
  belongs_to :prompt
end
