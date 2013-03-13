require 'rest-client'
require 'json'
 
 
APP_CONFIG = {
    :acs_url => "https://chalkable-access-control.accesscontrol.windows.net/v2/OAuth2-13",
    :client_id => "www.MyEdTechApp.com/",
    :client_secret => "Your API key from Chalkable Developer portal",
    :scope => "https://chalkable.com",
    :redirect_uri => "www.MyEdTechApp.com/",
    :service_url => "https://chalkable.com/User/Me.json"
}
 
 
def get_access_token(code)
  begin
    @response = RestClient.post(
        APP_CONFIG[:acs_url],
        'client_id' => APP_CONFIG[:client_id],
        'client_secret' =>APP_CONFIG[:client_secret],
        'scope' => APP_CONFIG[:scope],
        'redirect_uri' => APP_CONFIG[:redirect_uri],
        'grant_type' => 'authorization_code',
        'code' => code
    )
  rescue => e
    return :res => e, :error => true, :stack_trace => e.backtrace
  end
  return :res => JSON.parse(@response), :error => false
end
 
 
def get_current_user(access_token)
  begin
    @response = RestClient.get(APP_CONFIG[:service_url], :authorization => "Bearer:" + access_token)
    res = JSON.parse(@response)['data']
    res[:is_teacher] = res['rolename'] == 'Teacher'
    return :res => res, :error => false
  rescue => e
    return :res => e, :error => true, :stack_trace => e.backtrace
  end
end
 
 
token = get_access_token(25346243456868468)
puts token
puts get_current_user(token)
 