require 'securerandom'
require 'fileutils'

class Panel < ActiveRecord::Base
  has_many :images, dependent: :destroy
  belongs_to :icon, class_name: 'Image', foreign_key: :icon_id
  before_create :default_values
  after_create :create_folder
  before_destroy :delete_images_folder

  private
    def default_values
      self.folder_name = I18n.transliterate(self.title).gsub(/ /, '_')
      self.is_active = false
      self.ordre = Panel.count
    end

    def create_folder
      path = "./app/images/panels/#{self.folder_name}"
      unless File.directory?(path)
        FileUtils.mkpath(path)
      end
    end

    def delete_images_folder
      FileUtils.rm_rf("./app/images/panels/#{self.folder_name}")
    end

end
