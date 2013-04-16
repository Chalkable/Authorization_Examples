require 'sinatra'
require 'rest-client'
require 'json'

APP_CONFIG = {
  url: "http://localhost:9292/",
  api_key: "54398ab20e414abfb3a326c4646fd7799229f3c7071e4d8e94c1be2b58ffefea857c76845bb84a53b87f76feb431d05bdfb93c0b97e240abb5ef176481ae57f2"
}

set :environment, :development
set :port, 9292

helpers do
  def get_current_user(access_token)
    begin
      resp = RestClient.get("https://chalkable.com/User/Me.json", :authorization => "Bearer:" + access_token)
      parsed = JSON.parse(resp)['data']
      parsed[:is_teacher] = parsed['rolename'] == 'Teacher'
      return :res => parsed, :error => false
    rescue => e
      return :res => e, :error => true, :stack_trace => e.backtrace
    end
  end
end

get '/' do
  # Get the access token
  begin
    args = {
      'client_id' => APP_CONFIG[:url],
      'client_secret' => APP_CONFIG[:api_key],
      'scope' => "https://chalkable.com",
      'redirect_uri' => APP_CONFIG[:url],
      'grant_type' => 'authorization_code',
      'code' => params[:code]
    }
    oauth_response = RestClient.post(
      "https://chalkable-access-control.accesscontrol.windows.net/v2/OAuth2-13",
      args
    )
  rescue => e
    return [400, "Error"]
  end
  parsed_response = JSON.parse(oauth_response)
  access_token = parsed_response['access_token']
  me = get_current_user(access_token)[:res]
  me['displayname'].to_s
  puts me.inspect
end