# frozen_string_literal: true

class SamCsvService
  
  require 'open-uri'
  require 'tempfile'
  require 'google/cloud/storage'
  
  def initialize
    @logger = Logger.new(STDOUT)
    @tempfile = nil
    @bucket_name = ENV.fetch('SAM_CSV_BUCKET_NAME')
  end

  def fetch_csv
    download_csv
    parse_csv
    upload_csv_to_gcs
  end

  private
  def download_csv
    begin
      url = URI.parse('https://sam.gov/api/prod/fileextractservices/v1/api/download/Contract%20Opportunities/datagov/ContractOpportunitiesFullCSV.csv?privacy=Public')
      location = get_redirect_location(url)
      if location
        file = Tempfile.new(['result', '.csv'])
        @tempfile = file;
        @logger.debug '> > > > > > > > > > > > > > > > > > > > > > > > > > > >'
        @logger.debug "File Path #{@tempfile.path}"
        progress = 0
        total_size = 0
        @logger.debug '> > > > > > > > > > > > > > > > > > > > > > > > > > > >'
        @logger.debug "File Download Start"
        URI.open(location, 'rb') do |file|
          File.open(@tempfile.path, 'wb') do |output|
            output.write(file.read)
          end
        end
        file.close
        @logger.debug '> > > > > > > > > > > > > > > > > > > > > > > > > > > >'
        @logger.debug 'File downloaded successfully!'
      else
        @logger.debug '> > > > > > > > > > > > > > > > > > > > > > > > > > > >'
        @logger.debug 'Failed to retrieve file location'
      end
    rescue StandardError => e
      @logger.debug '> > > > > > > > > > > > > > > > > > > > > > > > > > > >'
      @logger.debug "An error occurred: #{e.message}"
    end
  end
  
  def parse_csv
    return unless @tempfile
    @logger.debug '> > > > > > > > > > > > > > > > > > > > > > > > > > > >'
    @logger.debug "Create and Update Database."
    existing_records = SamDotGov.pluck(:notice_id)
    SmarterCSV.process(@tempfile.path, {:chunk_size => 500, :file_encoding => 'ISO-8859-1'}) do |chunk|
      chunk.each do |row|
        notice_id = row[:noticeid]
        if existing_records.include?(notice_id)
          SamDotGov.where(notice_id: notice_id).update_all(
            title: row[:title],
            link: row[:link],
            description: row[:description],
            sol_number: row[:"sol#"],
            sub_tier: row[:sub_tier],
            office: row[:office],
            posted_date: row[:posteddate],
            oppty_type: row[:type],
            base_type: row[:basetype],
            set_aside_code: row[:setasidecode],
            response_deadline: row[:responsedeadline],
            naics_code: row[:naicscode],
            award_date: row[:awarddate],
            award_dollars: row[:"award$"],
            awardee: row[:awardee],
            organization_type: row[:organizationtype]
          )
        else
          SamDotGov.create(
            notice_id: notice_id,
            title: row[:title],
            link: row[:link],
            description: row[:description],
            sol_number: row[:"sol#"],
            sub_tier: row[:sub_tier],
            office: row[:office],
            posted_date: row[:posteddate],
            oppty_type: row[:type],
            base_type: row[:basetype],
            set_aside_code: row[:setasidecode],
            response_deadline: row[:responsedeadline],
            naics_code: row[:naicscode],
            award_date: row[:awarddate],
            award_dollars: row[:"award$"],
            awardee: row[:awardee],
            organization_type: row[:organizationtype]
          )
        end
      end
    end
    @logger.debug '> > > > > > > > > > > > > > > > > > > > > > > > > > > >'
    @logger.debug 'DataBase Updated successfully!'
  end

  def upload_csv_to_gcs
    return unless @tempfile
    @logger.debug '> > > > > > > > > > > > > > > > > > > > > > > > > > > >'
    @logger.debug 'Uploading CSV file to Google Cloud Storage! Please wait!'
  
    # Configure Google Cloud Storage
    storage = Google::Cloud::Storage.new
    bucket = storage.bucket(@bucket_name)

    # Generate a unique file name
    file_name = 'sam-daily-' + Time.now.strftime("%Y-%m-%d_%H-%M-%S") + '.csv'
  
    # Upload the file to Google Cloud Storage
    bucket.create_file(@tempfile.path, file_name).signed_url(version: :v4, method: 'PUT', expires: 600)
    
    @logger.debug 'CSV File Uploaded!'

  end

  def get_redirect_location(url)
    response = Net::HTTP.get_response(url)
    content_size = response['content-length'].to_i
    @logger.debug "response content-length #{content_size}"
    return response['location'] if response.code.to_i == 303
     nil
  end

  def print_download_progress(progress, total_size)
    percent = (progress.to_f / total_size.to_f * 100).to_i
    print "\rDownloading: #{percent}%"
  end
end
