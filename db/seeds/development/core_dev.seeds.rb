AdminUser.destroy_all
admin = AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

Org.destroy_all
org = Org.create(name: 'IBM', url: 'https://ibm.com', email_domain: 'ibm.com')

Group.destroy_all
group = Group.create(name: 'default', org_id: org.id)

User.destroy_all
argon = Argon2::Password.new(secret: ENV['ARGON_KEY'])
user1 = User.create(fname: 'Ima', lname: 'User1', email: 'user1@example.com', password_hash: argon.create('password'))

org.users << user1
group.members << user1

argon = Argon2::Password.new(secret: ENV['ARGON_KEY'])
user2 = User.create(fname: 'Ima', lname: 'User2', email: 'user2@example.com', password_hash: argon.create('password'))

org.users << user2
group.members << user2

AssetGenerator.destroy_all
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