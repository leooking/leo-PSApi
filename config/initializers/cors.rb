# 
# PDF preview requires cors origin for stag and prod apps on each GCS buckets
#   https://cloud.google.com/storage/docs/using-cors#client-libraries
#  
# The following CORS regex configure the allowable domains to allow either http(s), 
# and allow any subdomain, as well as the firebase aliases.

Rails.application.config.middleware.insert_before 0, Rack::Cors, debug: true, logger: (-> { Rails.logger }) do
  allowed_methods = %i[get post put delete options head]
  allow do
    # allow http(s) and any port and localhost or loopback address
    origins /\Ahttps?:\/\/((.*\.)*localhost|127.0.0.1)(:\d+)?\z/
    resource '*', credentials: true, headers: :any, max_age: 600, methods: allowed_methods
  end
  allow do
    # no quotes and wrapped in /.../ to be proper regex literal
    origins /\Ahttps?:\/\/([a-z0-9-]+\.)?psci-stag-app-8c52a(.*\.web\.app|\.firebaseapp\.com)\z/
    resource '*', credentials: true, headers: :any, max_age: 600, methods: allowed_methods
  end
  allow do
    # no quotes and wrapped in /.../ to be proper regex literal
    origins /\Ahttps?:\/\/([a-z0-9-]+\.)?pscibis-production(.*\.web\.app|\.firebaseapp\.com)\z/
    resource '*', credentials: true, headers: :any, max_age: 600, methods: allowed_methods
  end
  allow do
    origins /\Ahttps?:\/\/([a-z0-9-]+\.)?pscibis.com\z/
    resource '*', credentials: true, headers: :any, max_age: 600, methods: allowed_methods
  end
  allow do
    origins /\Ahttps?:\/\/([a-z0-9-]+\.)?psciai.com\z/
    resource '*', credentials: true, headers: :any, max_age: 600, methods: allowed_methods
  end
end
