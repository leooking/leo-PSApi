argon = Argon2::Password.new(secret: ENV['ARGON_KEY'])
u1 = User.create(fname: 'user1',  lname: 'example', email: 'user1@example.com', email_verified: true, password_hash: argon.create('password'))
u2 = User.create(fname: 'user2',  lname: 'example', email: 'user2@example.com', email_verified: true, password_hash: argon.create('password'))
u3 = User.create(fname: 'user3',  lname: 'example', email: 'user3@example.com', email_verified: true, password_hash: argon.create('password'))
# The above need:
# org.users << u1
# group.users << u1

ai = AssetInteraction.all

ai.each do |i|
  i.update(pid: Generator.pid(i))
end

# GCS

require "google/cloud/storage"
data = '/var/folders/jg/_01lx50x3tngs9br0dkmq_mh0000gn/T/tempfile.json20230202-30074-1m5kyel'
storage = Google::Cloud::Storage.new( project_id: ENV.fetch('GOOGLE_PROJECT_NAME'), credentials: File.open(data))

# staging:
data = File.open('../0_gcp/psci-test-01-25f0ccca8643.json').read
enc = Base64.encode64(data)
# write enc to env
data = Base64.decode64(enc)
data.valid_encoding?

file = Tempfile.new('tempfile.json')
file.write(data)
file.close
data = Base64.decode64(enc)
tmp << 
t.write() # => 9
IO.read t.path # => ""
t.rewind
IO.read t.path # => "Test datatest data"

data = '/var/folders/jg/_01lx50x3tngs9br0dkmq_mh0000gn/T/tempfile.json20230202-30074-1m5kyel'

# file > encode > env > decode > tempfile

==== Add users ====

users = [
  {org_pid: '', group_pid: '', fname: '', lname: '', email: ''},
]

users = [
  {org_pid: 'eboud', group_pid: 'r31', fname: 'Steven', lname: 'Pergament', email: 'spergament1@yahoo.com'}, 
  {org_pid: 'j0v8b', group_pid: 'jwe', fname: 'David', lname: 'Balser', email: 'dbalser@intracoastalstrategies.com'}, 
  {org_pid: 'h4w7a', group_pid: 'td8pj', fname: 'Tony', lname: 'Lawrence', email: 'tony@louannlawrence.com'}, 
  {org_pid: 'a4yi', group_pid: 'wkw', fname: 'Abby', lname: 'Mackness', email: 'amackness0506@gmail.com'}, 
  {org_pid: 'gdj', group_pid: 'hjn', fname: 'Cole', lname: 'Bruns', email: 'Colebruns30@gmail.com'}, 
  {org_pid: '2neha', group_pid: 'cu2x', fname: 'Christopher', lname: 'McNair', email: 'cbmcnair@magnusdiagnosticslabs.com'}, 
  {org_pid: 'c0v1', group_pid: 'im7w', fname: 'Tony', lname: 'Riggs', email: 'triggs@triggsgroup.com'}, 
]

def add_users(users)
  users.each do |u|
    o = Org.find_by(pid: u[:org_pid])
    g = Group.find_by(pid: u[:group_pid])
    u = User.create(fname: u[:fname], lname: u[:lname], email: u[:email])
    o.users << u
    g.users << u
  end
end

add_users(users)

# minimum viable project
p = Project.create(name: 'qwer', objective: 'qwer', user_id: 1, org_id: 1, group_id: 1)

# minimum viable asset
a = Asset.create(name: 'qwer', objective: 'qwer', user_id: 1, project_id: 4, asset_generator_id: 3)

