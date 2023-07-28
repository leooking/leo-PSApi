# frozen_string_literal: true

class HookLog < ApplicationRecord
  belongs_to :org, optional: true
end
