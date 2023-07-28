class CreateAssetGenerators < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_generators do |t|
      t.string :name
      t.string :description
      t.string :provider
      t.string :endpoint
      t.string :generator_type
      t.string :state
      t.string :pid,  null: false

      t.timestamps
    end
  end
end
