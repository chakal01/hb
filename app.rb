require 'bundler'
Bundler.require(:default)

require 'yaml'
require './helpers/auth_helper'
require './helpers/captcha_helper'
# require './helpers/mailer_helper'
require 'securerandom'
require 'logger'
require 'sinatra/assetpack'
require 'sinatra/flash'
require 'sinatra/cookies'
require 'sinatra/reloader'

# db = YAML.load_file('./config/database.yml')["development"]

#   ActiveRecord::Base.establish_connection(
#       adapter: db["adapter"],
#       host: db["host"],
#       username: db["username"],
#       password: db["password"],
#       database: db["database"],
#       encoding: db["encoding"]
#   )

class App < Sinatra::Base
  register Sinatra::AssetPack
  register Sinatra::Namespace
  include CaptchaHelper
  enable :sessions
  register Sinatra::Flash
  helpers Sinatra::Cookies

  config = YAML.load_file('./config/application.yml')

  if config["file_logger"]
    ::Logger.class_eval { alias :write :'<<' }
    access_log = ::File.join(::File.dirname(::File.expand_path(__FILE__)),'log','access.log')
    access_logger = ::Logger.new(access_log)
    error_logger = ::File.new(::File.join(::File.dirname(::File.expand_path(__FILE__)),'log','error.log'),"a+")
    error_logger.sync = true
  end

  set :root, File.dirname(__FILE__)

  assets do
    serve '/images', from: 'app/images'
    serve '/css', from: 'app/css'
    serve '/js', from: 'app/js'
    serve '/fonts', from: 'app/fonts'

    js :layout, ['/js/jquery-1.11.2.min.js', '/js/bootstrap.min.js']
    css :layout, ['/css/bootstrap.min.css', '/css/app.css']
    js :panel_form, ['/js/panel_form.js']

    js_compression :jsmin
    css_compression :sass
  end

  configure do
    configure :development do
      register Sinatra::Reloader
      also_reload './helpers/auth_helper.rb'
      also_reload './helpers/captcha_helper.rb'
      also_reload './models/constant.rb'
      also_reload './models/image.rb'
      also_reload './models/notification.rb'
      also_reload './models/panel.rb'
    end
    if config["file_logger"]
      use ::Rack::CommonLogger, access_logger
    end
  end

  before do
    @title = "Création"
    if config["file_logger"]
      env["rack.errors"] = error_logger
    end
  end


  get '/' do
    erb :welcome
  end

  


  # ============ admin section


  namespace '/admin' do
    include AuthHelper

    before do
      @title = "Admin"
      protected!
    end

    get '' do
      erb :admin
    end

    get '/constants' do
      @constants = Constant.all
      erb :constants
    end

    post '/constants' do
      params.each do |key, value|
        c = Constant.find_by(key: key)
        c.update_attributes({value: value}) unless c.nil?
      end
      flash[:notice] = "Sauvegardé"
      redirect '/admin/constants'
    end

    get '/gallery' do
      @panels = Panel.all
      erb :panels
    end

    get '/gallery/new' do
      @panel = Panel.new
      erb :panel_form
    end

    post '/gallery/new' do
      puts "#{params}"
      Panel.create(params.slice("title", "subtitle", "vignette_id", "date"))
      flash[:notice] = "Panel créé."
      redirect '/admin/gallery'
    end

    get '/gallery/:id' do
      @panel = Panel.find(params[:id])
      redirect '/admin/gallery' if @panel.nil?
      erb :panel_form
    end

    post '/gallery/:id' do
      @panel = Panel.find(params[:id])
      @panel.update_attributes(params.slice("title", "subtitle", "vignette_id", "date"))
      flash[:notice] = "Panel sauvé."
      redirect '/admin/gallery'
    end

    get '/gallery/:id/delete' do
      @panel = Panel.find(params[:id])
      @panel.destroy
      flash[:notice] = "Le panel a été supprimé, et toutes ses images avec."
      redirect '/admin/gallery'
    end

  end


end

require_relative 'models/init'
require_relative 'helpers/init'
