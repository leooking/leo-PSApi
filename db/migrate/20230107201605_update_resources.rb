class UpdateResources < ActiveRecord::Migration[7.0]
  def change
    add_column :resources, :source_url, :string         # nil if uploading
    add_column :resources, :data_asset, :string         # nil if linking, carrierwave uploader
    add_column :resources, :sha256_file, :string        # nil if linking, hash of the uploaded file
    remove_column :resources, :resource_type, :string
    remove_column :resources, :source, :string
    remove_column :resources, :link, :string
    add_index :resources, :sha256_file   # need not be unique assuming different org, group, user
  end                                    # avoid same user uploading same file: idempotency should suffice
end

# {"name": "Early Adopter Playbook", "description": "internal strategy docmuent", "objective": "Close early adopter customers", "source": "PSci fight club", "link": "https://docs.google.com/document/d/1XHDZGoWE_aUnlALBteo8ziNncK4IpR3xONtw9e_WM8I/edit#"}