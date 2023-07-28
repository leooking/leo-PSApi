class AddPreambleToInteractions < ActiveRecord::Migration[7.0]
  def change
    add_column  :asset_interactions, :preamble, :text
  end
end
