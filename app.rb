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

  API_BASE_URI = 'http://nbaservice.herokuapp.com'
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
      session.clear
    else
      request_url = "#{API_BASE_URI}/api/v1/comparisons/#{params[:id]}"
      options =  { headers: { 'Content-Type' => 'application/json' } }
      result = HTTParty.get(request_url, options)
      if result.code == 404
        flash[:notice] = 'This record is not a comparision ... try total salary'
        redirect '/comparisons'
        return nil
      end
      @results = result
      @id = params[:id]
    end

    @id = params[:id]
    @action = :update
    haml :comparisons
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
    session[:result] = JSON.parse(result.body)
    session[:playername1] = playername1
    session[:teamname] = teamname
    session[:action] = :create
    redirect "/playertotal/#{id}"
  end

  get '/playertotal/:id' do
    if session[:action] == :create
      if !session[:result][0].nil?
        @fullpay = session[:result][0][0]
      end
      @teamname2 = session[:teamname]
      @playername2 = session[:playername1]
      session.clear
    else
      request_url = "#{API_BASE_URI}/api/v1/playertotal/#{params[:id]}"
      options =  { headers: { 'Content-Type' => 'application/json' } }
      result = HTTParty.get(request_url, options)
      if result.code == 400
        flash[:notice] = 'This record does not exist'
        redirect '/playertotal'
        return nil
      end
       arrayOfArrayOfJson = JSON.parse(result.body)
       if !arrayOfArrayOfJson[0].nil?
         @fullpay = arrayOfArrayOfJson[0][0]
       end
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
