class UpdateSamGovColumnType < ActiveRecord::Migration[7.0]
  def up
    change_column :sam_dot_govs, :award_dollars, :bigint
  end
  def down
    change_column :sam_dot_govs, :award_dollars, :integer
  end
end
