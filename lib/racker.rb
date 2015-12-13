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
        @request.session[:error] = nil
      end
    end
  end

  def start_game
    Rack::Response.new do |response|
      @request.session[:game] = Codebreaker::Game.new.start
      @request.session[:marks] = []
      @request.session[:hint] = []
      @request.session[:saved] = nil
      response.redirect("/")
    end
  end

  def guessing_input
    input = params_suggest
    gues = game.guess(params_suggest).join
    @request.session[:marks] << [input, gues]
  end

  def guessing
    Rack::Response.new do |response|
      begin
      if game.win?
        response.redirect('/win')
      elsif game.lose?
        response.redirect('/lose')
      else
        guessing_input
        response.redirect("/")
      end
      rescue RuntimeError => e
      @request.session[:error] = "0 from #{Codebreaker::Game::ATTEMPTS} attempts left!"
      ensure
      response.redirect("/")
      end  
    end
  end

  def hint
    Rack::Response.new do |response|
      if game.win?
        response.redirect("/win")
      elsif game.lose?
        response.redirect("/lose")
      else
        begin
        @request.session[:hint] = [game.hint]
        rescue RuntimeError => e
        @request.session[:error] = "Hint may be used only #{Codebreaker::Game::HINT_COUNT} times!"
        ensure
        response.redirect("/")
        end
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
      if @request.session[:saved]
        response.redirect("/win")
      else
        game.user_name = @request.params["user_name"]
        score_hash = { name:          game.user_name,
                       score:         game.score,
                       attempts_left: game.attempts,
                       win_date:      Time.now.strftime("%d.%m.%y|%H:%M:%S"),
                       hints_left:    game.hint_count }
        game.save_game(score_hash)
        @request.session[:saved] = true
        response.redirect("/high_score")
      end
    end
  end

  def high_score
    Rack::Response.new do |response|
      if File.exist?("saves/score_table")
        hash = YAML.load_stream(File.read("saves/score_table"))
        h = hash.each.sort_by{|v| v[:score]}.reverse
        @request.session[:score] = h
        response.write(render("high_score.html.erb"))
      else
        response.redirect("/")
      end
    end
  end

  def game
    @request.session[:game]
  end

  def error
    @request.session[:error]
  end

  def params_suggest
    @request.params["suggest"]
  end

end