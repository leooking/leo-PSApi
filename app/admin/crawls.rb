ActiveAdmin.register Crawl do
  menu parent: 'Calls-n-crawls'

  permit_params :state, :scheduling_memo, :crawl_name, :target_url, :max_pages, :max_depth

  index do
    selectable_column
    column :id
    column :pid
    column :crawl_name
    column :target_url do |c|
      link_to c.target_url, c.target_url, target: '_blank'
    end
    column :crawl_results do |c|
      c.crawl_results.count  
    end
    column :max_pages
    column :max_depth
    actions
  end
  
  filter :id
  filter :pid
  filter :crawl_name
  filter :target_url
  filter :scheduling_memo
    
  form do |f|
    f.inputs 'Edit Crawl' do
      f.input :state, as: :select, collection: CRAWL_STATES
      f.input :crawl_name
      f.input :target_url
      f.input :max_pages
      f.input :max_depth
      # f.input :scheduling_memo
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :pid
      row :crawl_name
      row :target_url
      row :max_pages
      row :max_depth
      # row :scheduling_memo
      row :created_at
    end
    panel "Crawl results (#{crawl.crawl_results.count})" do
      table_for crawl.crawl_results do
        column :id do |cr|
          link_to "Crawl id #{cr.id}", psci_staff_crawl_result_path(cr)  
        end
        column :page_title
        column :page_url do |cr|
          link_to cr.url, cr.url, target: '_blank'
        end
        column :page_raw_text_length do |cr|
          if cr.raw_text.nil?
            0
          else
            cr.raw_text.try(:length)
          end
        end
        column :created_at
      end 
    end
  end
end
