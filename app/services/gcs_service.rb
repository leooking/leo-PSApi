# frozen_string_literal: true

# 2023-07-08 08:23:42
# req id 4ca63fad-e9e0-4cf0-8110-5831caffc485
# {
# insertId: "64a97f7e000a36e3167fed9e"
# labels: {1}
# logName: "projects/pscibis-prod/logs/run.googleapis.com%2Fstdout"
# receiveTimestamp: "2023-07-08T15:23:42.907604598Z"
# resource: {2}
# textPayload: "D, [2023-07-08T15:23:42.669304 #1] DEBUG -- : [4ca63fad-e9e0-4cf0-8110-5831caffc485] Sending HTTP get https://storage.googleapis.com/storage/v1/b/psci-bis-psci/o/resources%2Frxkrz%2Fdata_asset%2FMelges-24-class-rules.pdf?"
# timestamp: "2023-07-08T15:23:42.669411Z"
# }
# returned 404

# 291a60ff-ffb6-492c-a2cd-5544f42c2795 last without error   2023-07-07 12:54:32.280 PDT
# prod api deployment                                       2023 2023-07-07 17:20:18 PDT
# 1d76bfa6-035f-4abc-ab4b-4de24d577c1b first with an error  2023-07-07 20:06:33.121 PDT

