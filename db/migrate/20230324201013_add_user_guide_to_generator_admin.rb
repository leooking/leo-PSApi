class AddUserGuideToGeneratorAdmin < ActiveRecord::Migration[7.0]
  def change
    add_column :asset_generators, :user_guide_url, :string
  end
end
