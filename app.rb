require 'bundler'
Bundler.require(:default)

require 'yaml'
require 'securerandom'
require 'logger'
require 'sinatra/assetpack'
require 'sinatra/flash'
require 'sinatra/cookies'
require 'sinatra/reloader'

require_relative 'models/init'
require_relative 'helpers/init'

db = YAML.load_file('./config/database.yml')["development"]
ActiveRecord::Base.establish_connection( db )

class App < Sinatra::Base
  register Sinatra::AssetPack
  register Sinatra::Namespace
  include CaptchaHelper
  include MailerHelper
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

    js :layout, ['/js/jquery-1.11.2.min.js', '/js/bootstrap.min.js', '/js/jquery-ui.min.js', '/js/jquery.fancybox.pack.js' ]
    css :layout, ['/css/bootstrap.min.css', '/css/jquery.fancybox.css', '/css/app.css']
    js :admin, ['/js/jquery-1.11.2.min.js', '/js/admin.js']
    js :contact, ['/js/jquery-1.11.2.min.js', '/js/contact.js']

    css :application, ['/css/application.css']
    js :fancybox, ['/js/jquery-1.11.2.min.js', '/js/jquery.fancybox.pack.js']
    css :fancybox, ['/css/jquery.fancybox.css']
    css :bootstrap, ['/css/bootstrap.min.css']

    js_compression :jsmin
    css_compression :sass
  end

  configure do
    configure :development do
      register Sinatra::Reloader
      also_reload './helpers/auth_helper.rb'
      also_reload './helpers/captcha_helper.rb'
      also_reload './helpers/mailer_helper.rb'
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
    if config["file_logger"]
      env["rack.errors"] = error_logger
    end
  end


  get '/' do
    @images = Image.where(is_on_welcome_screen: true).order(:id)
    @gmap_key = config["gmap_key"]
    @text_welcome = Constant.get('text_welcome')
    @news = Constant.get('news')
    @address = Constant.get('address')
    @bgColor = Constant.get('bgAccueil')
    erb :accueil
  end

  get '/meubles' do
    @page_title="Meubles"
    @bgColor = Constant.get('bgMeubles')
    @panels = Panel.where(panel_type: "meuble", is_active: true).order(:ordre)
    erb :content
  end

  get '/atelier' do
    @page_title="Atelier"
    @bgColor = Constant.get('bgAtelier')
    @panels = Panel.where(panel_type: "atelier", is_active: true).order(:ordre)
    erb :content
  end

  get '/decoration' do
    @page_title="Décoration"
    @bgColor = Constant.get('bgDecoration')
    @panels = Panel.where(panel_type: "decoration", is_active: true).order(:ordre)
    erb :content
  end

  get '/evenements' do
    @bgColor = Constant.get('bgEvenements')
    @news = Constant.get('news')
    erb :evenements
  end

  get '/contact' do
    @text_intro_contact = Constant.get('text_contact')
    erb :contact
  end

  post '/contact' do
    cookies[:email] = params[:email]
    cookies[:confirmEmail] = params[:confirmEmail]
    cookies[:title] = params[:title]
    cookies[:content] = params[:content]

    errors = []
    errors << "Emails non compatibles" if params[:email]!=params[:confirmEmail]
    errors << "Veuillez écrire un message" if params[:content].nil? or params[:content]==""
    errors << "Code de sécurité erroné" unless captcha_pass?
    
    unless errors.empty?
      errors << "Veuillez retaper le code de sécurité" unless errors.include? "Code de sécurité erroné"
      flash[:error] = errors.join(', ')
    else
      send_mail(params[:email], params[:title], params[:content])
      cookies[:title], cookies[:content] = nil, nil
      Notification.create(email: params[:email], title: params[:title], content: params[:content] )
      flash[:notice] = "Votre message a bien été envoyé à Hervé Bonnot, je vous recontacterai au plus vite."
    end
    redirect '/contact'
  end


  # ============ admin section


  namespace '/admin' do
    include AuthHelper

    before do
      @title = "Admin"
      protected!
    end

    get '' do
      redirect '/admin/gallery'
    end

    # List all constantes
    get '/constants' do
      @constants = Constant.all.order(:id)
      erb :constants, layout: :admin_layout
    end

    # Update constants
    post '/constants' do
      params.each do |key, value|
        c = Constant.find_by(key: key)
        c.update_attributes({value: value}) unless c.nil?
      end
      flash[:notice] = "Sauvegardé"
      redirect '/admin/constants'
    end

    # List all panels
    get '/gallery' do
      @panels = Panel.all
      erb :panels, layout: :admin_layout
    end

    # View form for a new panel
    get '/gallery/new' do
      @panel = Panel.new
      @title_form, @cta_form = "Création", "Créer"
      erb :panel_form, layout: :admin_layout
    end

    # Create a new panel
    post '/gallery/new' do
      puts "#{params}"
      Panel.create(params.slice("title", "subtitle", "icon_id", "date", "panel_type"))
      flash[:notice] = "Panel créé."
      redirect '/admin/gallery'
    end

    # Sort panels
    post '/gallery/order' do
      params[:list].each_with_index do |id, index|
        panel = Panel.find(id)
        panel.ordre = index
        panel.save
      end
      halt 200
    end

    # Ajax to active/deactive a panel
    get '/gallery/:id/toggle' do
      @panel = Panel.find(params[:id])
      @panel.is_active = !@panel.is_active
      @panel.save
      halt 200
    end

    # View form to edit a panel
    get '/gallery/:id' do
      @panel = Panel.find(params[:id])
      @title_form, @cta_form = "Editer", "Enregistrer"
      redirect '/admin/gallery' if @panel.nil?
      erb :panel_form, layout: :admin_layout
    end

    # Update a panel
    post '/gallery/:id' do
      @panel = Panel.find(params[:id])
      @panel.update_attributes(params.slice("title", "subtitle", "icon_id", "date", "panel_type"))
      flash[:notice] = "Panel sauvé."
      redirect '/admin/gallery'
    end

    # Delete a panel
    get '/gallery/:id/delete' do
      @panel = Panel.find(params[:id])
      @panel.destroy unless @panel.nil?
      flash[:notice] = "Le panel a été supprimé, et toutes ses images avec"
      redirect '/admin/gallery'
    end

    # List all images of a panel
    get '/gallery/:id/image' do
      @panel = Panel.find(params[:id])
      erb :image, layout: :admin_layout
    end

    # Create a new image
    post '/gallery/:id/image/new' do
      @panel = Panel.find(params[:id])

      if params[:myfile].nil? or params[:name].nil?
        flash[:error] = "Choissisez au moins un fichier et un nom."
        redirect "/admin/gallery/#{params[:id]}/image"
      end
      format = params[:myfile][:filename].split('.')[1].downcase
      img = Image.create(
        name: params[:name],
        comment: params[:comment],
        panel_id: @panel.id,
      )

      img.update_attributes({  
        file_vignette: "#{@panel.folder_name}_#{img.id}_vignette.#{format}",
        file_normal: "#{@panel.folder_name}_#{img.id}.#{format}",
      })

      # Save image
      File.open("./app/images/panels/#{@panel.folder_name}/#{img.file_normal}", "wb") do |f|
        f.write(params[:myfile][:tempfile].read)
      end

      # Resize image
      i = Magick::Image.read("./app/images/panels/#{@panel.folder_name}/#{img.file_normal}").first
      width, height = i.columns, i.rows

      normal_size, vignette_size = 1024, 150
      i.resize_to_fit(normal_size,normal_size).write("./app/images/panels/#{@panel.folder_name}/#{img.file_normal}") if width > normal_size || height > normal_size

      if width > vignette_size || height > vignette_size
        i.resize_to_fit(vignette_size,vignette_size).write("./app/images/panels/#{@panel.folder_name}/#{img.file_vignette}")
      else
        i.write("./app/images/panels/#{@panel.folder_name}/#{img.file_icon}")
      end

      if @panel.images.length == 1
        @panel.icon_id = img.id
        @panel.save
      end

      flash[:notice] = "Image enregistrée"
      redirect "/admin/gallery/#{params[:id]}/image"
    end

    # Update image title and cmment
    post '/gallery/:id/image/:img_id' do
      @img = Image.find(params[:img_id])
      @img.update_attributes({name: params[:name], comment: params[:comment]}) unless @img.nil?
      flash[:notice] = "Image #{params[:name]} sauvegardée"
      redirect "/admin/gallery/#{params[:id]}/image"
    end

    # Delete an image
    get '/gallery/:id/image/:img_id/delete' do
      @image = Image.find(params[:img_id])
      @image.destroy unless @image.nil?
      flash[:notice] = "Image supprimée"
      redirect "/admin/gallery/#{params[:id]}/image"
    end

    # List all images
    get '/images' do
      @images = Image.all.order(:id)
      erb :select_images, layout: :admin_layout
    end

    # Toggle image appearance on welcome screen
    get '/images/:id/toggle' do
      @image = Image.find(params[:id])
      @image.is_on_welcome_screen = !@image.is_on_welcome_screen
      @image.save
      halt 200
    end

    get '/notifications' do
      @notifications = Notification.order(:created_at).reverse
      erb :notifications, layout: :admin_layout
    end

    get '/notification/:id/delete' do
      Notification.where(id: params[:id]).delete_all
      redirect '/admin/notifications'
    end

  end


end


