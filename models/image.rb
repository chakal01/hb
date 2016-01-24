class Image < ActiveRecord::Base
  belongs_to :panel
  before_destroy :delete_files

  private
    def delete_files
      begin File.delete("./app/images/panels/#{self.panel.folder_name}/#{self.file_vignette}");rescue; end
      begin File.delete("./app/images/panels/#{self.panel.folder_name}/#{self.file_normal}");rescue; end
    end
end