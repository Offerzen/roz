
InvestecOpenApi.configuration do |config|
  config.api_url = ENV['INVESTEC_API_URL']
  config.api_username = ENV['INVESTEC_API_USERNAME']
  config.api_password = ENV['INVESTEC_API_PASSWORD']
  config.scope = "accounts"
end
