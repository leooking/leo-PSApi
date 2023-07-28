# frozen_string_literal: true

module VexNotifier
  extend ActiveSupport::Concern
  included do

    def vex_post_url(r)
      conn             = Faraday.new(headers: {'Content-Type' => 'application/json'})
      vex_url          = ENV.fetch('PSCI_VEX_BASE_URL')
      vex_key          = ENV.fetch('PSCI_VEX_API_KEY')
      conn             = Faraday.new(headers: {'Content-Type' => 'application/json'})
      conn.headers['Authorization'] = "Bearer #{vex_key}"
      
      # old
      # payload = {
      #   resource_id: r.id, 
      #   resource_pid: r.pid, 
      #   org_pid: r.org.pid, 
      #   model_code: 'ad',
      #   url: r.source_url
      # }
      # new
      payload = {
        resource_id: r.id,
        resource_pid: r.pid, 
        url: r.source_url,
        model_code: 'ad', 
        qdrant_collection: "psci-bis-#{r.org.pid}-ad"
      }

      logger.debug 'vex url   vex url    vex url   vex url    vex url   vex url    vex url   vex url'
      logger.debug payload
      res = conn.post(vex_url + '/url',payload.to_json)
      logger.debug 'vex url   vex url    vex url   vex url    vex url   vex url    vex url   vex url'
      logger.debug "This is res.body:"
      logger.debug res.body
      logger.debug 'vex url   vex url    vex url   vex url    vex url   vex url    vex url   vex url'
    end
  end
end