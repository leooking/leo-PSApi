class CreateNaicsCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :naics_codes do |t|
      t.integer :naics_2022_code
      t.string :naics_2022_title

      t.timestamps
    end
  end
end
