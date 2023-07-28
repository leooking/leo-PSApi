# frozen_string_literal: true

module Pid
  extend ActiveSupport::Concern
  included do

    before_validation(on: :create) do
      update_attribute(:pid, Generator.pid(self))
    end

  end
end
