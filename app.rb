require 'sinatra/base'
require 'json'
require 'haml'
require 'sinatra/flash'
require 'httparty'

# nbasalaryscrape service
class TeamPay < Sinatra::Base
  enable :sessions
  register Sinatra::Flash
  use Rack::MethodOverride

  configure :production, :development do
    enable :logging
  end

  configure :development do
    set :session_secret, "something"    # ignore if not using shotgun in development
  end

  API_BASE_URI = 'http://nbapayservice.herokuapp.com'
  #API_BASE_URI = 'http://localhost:9393'
  API_VER = '/api/v1/'

  helpers do
    def current_page?(path = ' ')
      path_info = request.path_info
      path_info += ' ' if path_info == '/'
      request_path = path_info.split '/'
      request_path[1] == path
    end

    def api_url(resource)
      URI.join(API_BASE_URI, API_VER, resource).to_s
    end
  end

  get '/' do
    haml :home
  end

  get '/salary' do
    @teamname = params[:teamname]
    if @teamname
      redirect "/salary/#{@teamname}"
      return nil
    end

    haml :salary
  end

  get '/salary/:teamname' do
    @teamname = params[:teamname]
    @salary = HTTParty.get api_url("#{@teamname}.json")

    if @salary.nil?
      flash[:notice] = 'Please select team from list' if @salary.nil?
      redirect '/salary'
    end
    haml :salary
  end

  delete '/comparisons/:id' do
    request_url = "#{API_BASE_URI}/api/v1/comparisons/#{params[:id]}"
    result = HTTParty.delete(request_url)
    flash[:notice] = 'record deleted'
    redirect '/comparisons'
  end

  delete '/playertotal/:id' do
    request_url = "#{API_BASE_URI}/api/v1/playertotal/#{params[:id]}"
    result = HTTParty.delete(request_url)
    flash[:notice] = 'record deleted'
    redirect '/playertotal'
  end

  # put '/comparisons/:id' do
  #   request_url = "#{API_BASE_URI}/api/v1/comparisons/#{params[:id]}"
  #   result = HTTParty.delete(request_url)
  #   flash[:notice] = 'record deleted'
  #   redirect '/comparisons'
  # end
  #
  # put '/playertotal/:id' do
  #   request_url = "#{API_BASE_URI}/api/v1/playertotal/#{params[:id]}"
  #   result = HTTParty.delete(request_url)
  #   flash[:notice] = 'record deleted'
  #   redirect '/playertotal'
  # end

  get '/comparisons' do
    @action = :create
    haml :comparisons
  end

  post '/comparisons' do
    request_url = "#{API_BASE_URI}/api/v1/comparisons"

    playername2 = params[:playername2]
    teamname = params[:teamname]
    playername1 = params[:playername1]
    params_h = {
          playername2: playername2,
          teamname: teamname,
          playername1: playername1
    }

    options =  {
                  body: params_h.to_json,
                  headers: { 'Content-Type' => 'application/json' }
               }

    result = HTTParty.post(request_url, options)

    if (result.code != 200)
      flash[:notice] = 'Players not found! Ensure that team and player names are spelled correctly. '
      redirect '/comparisons'
      return nil
    end

    id = result.request.last_uri.path.split('/').last
    session[:result] = result.to_json
    session[:playername2] = playername2
    session[:playername1] = playername1
    session[:teamname] = teamname
    session[:action] = :create
    redirect "/comparisons/#{id}"
  end

  get '/comparisons/:id' do
    if session[:action] == :create
      @results = session[:result]
      @teamname = session[:teamname]
      @playername = session[:playername1]
      @playername2 = session[:playername2]
    else
      request_url = "#{API_BASE_URI}/api/v1/comparisons/#{params[:id]}"
      options =  { headers: { 'Content-Type' => 'application/json' } }
      result = HTTParty.get(request_url, options)
      @results = result
      @id = params[:id]
    end

    @id = params[:id]
    @action = :update
    haml :comparisons
  end

  post '/api/v1/comparisons' do
    content_type :json

    body = request.body.read
    logger.info body
    begin
      req = JSON.parse(body)
      logger.info req
    rescue Exception => e
      puts e.message
      halt 400
    end
    incomes = Income.new
    incomes.teamname = req['teamname']
    incomes.playername1 = req['playername1']
    incomes.playername2 = req['playername2']

    if incomes.save
      redirect "/api/v1/comparisons/#{incomes.id}"
    end
  end

  get '/playertotal' do
    @action2 = :create
    haml :playertotal
  end

  post '/playertotal' do
    request_url = "#{API_BASE_URI}/api/v1/playertotal"

    teamname = params[:teamname]
    playername1 = params[:playername1]
    params_h = {
          teamname: teamname,
          playername1: playername1
    }

    options =  {
                  body: params_h.to_json,
                  headers: { 'Content-Type' => 'application/json' }
               }

    result = HTTParty.post(request_url, options)

    if (result.code != 200)
      flash[:notice] = 'Player not found! Ensure that team and player name is spelled correctly. '
      redirect '/playertotal'
      return nil
    end

    id = result.request.last_uri.path.split('/').last
    session[:result] = result.to_json
    session[:playername1] = playername1
    session[:teamname] = teamname
    session[:action] = :create
    redirect "/playertotal/#{id}"
  end

  get '/playertotal/:id' do
    if session[:action] == :create
      @fullpay = session[:result]
      @teamname2 = session[:teamname]
      @playername2 = session[:playername1]
    else
      request_url = "#{API_BASE_URI}/api/v1/playertotal/#{params[:id]}"
      options =  { headers: { 'Content-Type' => 'application/json' } }
      result = HTTParty.get(request_url, options)
      @fullpay = JSON.parse(result)

    end

    @id = params[:id]
    @action2 = :update
    haml :playertotal
  end

  not_found do
    status 404
    'not found'
  end
end
