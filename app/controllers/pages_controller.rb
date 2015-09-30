class PagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  AUTH_CTX = ADAL::AuthenticationContext.new(
    'login.windows.net', ENV['TENANT'])
  CLIENT_CRED = ADAL::ClientCredential.new(ENV['CLIENT_ID'], ENV['CLIENT_SECRET'])
  GRAPH_RESOURCE = 'https://graph.microsoft.com'
  
  # TODO can I dynamically get the host + port?
  REPLY_URL = 'http://localhost:9292/auth/azureactivedirectory/callback';

  def index
  end
  
  def login
    redirect_to "/auth/azureactivedirectory"
  end
  
  def authd
    # Authentication redirects here
    code = params[:code]
    
    # Used in the template
    @name = auth_hash.info.name
    @email = auth_hash.info.email
    
    # Request an access token
    result = acquire_auth_token(code, REPLY_URL)
    
    # Associate this token to our user's session
    session[:access_token] = result.access_token
    # name -> session
    session[:name] = @name
    # email -> session
    session[:email] = @email
    
    # Debug logging
    puts "Code: #{code}"
    puts "Name: #{@name}"
    puts "Email: #{@email}"
    puts "[authd] - Access token: #{session[:access_token]}"
  end
  
  def send_mail
    puts "[send_mail] - Access token: #{session[:access_token]}"
    
    # Used in the template
    @name = session[:name]
    @email = params[:specified_email]
    @recipient = params[:specified_email]
    
    # TODO send the email...
    
    render "authd"
  end

  def auth_hash
    request.env['omniauth.auth']
  end
  
  def acquire_auth_token(auth_code, reply_url)
  AUTH_CTX.acquire_token_with_authorization_code(
                  auth_code,
                  reply_url,
                  CLIENT_CRED,
                  GRAPH_RESOURCE)
  end
  
end