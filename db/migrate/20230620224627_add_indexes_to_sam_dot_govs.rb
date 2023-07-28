class AddIndexesToSamDotGovs < ActiveRecord::Migration[7.0]
  def change
    add_index :sam_dot_govs, :posted_date
    add_index :sam_dot_govs, :response_deadline
  end
end
