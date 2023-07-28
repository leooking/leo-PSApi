# frozen_string_literal: true

class ChainsService
  
  def initialize(args)
    @logger                 = Logger.new(STDOUT)
    @ai                     = args[:asset_interaction]
    @use_my_resources       = args[:use_my_resources]       ||= false
    @use_ext_resources      = args[:use_ext_resources]      ||= false
    @use_premium_resources  = args[:use_premium_resources]  ||= false
    @inputs                 = args[:inputs]                 ||= []
    @resource_pids          = args[:resource_pids]          ||= []
    @cosine_threshold       = args[:cosine_threshold]       ||= 0.75
    @my_resource_count      = args[:number_of_my_resources] ||= 3
    @model_code             = 'ad'

    @qdrant_collections     = ["psci-bis-#{@ai.user.org.pid}-ad"]

    @conn                   = Faraday.new(headers: {'Content-Type' => 'application/json'})
    @chains_url             = ENV.fetch('PSCI_CHAINS_URL')
    @chains_key             = ENV.fetch('PSCI_CHAINS_KEY')
  end

  # POST /chat
  def chat
    notify_chains
  end

  private

    # vreq = {cosine_threshold: @cosine_threshold, prompt: @ai.prompt, interaction_id: @ai.id, model_code: model_code, resource_pids: @resource_pids, number_of_my_resources: @my_resource_count, qdrant_collections: qdrant_collections}
    def notify_chains
      req = {
        query: @ai.prompt, 
        constraints: @inputs, 
        action: @ai.action,
        vex_params: {
          use_my_resources: @use_my_resources,
          use_ext_resources: @use_ext_resources,
          use_premium_resources: @use_premium_resources,
          cosine_threshold: @cosine_threshold, 
          prompt: @ai.prompt, 
          interaction_id: @ai.id, 
          model_code: @model_code, 
          resource_pids: @resource_pids, 
          number_of_my_resources: @my_resource_count, 
          qdrant_collections: @qdrant_collections}
      }
      @logger.debug ''
      @logger.debug 'req     req     req     req     req     req     req     req     req'
      @logger.debug @inputs
      @logger.debug 'req     req     req     req     req     req     req     req     req'
      @logger.debug req
      @logger.debug 'req     req     req     req     req     req     req     req     req'
      @logger.debug ''
      @conn.headers['x-api-key'] = @chains_key
      @logger.debug ''
      
      @logger.debug ''
      @logger.debug 'res    res    res    res    res    res    res    res    res    res'
      @logger.debug @res = @conn.post(@chains_url+'/chat',req.to_json)
      @logger.debug 'res    res    res    res    res    res    res    res    res    res'
      @logger.debug ''
      body = JSON.parse(@res.body)
      
      @logger.debug ''
      @logger.debug 'body body body body body body body body body body body body'
      @logger.debug body
      @logger.debug 'body body body body body body body body body body body body'
      @logger.debug ''

      # JSON response
      # {
      #   "query": "what is 2 + 2",
      #   "answer": "4",
      #   "total_tokens": 1234 (an int)
      # }
      @ai.http_status = @res.status if @res.status
      @ai.response    = body['answer'] if body && body['answer']
      @ai.token_cost  = body['total_tokens'] if body && body['total_tokens']
      @ai.save

    end
end
