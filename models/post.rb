require 'securerandom'
require 'fileutils'

class Post < ActiveRecord::Base
  has_many :images, dependent: :destroy
  belongs_to :icon, class_name: 'Image', foreign_key: :icon_id
  before_create :set_folder_hash
  after_create :create_folder
  before_destroy :delete_images_folder
	def day
    mois = case self.date.strftime("%B")
    when "January"
      "Janvier"
    when "February"
      "Février"
    when "March"
      "Mars"
    when "April"
      "Avril"
    when "May"
      "May"
    when "June"
      "Juin"
    when "July"
      "Juillet"
    when "August"
      "Août"
    when "September"
      "Septembre"
    when "October"
      "Octobre"
    when "November"
      "Novembre"
    when "December"
      "Décembre"
    else
      "Inconnu"
    end
    return self.date.strftime("%d<br>#{mois}<br>%Y")
	end

  private
    def set_folder_hash
      self.folder_hash = SecureRandom.hex[0..7]
      self.sha1 = SecureRandom.hex[0..4]
      self.actif = 0
      self.views = 0
      self.order = Post.count
    end

    def create_folder
      path = "./app/images/posts/#{self.folder_hash}"
      unless File.directory?(path)
        FileUtils.mkpath(path)
      end
    end

    def delete_images_folder
      FileUtils.rm_rf("./app/images/posts/#{self.folder_hash}")
    end

end
