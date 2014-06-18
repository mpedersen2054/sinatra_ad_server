require "sinatra/base"

module Sinatra

  module Authorization

    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end

    def unauthorized!(realm="Short URL generator")
      headers "WWW-Authenticate" => %(Basic realm="#{realm}")
      throw :halt, [ 401, 'Authorization Required' ]
    end

    def bad_request!
      throw :halt, [ 400, 'Bad Request' ]
    end

    def authorize(username, password)
      if ( username == "patmedersen" && password == "asdf123456" ) then
        true
      else
        false
      end
    end

    def require_admin
      return if authorized?
      unauthorized! unless auth.provided?
      bad_request! unless auth.basic?
      unauthorized! unless authorize(*auth.credentials)
      request.env['REMOTE_USER'] = auth.username
    end

    def authorization_realm
      Sinatra::Default.authorization_realm
    end

    def authorized?
      !!request.env['REMOTE_USER']
    end
    alias :logged_in? :authorized?

    def current_user
      request.env['REMOTE_USER']
    end

  end

end