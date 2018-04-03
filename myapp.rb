require 'rubygems'
require 'sinatra'
require 'json'
require 'omniauth'
require 'omniauth-github'
require 'omniauth-facebook'
require 'omniauth-twitter'

class SinatraApp < Sinatra::Base
  configure do
    set :sessions, true
    set :inline_templates, true
  end

  use OmniAuth::Builder do
    provider :facebook,  '__putyourappid__', '__putyoursecret__'
    #provider :github,  '__putyourappid__', '__putyoursecret__'
    #provider :twitter, '__putyourappid__', '__putyoursecret__'
  end
  
  get '/' do
    erb "
    <a href='http://localhost:4567/auth/facebook'>Login with facebook</a><br>
    <!--<a href='http://localhost:4567/auth/github'>Login with Github</a><br>-->
    <!--<a href='http://localhost:4567/auth/twitter'>Login with twitter</a><br>-->"
  end
  
  get '/auth/:provider/callback' do
    session[:authenticated] = true
    erb "<h1>#{params[:provider]}</h1>
         <pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>"
  end
  
  get '/auth/failure' do
    erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
  end
  
  get '/auth/:provider/deauthorized' do
    erb "#{params[:provider]} has deauthorized this app."
  end
  
  get '/protected' do
    throw(:halt, [401, "Not authorized\n"]) unless session[:authenticated]
    request.env['omniauth.auth'] = session[:authenticated]
    erb "<pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre><hr>
         <a href='/logout'>Logout</a>"
  end
  
  get '/logout' do
    session[:authenticated] = false
    redirect '/'
  end

end

SinatraApp.run! if __FILE__ == $0

__END__

@@ layout
<html>
  <head>
    <link href='https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css' rel='stylesheet' />
  </head>
  <body>
    <div class='container'>
      <div class='content'>
        <%= yield %>
      </div>
    </div>
  </body>
</html>
