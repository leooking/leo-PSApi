# frozen_string_literal: true

class InteractionService

  def initialize(args)
    @logger             = Logger.new(STDOUT)
    # @prompt             = args[:prompt]

    @cosine_threshold   = args[:cosine_threshold]         ||= 5
    @use_my_resources   = args[:use_my_resources]         ||= false
    # @use_ext_resources  = args[:use_ext_resources]        ||= false
    @my_resource_count  = args[:number_of_my_resources]   ||= 2
    # @ext_resource_count = args[:number_of_ext_resources]  ||= 2

    @resource_pids      = args[:resource_pids]  ||= []
    
    @ai                 = args[:asset_interaction]
    @g                  = @g = AssetGenerator.find(@ai.asset_generator_id)
    @conn               = Faraday.new(headers: {'Content-Type' => 'application/json'})
    @vex_url            = ENV.fetch('PSCI_VEX_BASE_URL')
    @vex_key            = ENV.fetch('PSCI_VEX_API_KEY')
    @token_factor       = 0.15
    @window_size        = @g.window_size
  end

  def process
    request_my_resources  if @use_my_resources == true #&& @use_ext_resources == false
    # request_ext_resources if @use_ext_resources == true && @use_my_resources  == false
    fetch_result
    log_result
    payload
  end

  private

    # Expected JSON request
    # {cosine_threshold: float, prompt: '', interaction_id: '', org_pid: '', model_code: '', number_of_my_resources: ing}
    # Expected JSON response an array of n objects:
    # [{"resource_data": "string","token_count": 12, "resource_pid": "string","chunk_id":"string"}]
    def request_my_resources
      # 'ad' indicates ada embeddings (1596 dims)
      org_pid = @ai.user.org.pid
      model_code = 'ad'
      collection = "psci-bis-#{@ai.user.org.pid}-ad"
      req = {cosine_threshold: @cosine_threshold, prompt: @ai.prompt, interaction_id: @ai.id, org_pid: org_pid, model_code: model_code, resource_pids: @resource_pids, number_of_my_resources: @my_resource_count}
      url = @vex_url + '/prompt'
      @conn.headers['Authorization'] = "Bearer #{@vex_key}"
      @logger.debug ''
      @logger.debug ''
      @logger.debug 'vex vex vex vex vex vex vex vex vex vex vex vex'
      @logger.debug 'this is req:'
      @logger.debug req
      @logger.debug 'vex vex vex vex vex vex vex vex vex vex vex vex'
      @logger.debug 'this is @vex_res:'
      @logger.debug @vex_res = @conn.post(url,req.to_json).body
      @logger.debug 'vex vex vex vex vex vex vex vex vex vex vex vex'
      @logger.debug ''
      @logger.debug ''
      @vex_res
    end

    # This is tne none found response
    # [{"chunk_id": null, "token_count": 4, "resource_pid": null, "relevant_chunk": "None found."}]
    def provide_resources
      rd = AssetInteraction.find(@ai.id).resource_data
      if rd
        rarr = []
        rd.each do |r|
          rarr << {tokens: r['token_count'], chunk: r['relevant_chunk']}
        end
        # @resources = [{"chunk_id": nil, "token_count": 4, "resource_pid": nil, "relevant_chunk": "None found."}]
        @logger.debug ''
        @logger.debug ''
        @logger.debug 'chunk chunks chunk chunks chunk chunks chunk chunks'
        @logger.debug 'this is @resources:'
        @logger.debug @resources
        @logger.debug 'chunk chunks chunk chunks chunk chunks chunk chunks'
        @logger.debug ''
        @logger.debug ''
        @resources = rarr
      end
    end

    # prune @volleys first then @resources
    def eliminate_overflow
      @logger.debug ''
      @logger.debug ''
      @logger.debug '# # # # # # # # # # # # # # # # # # # # # #'
      @logger.debug 'this is @volleys:'
      @logger.debug @volleys
      @logger.debug '# # # # # # # # # # # # # # # # # # # # # #'
      @logger.debug 'this is @resources:'
      @logger.debug @resources
      @logger.debug '# # # # # # # # # # # # # # # # # # # # # #'
      @logger.debug ''
      @logger.debug ''
      if defined?(@volleys) && defined?(@resources)
        # volleys and resources process both
        loop do
          # NoMethodError (undefined method `+' for nil:NilClass):
          # TypeError (nil can't be coerced into Integer)
          if (@system[:content].length * @token_factor) + (@ai.prompt.length * @token_factor) + (@resources.map{ |r| r[:token_count] }.sum) + (@volleys.map{ |i| i[:token_cost] }.sum) > @window_size
            @volleys = @volleys.shift
            break if @volleys.nil?
          else
            break
          end
        end
      elsif !defined?(@volleys) && defined?(@resources)
        # no volleys process resources only
        loop do
          if (@system[:content].length * @token_factor) + (@ai.prompt.length * @token_factor) + (@resources.map{ |r| r[:token_count] }.sum) > @window_size
            @resources = @resources.shift
          else
            break
          end
        end
      elsif defined?(@volleys) && !defined?(@resources)
        # no resources process volleys only
        loop do
          if (@system[:content].length * @token_factor) + (@ai.prompt.length * @token_factor) + (@volleys.map{ |i| i[:token_cost] }.sum) > @window_size
            @volleys = @volleys.shift
          else
            break
          end
        end
      end
    end
  
  def fetch_result
    case @g.provider

      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      when 'openai.completions.gpt-3.5-turbo-v2'
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

      if @g.generator_type == 'multi'
        @system = {role: 'system', content: @ai.preamble} # attributes already merged
      else
        @system = {role: 'system', content: @g.preamble}  # static preamble
      end

      interactions = AssetInteraction.where(asset_id: @ai.asset.id).order(:created_at)
      @volleys = interactions.map { |i| {token_cost: i.token_cost, prompt: i.prompt, response: i.response} }

      if interactions.count > 1
        # when more than one, remove the last (it's the prompt)
        @volleys.pop
      end

      provide_resources if @use_my_resources == true && !AssetInteraction.find(@ai.id).resource_data.nil?

      # prune @volleys first then @resources
      # NoMethodError (undefined method `nil' for #<Array:0x00007fad5832ebc0>
      @logger.debug ''
      @logger.debug ''
      @logger.debug '# # # # # # # # # # # # # # # # # # # # # #'
      @logger.debug 'this is @volleys:'
      @logger.debug @volleys
      @logger.debug '# # # # # # # # # # # # # # # # # # # # # #'
      @logger.debug 'this is @resources:'
      @logger.debug @resources
      @logger.debug '# # # # # # # # # # # # # # # # # # # # # #'
      @logger.debug ''
      @logger.debug ''
      # eliminate_overflow if !@volleys.blank? && !@resources.blank?

      # put it together and send it off

      if @resources && @use_my_resources == true
        chunks = []
        @resources.each do |r|
          chunks << r['chunk']
        end  


        
        # think about putting a conditional here for with and without resource_data
        # think about putting a conditional here for with and without resource_data
        # think about putting a conditional here for with and without resource_data
        # think about putting a conditional here for with and without resource_data
        # think about putting a conditional here for with and without resource_data



        resource_data = 'Use only this bracketed text to prepare your answer: ' + chunks.to_s + '.  If you cannot do that, respond saying so. Do not fabricate an answer from anything not found within the brackets. Here is my question: '
        @prompt = {role: 'user', content: resource_data + @ai.prompt}
      else
        @prompt = {role: 'user', content: @ai.prompt}
      end

      messages_arr = []
      # Either send system/volleys/prompt or just system/prompt
      if interactions.count == 1 || @g.model_behavior == 'no_prior_interactions'
        messages_arr << @system
        messages_arr << @prompt
      else
        messages_arr << @system
        @volleys.each do |i|
          messages_arr << {role: 'user', content: i[:prompt]}
          messages_arr << {role: 'assistant', content: i[:response]} unless i[:response] == nil
        end  
        messages_arr << @prompt
      end

      req = @g.request_json # store json, return hash
      req['messages'] = messages_arr # an array
      req['max_tokens'] = @g.max_tokens
      req['temperature'] = @g.temperature < 1.0 ? @g.temperature : 0.0

      @logger.debug ''
      @logger.debug ''
      @logger.debug 'q q q q q q q q q q q q q q q q q q q q q q q q'
      @logger.debug 'this is req:'
      @logger.debug req
      @logger.debug 'q q q q q q q q q q q q q q q q q q q q q q q q'
      @logger.debug ''
      @logger.debug ''
      
      @conn.headers['Authorization'] = "Bearer #{ENV.fetch('PSCI_OPENAI_KEY')}"

      @res = @conn.post(@g.endpoint,req.to_json)
      http_status = @res.status
      @ai.update(http_status: http_status)

      body = JSON.parse(@res.body) # a hash

      @logger.debug ''
      @logger.debug ''
      @logger.debug 'x x x x x x x x x x x x x x x x x x x x x x x x'
      @logger.debug 'this is body:'
      @logger.debug body
      @logger.debug 'x x x x x x x x x x x x x x x x x x x x x x x x'
      @logger.debug ''
      @logger.debug ''
      
      if body['choices'] && http_status && http_status == 200
        response = body['choices'][0]['message']['content']
        total_tokens = body['usage']['total_tokens']
        if !response.nil?
          stored_response = response
        else
          stored_response = "Please try again! Error code #{http_status} was returned."
        end
      else # not the expected response structure!
        stored_response = "Please try again! There was an unknown error."
      end

      @ai.response = stored_response
      @ai.token_cost = total_tokens
      @ai.save
      @res


      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      when 'openai.completions.gpt-4'
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

      if @g.generator_type == 'multi'
        @system = @ai.preamble # attributes already merged
      else
        @system = @g.preamble          # static preamble
      end  

      append_system_with_relevant_resources if @use_my_resources == true && !AssetInteraction.find(@ai.id).resource_data.nil?

      interactions = AssetInteraction.where(asset_id: @ai.asset.id).order(:created_at)

      @volleys = interactions.map { |i| {token_cost: i.token_cost, prompt: i.prompt, response: i.response} }
      
      tokens_to_send = (@ai.prompt.length * @token_factor) + (@volleys.map{ |i| i[:token_cost]}.sum)
      if tokens_to_send > (@window_size - @system.length)
        @logger.debug '!  !  !  ! OVERFLOW !  !  !  !'
        prune_volleys
      end
          
      if interactions.count == 1 || @g.model_behavior == 'no_prior_interactions'
        # making sure no prior interactions means what it says on the tin
        if @g.model_behavior == 'no_prior_interactions'
          interactions = interactions.last
        end
        messages_arr = [{role: 'system', content: @system}]
        messages_arr << {role: 'user', content: @ai.prompt}
      else
        # more interactions with system, volleys, prompt
        messages_arr = [{role: 'system', content: @system}]
        @volleys.each do |i|
          messages_arr << {role: 'user', content: i[:prompt]}
          messages_arr << {role: 'assistant', content: i[:response]} unless i[:response] == nil
        end  
      end  
      
      req = @g.request_json # store json, return hash
      req['messages'] = messages_arr # an array
      req['max_tokens'] = @g.max_tokens
      req['temperature'] = @g.temperature < 1.0 ? @g.temperature : 0.0
      
      @conn.headers['Authorization'] = "Bearer #{ENV.fetch('PSCI_OPENAI_KEY')}"

      @res = @conn.post(@g.endpoint,req.to_json)
      http_status = @res.status
      @ai.update(http_status: http_status)

      body = JSON.parse(@res.body) # a hash

      if body['choices'] && http_status && http_status == 200
        response = body['choices'][0]['message']['content']
        total_tokens = body['usage']['total_tokens']
        if !response.nil?
          stored_response = response
        else
          stored_response = "Please try again! Error code #{http_status} was returned."
        end
      else # not the expected response structure!
        stored_response = "Please try again! There was an unknown error."
      end

      @ai.response = stored_response
      @ai.token_cost = total_tokens
      @ai.save
      @res

      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      when 'openai.completions.gpt-3.5-turbo'
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

      # 
      # 
      # Turbo tips
      # From here: https://platform.openai.com/docs/guides/chat/introduction
      # 
      # We can use this for the knowledgebase!
      #   "The assistant messages help store prior responses. They can also be
      #    written by a developer to help give examples of desired behavior."
      # 
      # Also:
      #     Including the conversation history helps when user instructions 
      #     refer to prior messages. In the example above, the user’s final 
      #     question of “Where was it played?” only makes sense in the 
      #     context of the prior messages about the World Series of 2020. 
      #     Because the models have no memory of past requests, all relevant 
      #     information must be supplied via the conversation. If a conversation 
      #     cannot fit within the model’s token limit, it will need to be 
      #     shortened in some way.
      # 

      if @g.generator_type == 'multi'
        @system = @ai.preamble # attributes already merged
      else
        @system = @g.preamble          # static preamble
      end  

      append_system_with_relevant_resources if @use_my_resources == true && !AssetInteraction.find(@ai.id).resource_data.nil?

      interactions = AssetInteraction.where(asset_id: @ai.asset.id).order(:created_at)

      @volleys = interactions.map { |i| {token_cost: i.token_cost, prompt: i.prompt, response: i.response} }
      
      tokens_to_send = (@ai.prompt.length * @token_factor) + (@volleys.map{ |i| i[:token_cost]}.sum)
      if tokens_to_send > (@window_size - (@system.length * @token_factor))
        @logger.debug '!  !  !  ! OVERFLOW !  !  !  !'
        prune_volleys
      end
          
      if interactions.count == 1 || @g.model_behavior == 'no_prior_interactions'
        # making sure no prior interactions means what it says on the tin
        if @g.model_behavior == 'no_prior_interactions'
          interactions = interactions.last
        end
        messages_arr = [{role: 'system', content: @system}]
        messages_arr << {role: 'user', content: @ai.prompt}
      else
        # more interactions with system, volleys, prompt
        messages_arr = [{role: 'system', content: @system}]
        @volleys.each do |i|
          messages_arr << {role: 'user', content: i[:prompt]}
          messages_arr << {role: 'assistant', content: i[:response]} unless i[:response] == nil
        end  
      end  
      
      req = @g.request_json # store json, return hash
      req['messages'] = messages_arr # an array
      req['max_tokens'] = @g.max_tokens
      req['temperature'] = @g.temperature < 1.0 ? @g.temperature : 0.0
      
      @conn.headers['Authorization'] = "Bearer #{ENV.fetch('PSCI_OPENAI_KEY')}"

      @res = @conn.post(@g.endpoint,req.to_json)
      http_status = @res.status
      @ai.update(http_status: http_status)

      body = JSON.parse(@res.body) # a hash

      if body['choices'] && http_status && http_status == 200
        response = body['choices'][0]['message']['content']
        total_tokens = body['usage']['total_tokens']
        if !response.nil?
          stored_response = response
        else
          stored_response = "Please try again! Error code #{http_status} was returned."
        end
      else # not the expected response structure!
        stored_response = "Please try again! There was an unknown error."
      end

      @ai.response = stored_response
      @ai.token_cost = total_tokens
      @ai.save
      @res

      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      when 'openai.completions.text-davinci-003'
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

      # grab the interactions (starts with first prompt with empty response)
      interactions = AssetInteraction.where(asset_id: @ai.asset_id)

      if @g.generator_type == 'multi'   # this means AssetMultiInteractionView.vue
        preamble = @g.dynamic_preamble # this is for the dropdowns
      else
        preamble = @g.preamble          # this is for the generator
      end

      # prepare the prompt based on first or subsequent interactions
      if interactions.count == 1
        prompt = preamble+' '+@ai.prompt+' '+@g.response_trigger
      else
        res_array = interactions.map {|i| {prompt: i.prompt, response: i.response}}
        prompt = res_array.join(' ')+' '+@ai.prompt+'\n'+@g.response_trigger
      end

      # customize their request_json
      req = JSON.parse(@g.request_json)
      req['prompt'] = prompt.rstrip
      req['max_tokens'] = @g.max_tokens
      req['temperature'] = @g.temperature < 1.0 ? @g.temperature : 0.0

      # append the auth header hash
      @conn.headers['Authorization'] = "Bearer #{ENV.fetch('PSCI_OPENAI_KEY')}"

      # make the magic happen and set http_status
      @res = @conn.post(@g.endpoint,req.to_json)
      http_status = @res.status
      @ai.update(http_status: http_status)

      @logger.debug '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
      @logger.debug @res.status.inspect
      @logger.debug '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
      @logger.debug @res.body.inspect
      @logger.debug '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
      
      body = JSON.parse(@res.body) # a hash
      # structure is as expected and we got a 200
      if body['choices'] && http_status && http_status == 200
        response = body['choices'].first['text'].strip
        if !response.nil?
          stored_response = response
        else
          stored_response = "Please try again! Error code #{http_status} was returned."
        end
      else # not the expected response structure!
        stored_response = "Please try again! There was an unknown error."
      end
      
      if http_status && http_status == 200
        if !response.nil?
          stored_response = response
        else
          stored_response = "Please try again! Error code #{http_status} was returned."
        end
      else
        stored_response = "Please try again! There was an unknown error."
      end
      
      @logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      @logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      @logger.debug stored_response
      @logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      @logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      
      # update the interaction
      # @ai.update(response: response)
      @ai.response = stored_response
      @ai.save
      @res

      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # \
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # \
      when 'huggingface.inference.gpt-j-6b'
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # \
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # \

      # grab the interactions (starts with first prompt with empty response)
      interactions = AssetInteraction.where(asset_id: @ai.asset_id)

      if @g.generator_type == 'multi'
        preamble = @g.preamble
      else
        preamble = @g.preamble
      end

      # prepare the prompt based on first or subsequent interactions
      if interactions.count == 1
        prompt = preamble+' '+@ai.prompt+' '+@g.response_trigger
      else
        res_array = interactions.map {|i| {prompt: i.prompt, response: i.response}}
        prompt = res_array.join(' ')+' '+@ai.prompt+'\n'+@g.response_trigger
      end

      # customize their request_json
      req = JSON.parse(@g.request_json)
      req['inputs'] = prompt.rstrip
      @logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      @logger.debug req
      @logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

      # append the auth header hash
      @conn.headers['Authorization'] = "Bearer #{ENV.fetch('HUGGING_ORG_KEY')}"

      # make the magic happen and set http_status
      @res = @conn.post(@g.endpoint,req.to_json)
      http_status = @res.status
      @ai.update(http_status: http_status)

      @logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      @logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      @logger.debug @res.body
      @logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      @logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

      # dig the response from their response and remove whitespace (incl \n)
      response = JSON.parse(@res.body)[0]['generated_text'].strip 

      # update the interaction
      # @ai.update(response: response)
      @ai.response = response
      @ai.save
      @res

      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      when 'api-inference.huggingface.models.facebook.bart-large-cnn'
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

      req_hash = {inputs: @ai.prompt}
      @res = @conn.post(@g.endpoint,req_hash.to_json)
      http_status = @res.status
      response = JSON.parse(@res.body)[0]['summary_text']
      @ai.update(http_status: http_status, response: response)
      @res
      
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
        # when 'cohere.v1.generate'
        when 'cohere.v1.command-xlarge-nightly'
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
        
      interactions = AssetInteraction.where(asset_id: @ai.asset.id).order(:created_at)

      # prepare the prompt based on first or subsequent interactions
      if interactions.count == 1 || @g.model_behavior == 'no_prior_interactions'
        prompt = @g.preamble+' '+@ai.prompt+' '+@g.response_trigger
      else
        res_array = interactions.map {|i| {prompt: i.prompt, response: i.response}}
        prompt = res_array.join(' ')+' '+@ai.prompt+'\n'+@g.response_trigger
      end

      # customize their request_json
      req = @g.request_json
      req['prompt'] = prompt.rstrip
      req['model'] = 'command-xlarge-nightly'
      req['max_tokens'] = @g.max_tokens
      req['truncate'] = "START" # window over flow shortening, removes oldest (START,END,NONE)
      req['temperature'] = @g.temperature < 5.0 ? @g.temperature : 0.0

      # append the auth header hash
      @conn.headers['Authorization'] = "Bearer #{ENV.fetch('COHERE_TRIAL_KEY')}"

      @logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
      @logger.debug 'This is req'
      @logger.debug req
      @logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'

      # make the magic happen and set http_status
      @res = @conn.post(@g.endpoint,req.to_json)
      http_status = @res.status
      @ai.update(http_status: http_status)
      
      body = JSON.parse(@res.body) # a hash

      @logger.debug '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
      @logger.debug 'This is @res.body'
      @logger.debug @res.body
      @logger.debug '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
      
      if body['generations'] #&& http_status && http_status == 200
        @logger.debug '$ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $'
        @logger.debug "This is body['generations'][0]['text']"
        @logger.debug body['generations'][0]['text']
        @logger.debug '$ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $ $'
        response = body['generations'][0]['text']
        # total_tokens = body['usage']['total_tokens']
        if !response.nil?
          stored_response = response
        else
          stored_response = "Please try again! Error code #{http_status} was returned."
        end
      else # not the expected response structure!
        stored_response = "Please try again! There was an unknown error."
      end

      @ai.response = stored_response
      @ai.save
      @res
    
    end # of case statements

  end # of fetch_result method

  # Log it and update the interaction
  def log_result
    @agl = AssetGeneratorLog.create(
      asset_generator_id:   @g.id,
      loggable_id:          @ai.id,
      loggable_type:        @ai.class.name,
      user_id:              @ai.user_id,
      json_response:        @res.body,  # log the raw json
      http_status:          @res.status # log the http_status
    )
  end

  def payload
    @payload = @res.body
  end

  def prune_volleys
    @logger.debug ''
    loop do
      if (@volleys.map{ |i| i[:token_cost] }.sum) > (@window_size - @system.length)
        @volleys.shift
        @logger.debug "    Current sum: #{(@volleys.map{ |i| i[:token_cost] }.sum)}"
      else
        @logger.debug ''
        @logger.debug '!  !  !  !  PRUNED !  !  !  !'
        AssetGeneratorLog.create(
          asset_generator_id:   @g.id,
          loggable_id:          @ai.id,
          loggable_type:        @ai.class.name,
          user_id:              @ai.user_id,
          json_response:        {message: "Trimmed down to #{(@volleys.map{ |i| i[:token_cost] }.sum)} tokens"}
        )
        break
      end
    end
  end

  def append_system_with_relevant_resources
    rd = AssetInteraction.find(@ai.id).resource_data
    # rd = @ai.resource_data
    tokens = rd.map {|d| d['token_count']}.sum
    chunks = rd.map { |d| d['relevant_chunk'] }
    @system = @system + ' relevant_resources: ' + chunks.to_s
    @logger.debug '7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7'
    @logger.debug 'chunk tokens'
    @logger.debug tokens
    @logger.debug '7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7'
    @logger.debug 'system length before'
    @logger.debug @system.length
    @logger.debug '7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7'
    @logger.debug 'chunk string length'
    @logger.debug chunks.to_s.length
    @logger.debug '7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7'
    @logger.debug 'chunk string factored'
    @logger.debug chunks.to_s.length * @token_factor
    @logger.debug '7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7'
    @logger.debug 'System length before'
    @logger.debug @system.length
    @logger.debug '7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7'
  end

end
