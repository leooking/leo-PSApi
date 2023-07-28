class AddAgencyToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :agency, :string
  end
end
