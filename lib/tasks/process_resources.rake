# 
# Loop all their resources
#   if source_url, POST /url
#   if data_asset, POST /file
# 

@logger = Logger.new(STDOUT)
require "google/cloud/storage"

namespace :send_resources_to_vex do
  desc 'all'
  task all: [:crawls, :uploads]
  
  desc 'send crawls to vex'
  task crawls: :environment do
    crawls = Resource.where.not(source_url: nil)
    type = 'crawl'
    crawls.each do |r|

      begin

        if r.crawl

          vex_url          = ENV.fetch('PSCI_VEX_BASE_URL')
          vex_key          = ENV.fetch('PSCI_VEX_API_KEY')
          conn             = Faraday.new(headers: {'Content-Type' => 'application/json'})
          conn.headers['Authorization'] = "Bearer #{vex_key}"
          crawl            = r.crawl 
  
          max_pages = crawl ? crawl.max_pages : 1
          max_depth = crawl ? crawl.max_depth : 1
          payload = {
            resource_id: r.id,
            resource_pid: r.pid, 
            target_url: r.source_url,
            crawl_max_pages: max_pages,
            crawl_max_depth: max_depth,
            crawl_id: crawl.id,
            model_code: 'ad',
            qdrant_collection: "psci-bis-#{r.org.pid}-ad"
          }
  
          @logger.debug 'init    init    init    init    init    init    init    init    init'
          @logger.debug vex_url ? 'vex_url yes' : 'vex_url no'
          @logger.debug vex_key ? 'vex_key yes' : 'vex_key no'
          @logger.debug conn ? 'conn yes' : 'conn no'
          @logger.debug crawl ? 'crawl yes' : 'crawl no'
          @logger.debug max_pages ? 'max_pages yes' : 'max_pages no'
          @logger.debug max_depth ? 'max_depth yes' : 'max_depth no'
          @logger.debug payload ? 'payload yes' : 'payload no'
          @logger.debug 'init    init    init    init    init    init    init    init    init'
  
          @logger.debug 'vex url   vex url    vex url   vex url    vex url   vex url    vex url   vex url'
          res = conn.post(vex_url + '/url',payload.to_json)
          @logger.debug res ? 'res yes' : 'res no'
          body = JSON.parse(res.body) if res 
          @logger.debug "This is res.body for type #{type} on Resource id #{r.id}:"
          @logger.debug body if body
  
          sleep 4

        else

          @logger.debug 'noop   noop   noop   noop   noop   noop   noop   noop   noop   noop   noop'
          @logger.debug "No crawl association for resource id #{r.id}!"
          break
          
        end

      rescue Exception => e

        @logger.debug 'rescue    rescue    rescue    rescue    rescue    rescue    rescue    rescue    rescue'
        @logger.debug "Failed #{type} type on resource id #{r.id}"
        @logger.debug "Exception: #{e}"
        raise e

      end
    end
  end
  
  desc 'send uploads to vex'
  task uploads: :environment do
    uploads = Resource.where.not(data_asset: nil)
    type = 'upload'
    uploads.each do |r|

      begin

        storage          = Google::Cloud::Storage.new
        bucket_name      = "psci-bis-#{r.org.pid}" if r.org
        bucket           = storage.bucket r.data_asset['bucket_name'] if r
        bucket_file_name = r.data_asset['bucket_file_name'] if r
        conn             = Faraday.new(headers: {'Content-Type' => 'application/json'})
        vex_url          = ENV.fetch('PSCI_VEX_BASE_URL')
        vex_key          = ENV.fetch('PSCI_VEX_API_KEY')

        @logger.debug 'init    init    init    init    init    init    init    init    init'
        @logger.debug storage ? 'storage yes' : 'storage no'
        @logger.debug bucket_name ? 'bucket_name yes' : 'bucket_name no'
        @logger.debug bucket_file_name ? 'bucket_file_name yes' : 'bucket_file_name no'
        @logger.debug conn ? 'conn yes' : 'conn no'
        @logger.debug vex_url ? 'vex_url yes' : 'vex_url no'
        
        conn.headers['Authorization'] = "Bearer #{vex_key}"
        
        payload = {
          resource_id: r.id, 
          resource_pid: r.pid, 
          model_code: 'ad', 
          bucket_name: r.data_asset['bucket_name'], 
          file_name: bucket_file_name,
          qdrant_collection: "psci-bis-#{r.org.pid}-ad"
        }
        @logger.debug payload ? 'payload yes' : 'payload no'
        @logger.debug 'init    init    init    init    init    init    init    init    init'


        res = conn.post(vex_url + '/file',payload.to_json)
        @logger.debug 'vex file   vex file    vex file   vex file    vex file   vex file    vex file   vex file'
        @logger.debug res ? 'res yes' : 'res no'
        @logger.debug "This is res.body for type #{type} on Resource id #{r.id}:"
        @logger.debug res.body if res

        sleep 4

      rescue Exception => e

        @logger.debug 'rescue    rescue    rescue    rescue    rescue    rescue    rescue    rescue    rescue'
        @logger.debug "Failed #{type} type on resource id #{r.id}"
        @logger.debug "Exception: #{e}"
        raise e

      end
    end
  end

end