# davinci to turbo
  # Three roles:
  #   system    == preamble + data
  #   user      == prompt
  #   assistant == res
  # 
  # Append volleys to messages hash, until full, retain system:
  #   
  #   system
  #   user        q1    volley1
  #   assistant   a1    volley1
  #   user        q2
  #   assistant   a2
  #   user        q3
  #   assistant   a3
  # 
  #   (FIFO volleys)
  # 
  # curl https://api.openai.com/v1/chat/completions \
  #  -H "Authorization: Bearer $OPENAI_API_KEY" \
  #  -H "Content-Type: application/json" \
  #  -d '{
  #  "model": "gpt-3.5-turbo",
  #  "messages": [{"role": "user", "content": "What is the OpenAI mission?"}] 
  #  }'

  # req = {
  #   model: "gpt-3.5-turbo",
  #   messages: [
  #     {role: "system", content: "I am a <noun>. You are a <noun>. Here is my first question:"},
  #     {role: "user", content: "prompt"}
  #   ]
  # }

  # res_body = {
  #   model: "gpt-3.5-turbo",
  #   usage: {prompt_tokens: 56, completion_tokens: 31, total_tokens: 87},
  #   choices: [
  #     message: {
  #       role: "assistant",
  #       content: "this is my final answer"
  #     }
  #   ]
  # }

  # openai.ChatCompletion.create(
  #   model="gpt-3.5-turbo",
  #   messages=[
  #         {"role": "system", "content": "You are a helpful assistant."},
  #         {"role": "user", "content": "Who won the world series in 2020?"},
  #         {"role": "assistant", "content": "The Los Angeles Dodgers won the World Series in 2020."},
  #         {"role": "user", "content": "Where was it played?"}
  #     ]
  # )

  # turbo response
  {
  id: 'chatcmpl-6p9XYPYSTTRi0xEviKjjilqrWU2Ve',
  object: 'chat.completion',
  created: 1677649420,
  model: 'gpt-3.5-turbo',
  usage: {prompt_tokens: 56, completion_tokens: 31, total_tokens: 87},
  choices: [
    {
      message: {
        role: 'assistant',
        content: 'The 2020 World Series was played in Arlington, Texas at the Globe Life Field, which was the new home stadium for the Texas Rangers.'},
      finish_reason: 'stop',
      index: 0
    }
    ]
  }

  # cohere generate request
  {"max_tokens": 20,"return_likelihoods": "NONE","truncate": "END", "prompt": "Once upon a time in a magical land called"}

  # cohere generate response
  {
    "id": "28e60682-cfb1-44ff-aed9-31b617e78be0",
    "generations": [
      {
        "id": "5cd002d5-be02-4dbf-8a5b-3b9390eedeef",
        "text": " the Internet, there was a website called Thingiverse. Thingiverse was a wonderful place where you could"
      }
    ],
    "prompt": "Once upon a time in a magical land called",
    "meta": {
      "api_version": {
        "version": "1"
      }
    }
  }
  

03/28/23
19:
prod_org_pids = ["c0v1", "jyte9", "gdj", "a4yi", "h4w7a", "eboud", "dwfo", "j0v8b", "psci", "2neha", "cal", "1mgrm", "7itwz", "nt3", "xcws", "lw6t", "ng0", "vxi", "fyw"]
pids = ["fyw", "vxi", "nt3", "ng0", "lw6t", "xcws", "7itwz", "cal", "1mgrm", "dwfo", "jyte9", "c0v1", "2neha", "gdj", "a4yi", "h4w7a", "j0v8b", "eboud", "psci"]
9:
prod_pids_to_add = ["c0v1", "jyte9", "gdj", "fyw", "a4yi", "h4w7a", "eboud", "j0v8b", "psci", "2neha"]
prod_orgs_to_fix = ["General Dynamics Information Technology", "Riggs Group", "Skymantics", "MKS2", "Mackness and Poore Consulting Services", "Lawrence Consulting Services", "Pergament Consulting", "Intracoastal Strategies Consulting", "PSci", "Magnus Diagnostics Labs"]

prod_pids_to_add.each do |p|
  o = Org.find_by(pid: p)
  if o
    GcsService.new(org: o).create_qdrant_collection
    p "+++++++ Added #{o.name} collection"
    sleep(1)
  else
    p ">>>>>>>>> #{p} pid not found"
    sleep(1)
  end
end


# prod after fix
["psci-bis-nt3-ad", "psci-bis-a4yi-ad", "psci-bis-lw6t-ad", "psci-bis-eboud-ad", "psci-bis-2neha-ad", "psci-bis-gdj-ad", "psci-bis-h4w7a-ad", "psci-bis-1mgrm-ad", "psci-bis-dwfo-ad", "psci-bis-ng0-ad", "psci-bis-7itwz-ad", "psci-bis-c0v1-ad", "psci-bis-jyte9-ad", "psci-bis-j0v8b-ad", "psci-bis-psci-ad", "psci-bis-cal-ad", "psci-bis-vxi-ad", "psci-bis-xcws-ad"]
# prod before the fix
["psci-bis-dwfo-ad", "psci-bis-nt3-ad", "psci-bis-vxi-ad", "psci-bis-lw6t-ad", "psci-bis-cal-ad", "psci-bis-xcws-ad", "psci-bis-1mgrm-ad", "psci-bis-ng0-ad", "psci-bis-7itwz-ad"]

# prod_collections
["psci-bis-nt3-ad", "psci-bis-a4yi-ad", "psci-bis-lw6t-ad", "psci-bis-eboud-ad", "psci-bis-2neha-ad", "psci-bis-gdj-ad", "psci-bis-h4w7a-ad", "psci-bis-1mgrm-ad", "psci-bis-dwfo-ad", "psci-bis-ng0-ad", "psci-bis-7itwz-ad", "psci-bis-c0v1-ad", "psci-bis-jyte9-ad", "psci-bis-j0v8b-ad", "psci-bis-psci-ad", "psci-bis-cal-ad", "psci-bis-vxi-ad", "psci-bis-xcws-ad"]
["psci-bis-nt3-ad", "psci-bis-a4yi-ad", "psci-bis-lw6t-ad", "psci-bis-eboud-ad", "psci-bis-2neha-ad", "psci-bis-gdj-ad", "psci-bis-h4w7a-ad", "psci-bis-1mgrm-ad", "psci-bis-dwfo-ad", "psci-bis-ng0-ad", "psci-bis-7itwz-ad", "psci-bis-c0v1-ad", "psci-bis-jyte9-ad", "psci-bis-j0v8b-ad", "psci-bis-psci-ad", "psci-bis-cal-ad", "psci-bis-vxi-ad", "psci-bis-xcws-ad"]



