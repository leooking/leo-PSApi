# frozen_string_literal: true

class LlmService

  def initialize(args)
    @logger                 = Logger.new(STDOUT)
    @use_my_resources       = args[:use_my_resources]       ||= false
    @use_ext_resources      = args[:use_ext_resources]      ||= false
    @use_premium_resources  = args[:use_premium_resources]  ||= false
    @resource_pids          = args[:resource_pids]          ||= []
    @shared_resources       = args[:shared_resources]       ||= []
    @cosine_threshold       = args[:cosine_threshold]       ||= 0.75
    @my_resource_count      = args[:number_of_my_resources] ||= 3
    @resource_data          = []
    @volleys                = []
    @ai                     = args[:asset_interaction]
    @a                      = @ai.asset
    @g                      = AssetGenerator.find(@ai.asset_generator_id)
    @window_size            = @g.window_size
    @vex_url                = ENV.fetch('PSCI_VEX_BASE_URL')
    @vex_key                = ENV.fetch('PSCI_VEX_API_KEY')
    @oai_key                = ENV.fetch('PSCI_OPENAI_KEY')
    @azure_oai_key          = ENV.fetch('AZURE_OAI_KEY1')
    @token_factor           = 0.15
    retry_options           = { exceptions: [Faraday::TimeoutError], max: 2, interval: 0.05, interval_randomness: 0.5, backoff_factor: 2 }
    @conn                   = Faraday.new(headers: {'Content-Type' => 'application/json'}) { |f| f.request :retry, retry_options }
    @my_resource_count      = 4 if @g.generator_type == 'ask_shipley'
  end

  def call
    @logger.debug 'use_my  use_my  use_my'
    @logger.debug 'my resources boolean:'
    @logger.debug @use_my_resources
    @logger.debug 'use_my  use_my  use_my'
    @logger.debug 'ext resources boolean:'
    @logger.debug @use_ext_resources
    @logger.debug 'use_my  use_my  use_my'
    @logger.debug 'premium resources boolean:'
    @logger.debug @use_premium_resources
    @logger.debug 'use_my  use_my  use_my'
    grab_resources   if @use_my_resources == true || @use_ext_resources == true  || @use_premium_resources == true
    # smartcheck (smartcheck UI) and intellibid (multi UI) should not use prior volleys (no prior interactions)
    #   in other words, prep_volleys when model behavior is use_prior_interactions
    #   and do not prep_volleys when there should be no prior interactions
    # also do not prep volleys unless > 1
    prep_volleys     if @a.asset_interactions.count > 1 || @g.model_behavior != 'no_prior_interactions'
    process
  end

  private

    def grab_resources
      # 'ad' indicates ada embeddings (1596 dims)
      org_pid = @ai.user.org.pid
      model_code = 'ad'
      if @use_my_resources
        qdrant_collections = ["psci-bis-#{@ai.user.org.pid}-ad"]
      elsif @use_ext_resources
        if @shared_resources == ['sam_dot_gov']
          qdrant_collections = ['sam-gov-opportunities']
        elsif @shared_resources == ['usa_spending']
          qdrant_collections = ['usaspending-gov-notices']
          # elsif @shared_resources == ['far']
          #   qdrant_collections = ['far-pdf']
          # elsif @shared_resources == ['dfar']
          #   qdrant_collections = ['dfars-pdf']
        end
      elsif @use_premium_resources
        # TODO: generalize this. . . it's a shipley hack at the moment
        qdrant_collections = ["psci-bis-#{@ai.user.org.pid}-ad"]
      end
      url = @vex_url + '/prompt'
      @conn.headers['Authorization'] = "Bearer #{@vex_key}"

      @logger.debug ''
      @logger.debug 'vex vex vex vex vex vex vex vex vex vex vex vex'
      @logger.debug 'Specified qdrant collection:'
      @logger.debug qdrant_collections
      @logger.debug 'vex vex vex vex vex vex vex vex vex vex vex vex'
      @logger.debug 'vreq:'
      @logger.debug vreq = {cosine_threshold: @cosine_threshold, prompt: @ai.prompt, interaction_id: @ai.id, model_code: model_code, resource_pids: @resource_pids, number_of_my_resources: @my_resource_count, qdrant_collections: qdrant_collections}
      @logger.debug 'vex vex vex vex vex vex vex vex vex vex vex vex'
      @logger.debug 'vres:'
      @logger.debug vres = @conn.post(url,vreq.to_json).body
      @logger.debug 'vex vex vex vex vex vex vex vex vex vex vex vex'
      @logger.debug ''
      
      if vres && valid_json?(vres)
        vhash = JSON.parse(vres)
        @logger.debug ''
        @logger.debug ''
        @logger.debug 'vhash_ruok   vhash_ruok   vhash_ruok   vhash_ruok   vhash_ruok   vhash_ruok'
        @logger.debug vhash
        @logger.debug 'vhash_ruok   vhash_ruok   vhash_ruok   vhash_ruok   vhash_ruok   vhash_ruok'
        @logger.debug ''
        @logger.debug ''
        if vhash[0].has_key? 'relevant_chunk'
          vhash.each do |r|
            @resource_data << {tokens: r['token_count'], chunk: r['relevant_chunk']} if (r.include? 'token_count') && (r['token_count'] != 0) && (r['relevant_chunk'].length > 20)
          end
        elsif vhash[0].has_key? :payload
          vhash.each do |p|
            @logger.debug 'JKJK++    JKJK++    JKJK++    JKJK++    JKJK++    JKJK++    JKJK++ [ppppp]'
            @logger.debug p
            @logger.debug 'JKJK++    JKJK++    JKJK++    JKJK++    JKJK++    JKJK++    JKJK++'
            @resource_data << {tokens: p['token_count'], chunk: p['payload']} if (p.include? 'token_count') && (p['token_count'] != 0) && (p['payload'].length > 20)
          end
        end
        @logger.debug ''
        @logger.debug ''
        @logger.debug 'resource_data_ruok   resource_data_ruok   resource_data_ruok   resource_data_ruok'
        @logger.debug @resource_data
        @logger.debug 'resource_data_ruok   resource_data_ruok   resource_data_ruok   resource_data_ruok'
        @logger.debug ''
        @logger.debug ''
      end
    end
    
    def prep_volleys
      interactions = AssetInteraction.where(asset_id: @ai.asset.id).order(:created_at)
      interactions.each do |i|
        @volleys << interactions.map { |i| {token_cost: i.token_cost, prompt: i.prompt, response: i.response} }
      end
      @volleys = @volleys.pop # ignore current prompt
    end

    def process
      case @g.provider
      when 'azure.completions.gpt-3.5-turbo-v2'

        if @g.generator_type == 'multi' || @g.generator_type == 'intellibid-2'
          @system = {role: 'system', content: @ai.preamble} # dynamic, already merged
        else
          preamble_to_use = @g.global_preamble_default ? @g.global_preamble_default : @g.preamble
          @system = {role: 'system', content: preamble_to_use}  # static preamble
        end

        # inspired by ../docs/pineccone_preamble.png
        internal_prefix = 'I will provide you with a document and I want you to act as though you are that document and we are chatting. Your name is "PSciAI." \n\nHere is that document: ['
        internal_suffix = '] \n\nRemember, you are that document and we are having a conversation.\nIf that document does not have the answer, say exactly "Sorry, I am not sure." and stop after that.\nNever mention "the document" or "the provided document" in your responses.\nYou must refuse to answer any questions that do not come from that document. Never break character.'

        prefix = @g.resource_instructions_prefix ? @g.resource_instructions_prefix : internal_prefix
        suffix = @g.resource_instructions_suffix ? @g.resource_instructions_suffix : internal_suffix

        @llm_instructions = prefix + @resource_data.map { |r| r[:chunk] }.join(', ') + suffix
        
        prevent_overflow
        
        messages_arr = []
        messages_arr << @system
        if !@volleys.blank?
          @volleys.each do |i|
            messages_arr << {role: 'user', content: i[:prompt]}
            messages_arr << {role: 'assistant', content: i[:response]} unless i[:response] == nil
          end  
        end
        messages_arr << { role: 'user', content: @llm_instructions } unless @resource_data.blank?
        messages_arr << { role: 'user', content: @ai.prompt }

        req = @g.request_json
        req['messages'] = messages_arr
        req['max_tokens'] = @g.max_tokens

        if @use_my_resources
          temp_to_use = @g.global_temp_1st_party ? @g.global_temp_1st_party : @g.temperature
        elsif @use_ext_resources
          temp_to_use = @g.global_temp_3rd_party ? @g.global_temp_3rd_party : @g.temperature
        else
          temp_to_use = @g.temperature ? @g.temperature : 0.5
        end

        req['temperature'] = temp_to_use
  
        @logger.debug ''
        @logger.debug 'req req req req req req req req req req req req req req req'
        @logger.debug req
        @logger.debug 'req req req req req req req req req req req req req req req'
        @logger.debug ''

        # @conn.headers['Authorization'] = "Bearer #{ @oai_key }"
        @conn.headers['api-key'] = @azure_oai_key

        begin

          @res = @conn.post(@g.endpoint,req.to_json)
          body = JSON.parse(@res.body)

          if valid_openai_response?(body) && @res.status && @res.status == 200
            response = body['choices'][0]['message']['content']
            total_tokens = body['usage']['total_tokens']
            if !response.nil?
              stored_response = response
            else
              stored_response = "Error code #{ @res.status } was returned. Please try again!"
            end
          else # not the expected response structure!
            stored_response = "Non-standard response! Please try again!"
          end
  
          @logger.debug ''
          @logger.debug '@res  @res  @res  @res  @res  @res  @res  @res  @res  @res  @res'
          @logger.debug @res
          @logger.debug '@res  @res  @res  @res  @res  @res  @res  @res  @res  @res  @res'
          @logger.debug ''
  
          @logger.debug ''
          @logger.debug 'body body body body body body body body body body body body'
          @logger.debug body
          @logger.debug 'body body body body body body body body body body body body'
          @logger.debug ''
  
        rescue => e # Faraday::TimeoutError
  
          @logger.debug 'rescue    rescue    rescue    rescue    rescue    rescue'
          @logger.debug 'e.inspect:'
          @logger.debug e.inspect
          @logger.debug 'rescue    rescue    rescue    rescue    rescue    rescue'
          @logger.debug 'stored_response:'
          @logger.debug stored_response = 'We are sorry, an error occurred, try again.'
          @logger.debug 'rescue    rescue    rescue    rescue    rescue    rescue'
            
        ensure

          @ai.response = stored_response
          @ai.http_status = @res.status if @res && @res.status
          @ai.token_cost = total_tokens
          @ai.save
  
          log_response

        end

      when 'openai.completions.gpt-3.5-turbo-v2', 'openai.completions.gpt-4-v2'

        if @g.generator_type == 'multi' || @g.generator_type == 'intellibid-2'
          @system = {role: 'system', content: @ai.preamble} # dynamic, already merged
        else
          preamble_to_use = @g.global_preamble_default ? @g.global_preamble_default : @g.preamble
          @system = {role: 'system', content: preamble_to_use}  # static preamble
        end

        # inspired by ../docs/pineccone_preamble.png
        internal_prefix = 'I will provide you with a document and I want you to act as though you are that document and we are chatting. Your name is "PSciAI." \n\nHere is that document: ['
        internal_suffix = '] \n\nRemember, you are that document and we are having a conversation.\nIf that document does not have the answer, say exactly "Sorry, I am not sure." and stop after that.\nNever mention "the document" or "the provided document" in your responses.\nYou must refuse to answer any questions that do not come from that document. Never break character.'

        prefix = @g.resource_instructions_prefix ? @g.resource_instructions_prefix : internal_prefix
        suffix = @g.resource_instructions_suffix ? @g.resource_instructions_suffix : internal_suffix

        @llm_instructions = prefix + @resource_data.map { |r| r[:chunk] }.join(', ') + suffix
        
        prevent_overflow
        
        messages_arr = []
        messages_arr << @system
        if !@volleys.blank?
          @volleys.each do |i|
            messages_arr << {role: 'user', content: i[:prompt]}
            messages_arr << {role: 'assistant', content: i[:response]} unless i[:response] == nil
          end  
        end
        messages_arr << { role: 'user', content: @llm_instructions } unless @resource_data.blank?
        messages_arr << { role: 'user', content: @ai.prompt }

        req = @g.request_json
        req['messages'] = messages_arr
        req['max_tokens'] = @g.max_tokens

        if @use_my_resources
          temp_to_use = @g.global_temp_1st_party ? @g.global_temp_1st_party : @g.temperature
        elsif @use_ext_resources
          temp_to_use = @g.global_temp_3rd_party ? @g.global_temp_3rd_party : @g.temperature
        else
          temp_to_use = @g.temperature ? @g.temperature : 0.5
        end

        req['temperature'] = temp_to_use

  
        @logger.debug ''
        @logger.debug 'req req req req req req req req req req req req req req req'
        @logger.debug req
        @logger.debug 'req req req req req req req req req req req req req req req'
        @logger.debug ''

        @conn.headers['Authorization'] = "Bearer #{ @oai_key }"

        begin

          @res = @conn.post(@g.endpoint,req.to_json)
          body = JSON.parse(@res.body)

          if valid_openai_response?(body) && @res.status && @res.status == 200
            response = body['choices'][0]['message']['content']
            total_tokens = body['usage']['total_tokens']
            if !response.nil?
              stored_response = response
            else
              stored_response = "Error code #{ @res.status } was returned. Please try again!"
            end
          else # not the expected response structure!
            stored_response = "Non-standard response! Please try again!"
          end
  
          @logger.debug ''
          @logger.debug '@res  @res  @res  @res  @res  @res  @res  @res  @res  @res  @res'
          @logger.debug @res
          @logger.debug '@res  @res  @res  @res  @res  @res  @res  @res  @res  @res  @res'
          @logger.debug ''
  
          @logger.debug ''
          @logger.debug 'body body body body body body body body body body body body'
          @logger.debug body
          @logger.debug 'body body body body body body body body body body body body'
          @logger.debug ''
  
        rescue => e # Faraday::TimeoutError
  
          @logger.debug 'rescue    rescue    rescue    rescue    rescue    rescue'
          @logger.debug 'e.inspect:'
          @logger.debug e.inspect
          @logger.debug 'rescue    rescue    rescue    rescue    rescue    rescue'
          @logger.debug 'stored_response:'
          @logger.debug stored_response = 'We are sorry, an error occurred, try again.'
          @logger.debug 'rescue    rescue    rescue    rescue    rescue    rescue'
            
        ensure

          @ai.response = stored_response
          @ai.http_status = @res.status if @res && @res.status
          @ai.token_cost = total_tokens
          @ai.save
  
          log_response

        end
      end
    end  
    
    def prevent_overflow
      completion = @g.max_tokens
      # example response: {"error"=>{"message"=>"This model's maximum context length is 4097 tokens. However, you requested 4517 tokens (2518 in the messages, 1999 in the completion). Please reduce the length of the messages or completion.", "type"=>"invalid_request_error", "param"=>"messages", "code"=>"context_length_exceeded"}}
      base = completion + (@ai.prompt.length * @token_factor) + (@system[:content].length * @token_factor)
      if !@resource_data.blank?
        resources = @llm_instructions.length * @token_factor
      else
        resources = 0
      end
      if !@volleys.blank?
        volleys = (@volleys.map{ |i| i[:token_cost] }.compact.sum)
      else
        volleys = 0
      end
      if resources + volleys + base > @window_size
        # we limit resource size so (resources + base) will always fit
        # we FIFO volleys until it fits
        i = 0
        loop do
          i = i += 1
          @logger.debug '!  !  !  ! OVERFLOW !  !  !  !'
          if (base + resources + (@volleys.map{ |i| i[:token_cost] }.compact.sum)) > @window_size
            overage = (base + resources + (@volleys.map{ |i| i[:token_cost] }.compact.sum)) - @window_size
            @logger.debug "Too big by #{ overage } tokens"
            @volleys.shift
            if @volleys.nil? && !@resource_data.nil?
              @resource_data = @resource_data.pop
              if (base + (@llm_instructions.length * @token_factor) + (@volleys.map{ |i| i[:token_cost] }.compact.sum)) < @window_size
                break
              end
            end
          else
            tokens = (base + resources + (@volleys.map{ |i| i[:token_cost] }.compact.sum))
            @logger.debug "Trimmed down to #{ tokens } tokens"
            AssetGeneratorLog.create(
              asset_generator_id:   @g.id,
              loggable_id:          @ai.id,
              loggable_type:        @ai.class.name,
              user_id:              @ai.user_id,
              json_response:        {message: "Trimmed down to #{ tokens } tokens"}
            )
            break
          end
          break if i >= 10
        end
      end
    end

    def log_response
      if @res && @res.status
        AssetGeneratorLog.create(
          asset_generator_id:   @g.id,
          loggable_id:          @ai.id,
          loggable_type:        @ai.class.name,
          user_id:              @ai.user_id,
          json_response:        @res.body,
          http_status:          @res.status
        )
      end
    end

    def valid_json?(json)
      if JSON.parse(json)
        true
      else
        false
      end
    end

    def valid_openai_response?(body)
      if body['choices']
        true
      else
        false
      end
    end

end
