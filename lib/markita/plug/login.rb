# frozen_string_literal: true

# Markita namespace
module Markita
  # Base class of the Sinatra Markita application
  class Base
    # Login namespace to support the /login.html route
    module Login
      ID = File.exist?(_=File.join(ROOT, '.valid-id')) ?
           File.read(_).strip :
           nil
      IPS = (_=OPTIONS.allowed)? _.split(',') : []
      if !IPS.empty? && !ID
        raise 'Allowed ips without site password does not make sense.'
      end
      FORM   = File.read PATH['login_form.html']
      FAILED = File.read PATH['login_failed.html']
    end

    before do
      unless Login::ID.nil? || Login::IPS.include?(request.ip)
        if (id=params[:id])
          session[:id] = Digest::SHA256.hexdigest id
        end
        if session[:id] == Login::ID
          redirect '/' if request.path_info == '/login.html'
        else
          puts "#{request.ip} #{request.path_info}".magenta
          redirect '/login.html' unless request.path_info == '/login.html'
        end
      end
    end

    get '/login.html' do
      Login::FORM
    end

    post '/login.html' do
      Login::FAILED
    end
  end
end