coll_19 = ["1mgrm", "2neha", "7itwz", "a4yi", "c0v1", "cal", "dwfo", "eboud", "fyw", "gdj", "h4w7a", "j0v8b", "jyte9", "lw6t", "ng0", "nt3", "psci", "vxi", "xcws"]
org_19  = ["1mgrm", "2neha", "7itwz", "a4yi", "c0v1", "cal", "dwfo", "eboud", "fyw", "gdj", "h4w7a", "j0v8b", "jyte9", "lw6t", "ng0", "nt3", "psci", "vxi", "xcws"]

stag_pids_to_fix = ["iqwed", "gzhl2"]
# ==== remediation ===
pids_to_fix = ["2neha", "a4yi", "c0v1", "eboud", "fyw", "gdj", "h4w7a", "j0v8b", "jyte9", "psci"]
collections_to_create = ["p9v", "6mgbd"]

pids_to_fix.each do |p|
  o = Org.find_by(pid: p)
  if o
    res = o.resources
    if res
      res.each do |r|
        if r && r.data_asset.present?
          GcsService.new(resource: r).add_missing_vectors
          sleep(9)
        end
      end
    else
      p 'THIS ORG HAS NO RESOURCES'
    end
  else
    p "#{p} IS A BAD ORG PID!"
  end
end

collections_to_create = ["p9v", "6mgbd"]
collections_to_create.each do |p|
  o = Org.find_by(pid: p)
  if o
    GcsService.new(org: o).create_qdrant_collection
    sleep(5)
  else
    p 'WHOA, NOT FOUND'
  end
end

# ==== hero api with GCPG ====
# 1) set a custom environment in database.yml and /environments
# 2) call -e to set the environment 
#     i.e. heroku run rails c -e hero_pg_stag -a psci-stag-api

# ==== qdrant migration scripts ====

# 1) create collections for each org
orgs = Org.all
orgs.each do |o|
  if o
    GcsService.new(org: o).create_qdrant_collection
    sleep(5)
    p '>>>>>>>>>>>> OKAY <<<<<<<<<<<<'
  else
    p 'WHOA, NOT FOUND'
  end
end

# 2) feed all uploads one by one to vex POST /file

# https://stackoverflow.com/questions/65635612/automatically-load-dotenv-on-my-ruby-console/65636532#65636532
require 'dotenv'
Dotenv.load('.env')

# prod_collections_to_skip = %w[dfars-pdf usaspending-gov-notices sam-gov-opportunities far-pdf]
skip_list = %w[dfars-pdf my_collection usaspending-gov-notices sam-gov-opportunities far-pdf]
orgs = Org.all
orgs.each do |o|
  collection_name = "psci-bis-#{o.pid}-ad"
  if skip_list.include? collection_name
    break
  else
    p ">>>>>>>>> #{o.name} <<<<<<<<<"
    if o.resources

      resources = o.resources.where.not(data_asset: nil)
      resources.each do |r|
        if !r.data_asset.blank?
          p "+++++++++ #{r.pid} +++++++++"
          GcsService.new(resource: r).add_missing_file_vectors
          sleep(1)
        end
      end
      
      resources = o.resources.where.not(source_url: nil)
      resources.each do |r|
        p "+++++++++ #{r.pid} +++++++++"
        GcsService.new(resource: r).add_missing_url_vectors
        sleep(1)
      end
      
    end
  end
end

foo = Resource.where.not(data_asset: nil)
foo.each do |r|
  r.data_asset unless 
end



# https://github.com/andreibondarev/qdrant-ruby 
require 'qdrant'

client = Qdrant::Client.new(
  url: ENV.fetch('PSCI_QDRANT_HOST'),
  api_key: ENV.fetch('PSCI_QDRANT_API_KEY')
)

client.collections.cluster_info(
    collection_name: "psci-bis-psci-ad" # required
)

foo = ["c0v1", "jyte9", "gdj", "a4yi", "h4w7a", "eboud", "dwfo", "j0v8b", "psci", "2neha", "cal", "1mgrm", "7itwz", "nt3", "xcws", "lw6t", "ng0", "vxi", "fyw", "p9v", "6mgbd", "iow", "9awba"]

