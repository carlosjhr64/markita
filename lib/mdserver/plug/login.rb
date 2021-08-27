module MDServer
class Base
  module Login
    ID = File.exist?(_=File.join(ROOT, '.valid-id')) ?
         File.read(_).strip :
         nil
    IPS = (_=OPTIONS&.allowed)? _.split(',') : nil
    if IPS and not ID
      raise "Allowed ips without site password does not make sense."
    end
    FORM   = File.read File.join(APPDIR, 'data/login_form.html')
    FAILED = File.read File.join(APPDIR, 'data/login_failed.html')
  end

  before do
    unless Login::ID.nil? or Login::IPS&.include?(request.ip)
      if id = params[:id]
        session[:id] = Digest::SHA256.hexdigest id
      end
      if session[:id] == Login::ID
        redirect '/' if request.path_info == '/login.html'
      else
        redirect '/login.html' unless request.path_info == '/login.html'
      end
    end
    puts "#{request.ip} #{request.path_info}"
  end

  get '/login.html' do
    Login::FORM
  end

  post '/login.html' do
    Login::FAILED
  end
end
end

