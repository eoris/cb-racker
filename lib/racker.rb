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
    when "/"           then index
    when "/start_game" then start_game
    when "/guessing"   then guessing
    when "/hint"       then hint
    when "/win"        then win
    when "/lose"       then lose
    when "/save_score" then save_score
    when "/high_score" then high_score
    else Rack::Response.new("Not Found", 404)
    end
  end
   
  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def index
    Rack::Response.new do |response|
      if @request.session[:game].nil?
        response.redirect('/start_game')
      elsif game.win?
        response.redirect('/win')
      elsif game.lose?
        response.redirect('/lose')
      else
        response.write(render("index.html.erb"))
      end
    end
  end

  def start_game
    Rack::Response.new do |response|
     p @request.session[:game] = Codebreaker::Game.new.start
      # response.delete_cookie('suggest')
      # response.delete_cookie('input')
      @request.session[:marks] = []
      @request.session[:hint] = []
      response.redirect("/")
    end
  end

  def guessing
    Rack::Response.new do |response|
      begin
      input = params_suggest
      guessing = game.guess(params_suggest).join
     p @request.session[:marks] << [input, guessing]
      if game.win?
        response.redirect('/win')
      elsif game.lose?
        response.redirect('/lose')
      else
        response.redirect("/")
      end
      rescue RuntimeError => e
      response.redirect("/")
      end  
    end
  end

  def hint
    Rack::Response.new do |response|
      begin
      if game.have_hint?
       p @request.session[:hint] = [game.hint]
        response.redirect("/")
      else
        response.redirect("/")
      end
      rescue
      response.redirect("/")
      end
    end
  end

  def win
    Rack::Response.new do |response|
      if game.win?
        response.write(render("win.html.erb"))
      else
        response.redirect("/")
      end
    end
  end

  def lose
    Rack::Response.new do |response|
      if game.lose?
        response.write(render("lose.html.erb"))
      else
        response.redirect("/")
      end
    end
  end

  def save_score
    Rack::Response.new do |response|
      game.user_name = @request.params["user_name"]
      score_hash = { "player - #{game.user_name}" => 
                      { 'score'         => game.score,
                        'attempts left' => game.attempts,
                        'hints left'    => game.hint_count } }
      game.save_game(score_hash)
      response.redirect("/high_score")
    end
  end

  def high_score
    Rack::Response.new(render("high_score.html.erb"))
  end

  def game
    @request.session[:game]
  end

  def params_suggest
    @request.params["suggest"]
  end

end