# self hosted to hosted qdrant emergency switchover:
# 1) create hosted cluster
#   curl \
#       -X GET 'https://90cd7c96-8bb7-4b9b-9846-c5ccde719e3c.us-east-1-0.aws.cloud.qdrant.io:6333' \
#       --header 'api-key: erU_om4DwL1kR4J97k2pyqIfEJC57f3EDr5NTJP_9QjWCdUpcboEGA'
# 2) create prod secrets HOSTED_PSCI_QDRANT_HOST & HOSTED_PSCI_QDRANT_API_KEY
# 3) create collections for each org
# 
# 
# 
# https://stackoverflow.com/questions/65635612/automatically-load-dotenv-on-my-ruby-console/65636532#65636532
require 'dotenv'
Dotenv.load('.env')

# insure all orgs have a collection
# https://github.com/andreibondarev/qdrant-ruby
require 'qdrant'
q = Qdrant::Client.new(url: ENV.fetch('PSCI_QDRANT_HOST'),api_key: ENV.fetch('PSCI_QDRANT_API_KEY'))
orgs = Org.all
orgs.each do |o|
  c = "psci-bis-#{o.pid}-ad"
  res = q.collections.get(collection_name: c)
  if res['result'].nil?
    # collection missing!
    GcsService.new(org: o).create_qdrant_collection
    p '++++++++++ Collection created ++++++++++'
    sleep(2)
  else
    # collection exists
    p '>>>>>>>>>> Collection found <<<<<<<<<<'
  end
end

# insure all orgs have a storage bucket
require 'dotenv'
Dotenv.load('.env')

