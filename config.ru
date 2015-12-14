require "./lib/racker"
use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :expire_after => 2592000,
                           :secret => 'change_me',
                           :old_secret => 'also_change_me'
use Rack::Static, :urls => ["/css", "/fonts", "/js"], :root => "public"
use Rack::Reloader
run Racker