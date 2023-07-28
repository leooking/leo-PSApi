# frozen_string_literal: true

class ApiCallerService
  
  def initialize(args = {})
    @logger             = Logger.new(STDOUT)
    @batch_size         = 1000
    @sam_api_key        = ENV.fetch('SAM_GOV_API_KEY')
    @sam_endpoint       = 'https://api.sam.gov/prod/opportunities/v2/search'
    @conn               = Faraday.new(headers: {'Content-Type' => 'application/json'})
    @newest_date_obj    = SamDotGov.maximum(:posted_date)
    @newest_sam         = @newest_date_obj.strftime('%m/%d/%Y')
    @fetch_sam_from     = (@newest_date_obj + 1.day).strftime('%m/%d/%Y')
    @fetch_sam_to       = Time.now.strftime('%m/%d/%Y')
  end

  def update_sam
    @logger.debug 'sam   sam  sam   sam  sam   sam  sam   sam   sam   sam   sam   sam'
    @logger.debug "We currently have #{SamDotGov.count} opportunities"
    @logger.debug 'sam   sam  sam   sam  sam   sam  sam   sam   sam   sam   sam   sam'
    @logger.debug "Most recent opportunity is #{@newest_sam}"
    start_fetching
  end

  private

    # kicks things off
    def start_fetching
      @first_query = "?api_key=#{@sam_api_key}&limit=#{@batch_size}&offset=0&postedFrom=#{@fetch_sam_from}&postedTo=#{@fetch_sam_to}"
      response = @conn.get(@sam_endpoint+@first_query)
      body = response.body
      http_status = response.status
      hash = HashWithIndifferentAccess.new(JSON.parse(body))
      
      @logger.debug 'sam   sam  sam   sam  sam   sam  sam   sam   sam   sam   sam   sam'
      return @logger.debug '> > > > > > Invalid sam response - waiting for retry < < < < < < <' unless hash[:opportunitiesData]

      # file = File.open("sam_dot_api_200_06-15-23.json")
      # hash = HashWithIndifferentAccess.new(JSON.load(file))

      # get the remaining qty to fetch and build those queries
      qty_recd = hash[:opportunitiesData].length
      total_qty = hash[:totalRecords]
      @logger.debug 'sam   sam  sam   sam  sam   sam  sam   sam   sam   sam   sam   sam'
      @logger.debug "We need to fetch #{total_qty} opportunities"
      @logger.debug 'sam   sam  sam   sam  sam   sam  sam   sam   sam   sam   sam   sam'
      @logger.debug "In batches of #{@batch_size} opportunities per API call"

      query_chunk_builder(qty_recd,total_qty)

      process_batch(hash)

      # call remaining batches
      remaining_batches
    end
    
    # finish things up
    def remaining_batches
      @logger.debug 'sam   sam  sam   sam  sam   sam  sam   sam   sam   sam   sam   sam'
      @logger.debug "There will be #{@query_arr.length} more API calls"
      @query_arr.each do |q|
        response = @conn.get(@sam_endpoint+q)
        body = response.body
        http_status = response.status
        hash = HashWithIndifferentAccess.new(JSON.parse(body))
        process_batch(hash)
        # p q
      end
    end

    # loops and inserts the hash
    def process_batch(hash)
      @logger.debug 'sam   sam  sam   sam  sam   sam  sam   sam   sam   sam   sam   sam'
      @logger.debug "Now processing #{hash[:opportunitiesData].length} opportunities"
      @logger.debug 'sam   sam  sam   sam  sam   sam  sam   sam   sam   sam   sam   sam'
      @logger.debug "SamDotGov contains #{SamDotGov.count} before this batch"
      @logger.debug 'sam   sam  sam   sam  sam   sam  sam   sam   sam   sam   sam   sam'
      oppty_arr = hash[:opportunitiesData]
      oppty_arr.each do |h|
        # desc_link     = h.dig(:description)
        # desc          = @conn.get(desc_link+'&'+@sam_api_key).body
        # desc_hash     = HashWithIndifferentAccess.new(JSON.parse(desc))
        # description:          desc,                                         << url needs an api key
        award_dollars = h.dig(:award,:amount).to_i
        award_date    = h.dig(:award,:date)
        awardee       = h.dig(:award,:awardee,:name)
        fppn          = h.dig(:fullParentPathName) if h.dig(:fullParentPathName)
        sub_tier      = fppn ? fppn.split('.')[1] : nil
        office        = fppn.include?('.') ? fppn.split('.')[2..].join(', ') : nil
        SamDotGov.create(
          notice_id:            h[:noticeId],
          title:                h[:title],
          link:                 h[:uiLink],
          api_desc_link:        h[:description],
          sol_number:           h[:solicitationNumber],
          sub_tier:             sub_tier,
          office:               office,
          posted_date:          h[:postedDate],
          oppty_type:           h[:type],
          base_type:            h[:baseType],
          set_aside_code:       h[:typeOfSetAside],
          response_deadline:    h[:responseDeadLine],
          naics_code:           h[:naicsCode],
          award_date:           award_date,
          award_dollars:        award_dollars,
          awardee:              awardee,
          organization_type:    h[:organizationType]
        )
      end
        @logger.debug "SamDotGov now contains #{SamDotGov.count} opportunities after this batch"
    end  
  
    # query = "?api_key=abc123&limit=1000&offset=0&postedFrom=MM/dd/yyyy&postedTo=MM/dd/yyyy"
    # an array of remaining query strings we can loop through
    def query_chunk_builder(qty_recd,total_qty)
      prototype_query = @first_query
      calls_to_make = ((total_qty-qty_recd) / @batch_size).ceil
      @query_arr = []
      i = @batch_size
      calls_to_make.times do 
        @query_arr << prototype_query.gsub("offset=0","offset=#{i}")
        i = i += @batch_size
      end
      @query_arr
    end
    
end
