ActiveAdmin.register CrawlResult do
  menu parent: 'Calls-n-crawls'
  actions :all, except: [:new, :edit, :destroy]
  # permit_params :crawl_results, :crawl_name, :target_url, :total_pages, :crawl_id

  index do
    selectable_column
    column :id
    column :crawl
    column :page_title
    column :url
    column :created_at
    actions  
  end
  
  filter :crawl_name
  filter :raw_text
  filter :url
  
  show do
    attributes_table do
      row :id
      row :crawl
      row :page_title
      row :url do
        link_to resource.url, resource.url, target: '_blank'
      end
      row :raw_text
      row :created_at
    end
  end

end
