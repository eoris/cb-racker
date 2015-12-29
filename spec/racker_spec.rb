require 'spec_helper.rb'

describe Racker do
  include Rack::Test::Methods
  let(:racker) { Racker.new(TEST_ENV) }

  context '#call' do
    it 'call :new, :response, :finish' do
      expect(Racker).to receive_message_chain(:new, :response, :finish)
      Racker.call(TEST_ENV)
    end
  end

  describe '#response' do
    before { @request = racker.instance_variable_get(:@request) }
    after { racker.response }

      context 'when @request.path "/"' do
        it 'call a #index' do
          allow(@request).to receive(:path).and_return("/")
          expect(racker).to receive(:index)
        end
      end

    @pages = ['start_game', 'guessing', 'hint', 'win',
              'lose', 'save_score', 'high_score']
    @pages.each do |p|
      context "when @request.path /#{p}" do
        it "call a ##{p}" do
          allow(@request).to receive(:path).and_return("/#{p}")
          expect(racker).to receive("#{p}".to_sym)
        end
      end
    end
  end

  describe 'not_found' do
    let(:request) { Rack::MockRequest.new(stack) }
    context "when @request.path any other path" do
      let(:response) { request.get("/not_found") }
      it "page not found" do
        expect(Rack::Response).to receive(:new).with("Not Found", 404)
        racker.response
      end
    end
  end

  describe '#index' do
    before {racker.start_game}

    context 'when session[game] == nil' do
      it 'redirect to /start_game' do
        racker.instance_variable_get(:@request).session[:game] = nil
        action = racker.index
        expect(action.location).to eq('/start_game')
        expect(action.status).to eq(302)
      end
    end

    context 'when the game is won' do
      it 'redirect to /win' do
        allow(racker.game).to receive(:win?).and_return(true)
        action = racker.index
        expect(action.location).to eq('/win')
        expect(action.status).to eq(302)
      end
    end

    context 'when the game is lost' do
      it 'redirect to /lose' do
        allow(racker.game).to receive(:lose?).and_return(true)
        action = racker.index
        expect(action.location).to eq('/lose')
        expect(action.status).to eq(302)
      end
    end

    context 'when the game goes on' do
      it 'render "index.html.erb"' do
        expect(racker).to receive(:render).with("index.html.erb")
        racker.index
      end

      it 'set session[error] to nil' do
        expect(racker.instance_variable_get(:@request).session[:error]).to be_nil
      end
    end

    describe '#start_game' do
      it '' do

      end
    end

    describe '#guessing' do
      it '' do

      end
    end

    describe '#hint' do
      it '' do

      end
    end

    describe '#win' do
      it '' do

      end
    end

    describe '#lose' do
      it '' do

      end
    end

    describe '#save_score' do
      it '' do

      end
    end

    describe '#high_score' do
      it '' do

      end
    end


  end

end