require 'google/cloud/storage'
cred = JSON.parse(File.read(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS')))
s = Google::Cloud::Storage.new( project: ENV.fetch('GOOGLE_PROJECT_NAME'), credentials: cred )
orgs = Org.all
orgs.each do |o|
  b = "psci-bis-#{o.pid}"
  bucket = s.bucket(b) ? s.bucket(b) : nil
  if bucket.nil?
    GcsService.new(org: o).create_bucket
    p '++++++++++ Bucket created ++++++++++'
    sleep 2
  else
    p '>>>>>>>>>> Bucket found <<<<<<<<<<'
  end
end

# ==== backfill storage bucket cors ====

# hack .env for stag & prod
# export GCP_PG='postgres://...' # because rails c inits before local dotenv
# rails c -e hero_api_gcpg
require 'dotenv'
Dotenv.load('.env')

require 'google/cloud/storage'
cred = JSON.parse(File.read(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS')))
s = Google::Cloud::Storage.new( project: ENV.fetch('GOOGLE_PROJECT_NAME'), credentials: cred )
orgs = Org.all
orgs.each do |o|
  foo = Org.find_by(pid: o.pid) # hack to fix crazy 403 error when no bucket exists for a missing o.pid
  if foo
    b = "psci-bis-#{o.pid}"
    bucket = s.bucket b
    if bucket
      bucket.cors do |c|
        # c.add_rule ["https://pscibis-staging.web.app", "https://pscibis.com", "http://localhost:4000"],
        c.add_rule ["https://psci-stag-app-8c52a.web.app", "https://pscibis.com", "http://localhost:4000"],
                  ["GET"],
                  headers: [ "Content-Type"],
                  max_age: 3600
      end
    end
  end
end

# ==== chains_service ====

  # POST /chat/add-detail
  # POST /chat/respond
  # POST /chat/suggestions
  # POST /chat/explain
  # {"query": "what was highlighted", "action": "suggestions", "constraints": {"industry": "sailboats", "sentiment": "confident"}, "context": [{"JK says": "still unsure what context is!"}]}
  # "query": "" # the text that was highlighted
  # "constraints": {
  #   "industry": "",
  #   "company": "",
  #   "agency": "",
  #   "type": "",
  #   "length": "",
  #   "custom_words": "",
  #   "sentiment": "",
  #   "key_words": "",
  # }

  # <select>
  #   <option value="respond">Generate Requirement Response</option>
  #   <option value="explain">Explain This Requirement</option>
  #   <option value="suggestions">Tips & Suggestions for this Requirement</option>
  #   <option value="summarize">Create Agency Strategic Analysis</option>
  #   <option value="add-detail">Make this text more detailed and informative</option>
  # </select>

  # POST /chat
  # action is one of ["summarize", "add-detail", "respond", "suggestions", "explain"]
  # {
  #   "query": "what was highlighted",          # required
  #   "action": "suggestions",                  # required
  #   "constraints": {
  #     "industry": "sailboats",
  #     "sentiment": "confident"
  #   },
  #   "vex_params": [{
  #     "JK says": "still unsure what context is!"
  #   }]
  # }

  # vex_params: [
    # vex_params = {cosine_threshold: @cosine_threshold, prompt: @ai.prompt, interaction_id: @ai.id, model_code: @model_code, resource_pids: @resource_pids, number_of_my_resources: @my_resource_count, qdrant_collections: qdrant_collections}
  ]

  # JSON response
  # {
  #   "query": "what is 2 + 2",
  #   "answer": "4"
  # }

# https://psci-stag-api-zcfe4iexva-uc.a.run.app/psci_staff
# https://psci-prod-api-kuvr57zz5a-uc.a.run.app/psci_staff

# ==== FAR && DFARS 3rd party hack ====
# export GCP_PG='postgres://...' # because rails c inits before local dotenv
# rails c -e hero_api_gcpg
# require 'dotenv'
# Dotenv.load('.env')

far = Org.create(name: 'delete-me', url: 'https://example.com', email_domain: 'far.com')
dfars = Org.create(name: 'delete-me', url: 'https://example.com', email_domain: 'dfars.com')

far_g = Group.create(name: 'default', org_id: far.id)
dfars_g = Group.create(name: 'default', org_id: dfars.id)

argon = Argon2::Password.new(secret: ENV['ARGON_KEY'])

far_u = User.create(fname: 'far', lname: 'User1', email: 'far@example.com', password_hash: argon.create('password'))
dfars_u = User.create(fname: 'dfars', lname: 'User1', email: 'dfars@example.com', password_hash: argon.create('password'))

far.users << far_u
far_g.users << far_u

dfars.users << dfars_u
dfars_g.users << dfars_u



far2 = Org.create(name: 'delete-me2', url: 'https://example.com', email_domain: 'far.com')
dfars2 = Org.create(name: 'delete-me2', url: 'https://example.com', email_domain: 'dfars.com')

far_g2 = Group.create(name: 'default', org_id: far2.id)
dfars_g2 = Group.create(name: 'default', org_id: dfars2.id)

argon = Argon2::Password.new(secret: ENV['ARGON_KEY'])

far_u2 = User.create(fname: 'far', lname: 'User1', email: 'far2@example.com', password_hash: argon.create('password'))
dfars_u2 = User.create(fname: 'dfars', lname: 'User1', email: 'dfars2@example.com', password_hash: argon.create('password'))

far2.users << far_u2
far_g2.users << far_u2

dfars2.users << dfars_u2
dfars_g2.users << dfars_u2

export GCP_PG='postgres://...' # because rails c inits before local dotenv
rails c -e hero_api_gcpg
require 'dotenv'
Dotenv.load('.env')

foo.each do |g|
  g.provider = 'azure.completions.gpt-3.5-turbo-v2'
  sleep 1
  g.endpoint = 'https://psci-bis.openai.azure.com/openai/deployments/psci-api-35-turbo/chat/completions?api-version=2023-03-15-preview'
  sleep 1
  g.request_json = {"messages"=>[{"role"=>"system", "content"=>"You are a helpful assistant."}, {"role"=>"user", "content"=>"Does Azure OpenAI support customer managed keys?"}, {"role"=>"assistant", "content"=>"Yes, customer managed keys are supported by Azure OpenAI."}, {"role"=>"user", "content"=>"Do other Azure Cognitive Services support this too?"}]}
  sleep 1
  g.sample_response = {"id"=>"chatcmpl-7F7NOqc9Re4WdMXwCRI25X4anxTyl", "model"=>"gpt-35-turbo", "usage"=>{"total_tokens"=>119, "prompt_tokens"=>59, "completion_tokens"=>60}, "object"=>"chat.completion", "choices"=>[{"index"=>0, "message"=>{"role"=>"assistant", "content"=>"Yes, other Azure Cognitive Services also support customer managed keys. When you create a Cognitive Service resource in Azure, you can choose to use a customer-managed key stored in Azure Key Vault. This provides you with the ability to better control access to your Cognitive Services resources and manage your own encryption keys."}, "finish_reason"=>"stop"}], "created"=>1683837630}
  sleep 1
  g.save
end

# ==== generator attribute update

# changes
# global_preamble_default replaces preamble
# global_preamble_default = preamble
# hard coded prefix/suffix into generators
prefix = 'I will provide you with a document and I want you to act as though you are that document and we are chatting. Your name is "PSciAI." \n\nHere is that document: ['
suffix = '] \n\nRemember, you are that document and we are having a conversation.\nIf that document does not have the answer, say exactly "Sorry, I am not sure." and stop after that.\nNever mention "the document" or "the provided document" in your responses.\nYou must refuse to answer any questions that do not come from that document. Never break character.'
foo = AssetGenerator.all
foo.each do |g|
  g.global_preamble_default = g.preamble if g.preamble
  g.resource_instructions_prefix = prefix
  g.resource_instructions_suffix = suffix
  g.global_temp_1st_party = g.temperature
  g.global_temp_3rd_party = g.temperature
  g.global_preamble_1st_party = g.preamble
  g.global_preamble_3rd_party = g.preamble
  g.custom_preambles_3rd_party = { "sam_dot_gov_preamble": "A am a preamble for sam_dot_gov", "usa_spending_preamble": "A am a preamble for usa_spending" }
  g.custom_temps_3rd_party = { "sam_dot_gov_temp": 0.5, "usa_spending_temp": 0.5 }
  g.action_specific_preambles = {"generate_new_prompt": "Concisely and exhaustively evaluate the following text and respond to the requirements within:", "add_detail_prompt": "You've been tasked with extending the text given to you. Make it more detailed informative and descriptive. Respond to the following:", "summary_prompt": "Please summarize the following:", "explain_prompt": "Explain this as if talking to a 10th grader:", "make_suggestions_prompt": "Take this requirement, give me tips and suggestions how to respond and be in compliance, return in list format:" }
  g.save
end 

# conditionals
# temperature varies based on if toggles are off vs on

# new
# custom temps for 1st & 3rd party resources

# not used yet
# action specific preambles
  
# ==== shipley
stag_collection = 'psci-bis-pb44-ad'
prod_collection = 'psci-bis-vapl-ad'
#     capture pid was 2td
#     proposal pid was raqi
# stag resource.id 345
data_asset = {"sha"=>"39e844b5ad3f3687d8ebdd38566c53cb840f3a637539138d0e077a52d51c1145", "bytes"=>23029471, "filename"=>"Shipley Capture Guide.pdf", "utc_epoch"=>1684347095, "bucket_name"=>"psci-bis-pb44", "content_type"=>"application/pdf", "bucket_file_name"=>"resources/shipley_capture_guide/data_asset/Shipley Capture Guide.pdf"}
# stag resource.id 346
data_asset = {"sha"=>"afb0d21c8ee1806c192a978daf0f08ff5841df989d52e10d1dcd07a2e0c4a82f", "bytes"=>113848, "filename"=>"Shipley Proposal Guide.pdf", "utc_epoch"=>1684350459, "bucket_name"=>"psci-bis-pb44", "content_type"=>"application/pdf", "bucket_file_name"=>"resources/shipley_proposal_guide/data_asset/Shipley Proposal Guide.pdf"}
# prod resource.id 169 (capture)
data_asset = {"sha"=>"39e844b5ad3f3687d8ebdd38566c53cb840f3a637539138d0e077a52d51c1145", "bytes"=>23029471, "filename"=>"Shipley Capture Guide.pdf", "utc_epoch"=>1684362179, "bucket_name"=>"psci-bis-vapl", "content_type"=>"application/pdf", "bucket_file_name"=>"resources/shipley_capture_guide/data_asset/Shipley Capture Guide.pdf"}
# prod resource.id 170 (proposal)
data_asset = {"sha"=>"afb0d21c8ee1806c192a978daf0f08ff5841df989d52e10d1dcd07a2e0c4a82f", "bytes"=>113848, "filename"=>"Shipley Proposal Guide.pdf", "utc_epoch"=>1684362367, "bucket_name"=>"psci-bis-vapl", "content_type"=>"application/pdf", "bucket_file_name"=>"resources/shipley_proposal_guide/data_asset/Shipley Proposal Guide.pdf"}


# 0) premium_resources = true
#     Parameters: {"prompt"=>"3rd neither checked", "resource_pids"=>[], "use_my_resources"=>false, "use_ext_resources"=>false, "use_premium_resources"=>true, "id"=>"z75s", "assetz"=>{"prompt"=>"3rd neither checked", "resource_pids"=>[], "use_my_resources"=>false, "use_ext_resources"=>false, "use_premium_resources"=>true}}
#         Issue: told vex to query ["psci-bis-pb44-ad"]
#         Issue: odd chunks! 
#             [{"cosine_similarity":0.7571839,"qdrant_id":"81a91b78-799b-4e3d-a928-ebae7f130f39","relevant_chunk":". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 130\nTeaming . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .","resource_pid":"f1gd","token_count":103},{"cosine_similarity":0.7571839,"qdrant_id":"a1064736-bb9c-4a76-97f1-338d6538f2f4","relevant_chunk":". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 130\nTeaming . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .","resource_pid":"hw78o","token_count":103},{"cosine_similarity":0.7571839,"qdrant_id":"722eb004-b1b0-4869-9df3-1b1e912f0fb9","relevant_chunk":". . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 130\nTeaming . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .","resource_pid":"qqwb","token_count":103}]
# 1) neither checked, empty pid array
# 2) One checked, pid properly sent
# 

export GCP_PG='postgres://...' # because rails c inits before local dotenv
rails c -e hero_api_gcpg
require 'dotenv'
Dotenv.load('.env')

g = AssetGenerator.create(
  name: 'azure winmore', 
  provider: 'azure.completions.gpt-3.5-turbo-v2',
  endpoint: 'https://psci-bis.openai.azure.com/openai/deployments/psci-api-35-turbo/chat/completions?api-version=2023-03-15-preview',
  request_json: '{"messages"=>[{"role"=>"system", "content"=>"You are a helpful assistant."}, {"role"=>"user", "content"=>"Does Azure OpenAI support customer managed keys?"}, {"role"=>"assistant", "content"=>"Yes, customer managed keys are supported by Azure OpenAI."}, {"role"=>"user", "content"=>"Do other Azure Cognitive Services support this too?"}]}',
  sample_response: 	'{"id"=>"chatcmpl-7F7NOqc9Re4WdMXwCRI25X4anxTyl", "model"=>"gpt-35-turbo", "usage"=>{"total_tokens"=>119, "prompt_tokens"=>59, "completion_tokens"=>60}, "object"=>"chat.completion", "choices"=>[{"index"=>0, "message"=>{"role"=>"assistant", "content"=>"Yes, other Azure Cognitive Services also support customer managed keys. When you create a Cognitive Service resource in Azure, you can choose to use a customer-managed key stored in Azure Key Vault. This provides you with the ability to better control access to your Cognitive Services resources and manage your own encryption keys."}, "finish_reason"=>"stop"}], "created"=>1683837630}',
  preamble: 'You are PSciAI, your job is answering questions for a user.\n',
  generator_type: 'convo',
  state: 'active',
  model_behavior: 'use_prior_interactions',
  resumable: true,
  my_resources_visible: true,
  ext_resources_visible: true,
  window_size: 4096,
  max_tokens: 500,
  temperature: 0.25
)

# ==== jail break assets ====
# 1) loop a collection thus:
# 2) remove the fk binding
# 3) AssetFolder.create(asset_id: a.id, folder_id: f.id)
assets = Asset.where.not(project_id: nil)
assets.each do |a|
  pid = a.project_id
  AssetProject.create(asset_id: a.id, project_id: pid)
  # a.project_id = nil
end

# Phase 2: make project_id nil
assets.update_all(project_id: nil)
# prolly optional

export GCP_PG='postgres://...' # because rails c inits before local dotenv
rails c -e hero_api_gcpg
require 'dotenv'
Dotenv.load('.env')

# Naics
file = '/Users/jk/Documents/companies/psci/data/naics_2022_6_digit.csv'
options = {chunk_size: 100}
sam = SmarterCSV.process(file, options) do |chunk|
  NaicsCode.create(chunk)
end


# sam
# "notice_id","title","sol_number","agency","CGAC","sub_tier","fpds_code","office","aac_code","posted_date","oppty_type","base_type","archive_type","archive_date","set_aside_code","set_aside","response_deadline","naics_code","classification_code","pop_street_address","pop_city","pop_state","pop_zip","pop_country","active","award_number","award_date","award_dollars","awardee","primary_contact_title","primary_contact_fullname","primary_contact_email","primary_contact_phone","primary_contact_fax","secondary_contact_title","secondary_contact_fullname","secondary_contact_email","secondary_contact_phone","secondary_contact_fax","organization_type","state","city","zip_code","country_code","additional_info_link","link","description"
# "NoticeId","Title","Sol#","Department/Ind.Agency","CGAC","Sub-Tier","FPDS Code","Office","AAC Code","PostedDate","Type","BaseType","ArchiveType","ArchiveDate","SetASideCode","SetASide","ResponseDeadLine","NaicsCode","ClassificationCode","PopStreetAddress","PopCity","PopState","PopZip","PopCountry","Active","AwardNumber","AwardDate","Award$","Awardee","PrimaryContactTitle","PrimaryContactFullname","PrimaryContactEmail","PrimaryContactPhone","PrimaryContactFax","SecondaryContactTitle","SecondaryContactFullname","SecondaryContactEmail","SecondaryContactPhone","SecondaryContactFax","OrganizationType","State","City","ZipCode","CountryCode","AdditionalInfoLink","Link","Description"

# CSV Refresh workflow
#   fetch new csv
#   switch to our headers
#   process the file
#   carefully purge the priors, i.e. SamDotGov.where(created_at: 10.days.ago..3.days.ago).delete_all
# 

# CSV source: https://sam.gov/data-services/Contract%20Opportunities/datagov
file = '/Users/jk/Documents/companies/psci/data/opportunities_our_headers_23-06-07.csv' 
# contains 179879
options = {chunk_size: 100, verbose: false}

file = '/Users/jk/Documents/companies/psci/data/opportunities_our_headers_23-06-16.csv' 
# contains 179908
options = {chunk_size: 200, verbose: false}
notices = SamDotGov.pluck(:notice_id)

sam = SmarterCSV.process(file, options) do |chunk|
  SamDotGov.create(chunk) #unless notices.include? chunk.map { |o| o[:notice_id] }
end

SamDotGov.maximum(:posted_date)

# dedupe after a new intake:
#   (whatever date range is right)
#   (required order is newer..older). . . really? U sure?
SamDotGov.where(created_at: 10.days.ago..3.days.ago)#.delete_all
SamDotGov.where(created_at: 60.days.ago..3.days.ago)#.delete_all
# The recent ones:
SamDotGov.where(created_at: 2.days.ago..Time.now).count

# sam csv != sam api
#   api is multi-dimensional with different names
# 
# The daily CSV
# https://sam.gov/data-services/Contract%20Opportunities/datagov?privacy=Public
# 
# There is no curl-able url
# 
# csv workflow
#   1. download
#   2. swap header row
#   3. clip desired rows
#   4. inhale
# 

# flatten a multi-dimensional hash (JSON)
# https://stackoverflow.com/questions/31566789/cant-flatten-json-array-to-prepare-for-csv-conversion-using-ruby-2-1-4
require 'csv'code 
require 'json'

def hflat(h)
  h.values.flat_map {|v| v.is_a?(Hash) ? hflat(v) : v }
end

CSV.open('file.csv', 'w') do |csv|
  JSON.parse(File.open('sam_api_response_sample.json').read).each do |h| 
    csv << hflat(h)
  end
end

# agencies
file = '/Users/jk/Documents/companies/psci/data/agencies/agencies2.csv'
file = '/Users/jk/Documents/companies/psci/data/agencies/agencies3.csv'
options = {chunk_size: 100, verbose: true}
agencies = SmarterCSV.process(file, options) do |chunk|
  Agency.create(chunk)
end

export GCP_PG='postgres://...' # because rails c inits before local dotenv
rails c -e hero_api_gcpg
require 'dotenv'
Dotenv.load('.env')

# prototype data structure
crawl_data_structure = {
  source_url: 'a string',
  pages_crawled: 2,
  crawl_results: [
    {page_title: 'a string', page_url: 'a string', extracted_text: 'more string'},
    {page_title: 'a string', page_url: 'a string', extracted_text: 'more string'}
  ]
}


export GCP_PG='postgres://...' # because rails c inits before local dotenv
rails c -e hero_api_gcpg
require 'dotenv'
Dotenv.load('.env')

# # # # # # # groups # # # # # # #
# # # # # # # groups # # # # # # #
# # # # # # # groups # # # # # # #

# user has many group memberships but only one at a time can be active

# 1) New user provisioned as an active member of a group (g.members << u default true)
# 2) add that user to a second group (create GroupUser record)
#   a) make all groups inactive
#   b) make new group active              <<<<<< at this point, GroupUser.count will > User.count
# 3) move user is activate_in_group (which will create or update)
# 

# change user.group_id to group_users
User.all.each do |u|
  u.activate_in_group u.group # refactored the method to group vs group_id
end
#   1) loop users and create group_users.active: true
#   2) added private method user.activate_in_group
#   3) refactored user.group to return active group
#   4) modified session
#   5) modified customer add user (customer provisioning)
#   6) modified csv_service (admin provisioning)

# prod forensics
#   189 users but only 27 GroupUser records
#     9 are false: [493, 494, 495, 496, 497, 500, 501, 504, 505]
#     18 are true: [506, 507, 508, 509, 510, 511, 512, 513, 514, 502, 425, 422, 431, 499, 419, 428, 503, 516]
#   This is probably fine, but there User.count should == GroupUser.count WHEN none are in multiple groups
# 

objects = %w[asset folder project prompt resource]

# collections
g.assets # inner join
g.folders # inner join
g.projects # inner join
g.prompts # group_id fk       << OK?
g.resources # inner join

Group org_id
Prompt group_id # optional
Project group_id

Asset :has_many :through :asset_groups
Folder

# relevant join tables
group_orgs
asset_groups
group_projects
group_resources
group_users
org_resources
folder_groups
asset_users

require 'dotenv'
Dotenv.load('.env')

# bucket / collection remediation for a particular org
# run this in the right env console with the right secrets
o = Org.find 62
GcsService.new(org: o).create_bucket
GcsService.new(org: o).create_qdrant_collection

# Transitioning org scope to group scope
#   assets, folders, projects, prompts, resources
# 1) update data, changing scope org to group
Asset.where(scope: 'org').update_all(scope: 'group')
Folder.where(scope: 'org').update_all(scope: 'group')
Project.where(scope: 'org').update_all(scope: 'group')
Prompt.where(scope: 'org').update_all(scope: 'group')
Resource.where(scope: 'org').update_all(scope: 'group')
# 2) update controllers to change queries from org to group
, scope: 'org' to , scope: 'group'
.scope == 'org' to .scope == 'group'
# 3) confirm proper collections, debug
# 4) migration to change default from org to group
# 
# 