class GcsService
  require "google/cloud/storage"
  
  def initialize(args)
    @logger           = Logger.new(STDOUT)
    @r                = args[:resource]
    if @r
      @org              = @r.org
    elsif args[:org] 
      @org              = args[:org]
    end
    @tempfile         = args[:tempfile]
    @secondstolive    = args[:secondstolive]

    # Heroku and localhost
    # cred = JSON.parse(File.read(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS')))
    # @storage = Google::Cloud::Storage.new( project: ENV.fetch('GOOGLE_PROJECT_NAME'), credentials: cred )
    
    # Per https://cloud.google.com/ruby/docs/reference/google-cloud-storage/latest/AUTHENTICATION
    # I added secrets with "legal" names as shown on this link
    #     and as instructed, "code is written as if already authenticated"
    #     as seen on line 86 here: google-cloud-storage/.toys/benchmark/perform.rb
    @storage          = Google::Cloud::Storage.new
    # the @org flow is for provisioning orgs, the @r flow is for uploads
    if @org || @r && @r.data_asset && @r.data_asset['bucket_name']
      @bucket_name      = "psci-bis-#{@org.pid}" if @org
      @bucket           = @storage.bucket @r.data_asset['bucket_name'] if @r
      @bucket_file_name = @r.data_asset['bucket_file_name'] if @r
    end
    @conn             = Faraday.new(headers: {'Content-Type' => 'application/json'})
    @vex_url          = ENV.fetch('PSCI_VEX_BASE_URL')
    @vex_key          = ENV.fetch('PSCI_VEX_API_KEY')
  end
  
  def create_bucket
    @storage.create_bucket @bucket_name
    set_cors
  end

  def create_qdrant_collection
    dims = 1536
    # ada embeddings is code "ad
    qdrant_collection = "psci-bis-#{@org.pid}-ad"
    @conn.headers['api-key'] = ENV.fetch('PSCI_QDRANT_API_KEY')
    payload = { 
          name: qdrant_collection,
          shard_number: 2,
          replication_factor: 2,
          write_consistency_factor: 1,
          vectors: { size: dims, distance: "Cosine" } 
        }
    host = ENV.fetch('PSCI_QDRANT_HOST')
    path = "/collections/#{qdrant_collection}"
    url = host + path
    @res = @conn.put(url,payload.to_json)
  end

  def upload
    if @bucket && @tempfile
      @bucket.create_file(@tempfile, @bucket_file_name).signed_url(version: :v4, method: 'PUT', expires: 600) # 10 minutes
      notify_vex_file
    end
  end

  def download_link
    if @bucket.file(@bucket_file_name)
      @bucket.file(@bucket_file_name).signed_url method: "GET", expires: @secondstolive
    end
  end

  # call when deleting a resource in app or admin
  def remove_artifacts
    prune_chunks
    clear_bucket if @r.data_asset
  end

  def add_missing_file_vectors
    notify_vex_file
  end

  def add_missing_url_vectors
    notify_vex_url
  end
  
  private
  
    # POST vex /prune_chunks
    # {"resource_pid": "resource_pid", "qdrant_collection": "qdrant_collection"}
    def prune_chunks
      payload = {
        resource_pid: @r.pid,
        qdrant_collection: "psci-bis-#{@r.org.pid}-ad"
      }
      @logger.debug 'prune vex   prune vex   prune vex   prune vex   prune vex   prune vex'
      @logger.debug 'this is payload'
      @logger.debug payload
      @logger.debug 'prune vex   prune vex   prune vex   prune vex   prune vex   prune vex'
      
      @conn.headers['Authorization'] = "Bearer #{@vex_key}"
      @logger.debug "This is request_payload.to_json:"
      @logger.debug payload.to_json
      @logger.debug 'prune vex   prune vex   prune vex   prune vex   prune vex   prune vex'
      res = @conn.post(@vex_url + '/prune_chunks',payload.to_json)
      @logger.debug "This is @res.body:"
      @logger.debug res.body
      @logger.debug 'prune vex   prune vex   prune vex   prune vex   prune vex   prune vex'
    end
    
    def clear_bucket
      if @bucket.file(@bucket_file_name)
        @logger.debug(@bucket.file(@bucket_file_name).delete) 
      end
    end

    def notify_vex_url
      @logger.debug 'vex url   vex url   vex url   vex url   vex url   vex url   vex url'
      crawl = @r.crawl
      max_pages = crawl ? crawl.max_pages : 1
      max_depth = crawl ? crawl.max_depth : 1
      if crawl
        payload = {
          resource_id: @r.id,
          resource_pid: @r.pid, 
          resource_name: @r.name, 
          target_url: @r.source_url,
          crawl_max_pages: max_pages,
          crawl_max_depth: max_depth,
          crawl_id: crawl.id,
          model_code: 'ad',
          qdrant_collection: "psci-bis-#{@r.org.pid}-ad"
        }
      end

      @logger.debug 'this is @vex_key:'
      @logger.debug @vex_key
      @logger.debug 'vex url   vex url    vex url   vex url    vex url   vex url    vex url   vex url'
      @logger.debug 'this is @vex_url:'
      @logger.debug @vex_url
      @logger.debug 'vex url   vex url    vex url   vex url    vex url   vex url    vex url   vex url'
      @logger.debug 'this is @conn.headers:'
      @conn.headers['Authorization'] = "Bearer #{@vex_key}"
      @logger.debug @conn.headers

      @logger.debug 'vex url   vex url    vex url   vex url    vex url   vex url    vex url   vex url'
      @logger.debug "This is request_payload:"
      @logger.debug payload if payload
      res = @conn.post(@vex_url + '/url',payload.to_json) if payload
      body = JSON.parse(res.body) if res 
      @logger.debug 'vex url   vex url    vex url   vex url    vex url   vex url    vex url   vex url'
      @logger.debug "This is body:"
      @logger.debug body
      @logger.debug 'vex url   vex url    vex url   vex url    vex url   vex url    vex url   vex url'
    end
    
    def notify_vex_file
      @logger.debug 'GCR VEX   GCR VEX   GCR VEX   GCR VEX   GCR VEX'
      @logger.debug 'this is @vex_key:'
      @logger.debug @vex_key
      @logger.debug 'GCR VEX   GCR VEX   GCR VEX   GCR VEX   GCR VEX'
      @logger.debug 'this is @vex_url:'
      @logger.debug @vex_url
      @logger.debug 'GCR VEX   GCR VEX   GCR VEX   GCR VEX   GCR VEX'
      @logger.debug 'this is @conn.headers:'
      @conn.headers['Authorization'] = "Bearer #{@vex_key}"
      @logger.debug @conn.headers
      @logger.debug 'GCR VEX   GCR VEX   GCR VEX   GCR VEX   GCR VEX'
      
      # new
      # {"resource_id": resource_id, "resource_pid": "resource_pid", "model_code": "model_code", "bucket_name": "bucket_name", "file_name": "file_name", "qdrant_collection": "qdrant_collection"}
      if @bucket_name
        payload = {
          resource_id: @r.id, 
          resource_name: @r.name, 
          resource_pid: @r.pid, 
          model_code: 'ad', 
          bucket_name: @bucket_name, 
          file_name: @bucket_file_name,
          qdrant_collection: "psci-bis-#{@r.org.pid}-ad"
        }
      end
      # old
      # payload = {
      #   resource_id: @r.id, 
      #   resource_pid: @r.pid, 
      #   org_pid: @r.org.pid, 
      #   model_code: 'ad', 
      #   bucket_name: @r.data_asset['bucket_name'], 
      #   file_name: @bucket_file_name
      # }
      @logger.debug 'vex file   vex file    vex file   vex file    vex file   vex file    vex file   vex file'
      @logger.debug "This is request_payload.to_json:"
      @logger.debug payload.to_json if payload
      @res = @conn.post(@vex_url + '/file',payload.to_json) if payload
      @logger.debug 'vex file   vex file    vex file   vex file    vex file   vex file    vex file   vex file'
      @logger.debug "This is @res.body:"
      @logger.debug @res.body
      @logger.debug 'vex file   vex file    vex file   vex file    vex file   vex file    vex file   vex file'
    end

    def set_cors
      bucket = @storage.bucket @bucket_name
      bucket.cors do |c|
        c.add_rule ["https://pscibis-staging.web.app", "https://pscibis.com"],
                   ["GET"],
                   headers: [ "Content-Type"],
                   max_age: 3600
      end
    end

end
