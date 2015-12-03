require 'erb'
require 'codebreaker'
 
class Racker
  def self.call(env)
    new(env).response.finish
  end
   
  def initialize(env)
    @request = Rack::Request.new(env)
  end
   
  def response
    case @request.path
    when "/" then Rack::Response.new(render("index.html.erb"))
    when "/start_game" then start_game
    when "/update_word" then update_word
    else Rack::Response.new("Not Found", 404)
    end
  end
   
  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def update_word
    Rack::Response.new do |response|
      response.set_cookie('answer', game.guess(@request.params["answer"]).join)
      response.redirect("/")
    end
  end

  def start_game
    Rack::Response.new do |response|
      @request.session[:game] = Codebreaker::Game.new.start
      response.redirect("/")
    end
  end

  def game
    @request.session[:game]
  end

  def answer
    @request.cookies['answer'] || 'Wrong input'
  end

end