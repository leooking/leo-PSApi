class Prompt < ApplicationRecord
  include Pid
  belongs_to :user
  belongs_to :group, optional: true
  belongs_to :org, optional: true
  has_many :favorite_prompts
  has_many :user_stars, through: :favorite_prompts, source: :prompt
end

# Prompt.create(user_id: 1, group_id: 1, org_id: 1, name: 'name', description: 'description', prompt_text: 'prompt_text')