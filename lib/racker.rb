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
    when "/"           then Rack::Response.new(render("index.html.erb"))
    when "/start_game" then start_game
    when "/guessing"   then guessing
    when "/win"        then win
    when "/lose"       then lose
    else Rack::Response.new("Not Found", 404)
    end
  end
   
  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def start_game
    Rack::Response.new do |response|
      @request.session[:game] = Codebreaker::Game.new.start
      response.delete_cookie('answer')
      response.delete_cookie('input')
      response.redirect("/")
    end
  end

  def guessing
    Rack::Response.new do |response|
      inp = @request.params["answer"]
      answ = game.guess(@request.params["answer"]).join
      response.set_cookie('input', inp)
      response.set_cookie('answer', answ)
      if game.win?
        response.redirect('/win')
      elsif game.lose?
        response.redirect('/lose')
      else
        response.redirect("/")
      end
    end
  end

  def win
    Rack::Response.new(render("win.html.erb"))
  end

  def lose
    Rack::Response.new(render("lose.html.erb"))
  end

  def game
    @request.session[:game]
  end

  def input
    @request.cookies['input']
  end

  def answer
    @request.cookies['answer']
  end

end