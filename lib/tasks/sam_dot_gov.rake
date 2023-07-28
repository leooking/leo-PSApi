namespace :sam do

  desc 'call the sam_dot_gov api'
  task update_sam_dot_gov: :environment do
    ApiCallerService.new().update_sam
  end
  
  desc 'fetch_csv'
  task fetch_csv: :environment do
    SamCsvService.new().fetch_csv
  end

end
