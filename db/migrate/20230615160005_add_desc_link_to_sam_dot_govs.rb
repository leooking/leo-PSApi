class AddDescLinkToSamDotGovs < ActiveRecord::Migration[7.0]
  def change
    add_column :sam_dot_govs, :api_desc_link, :string
  end
end
