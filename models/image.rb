class Image < ActiveRecord::Base
  belongs_to :post
  before_destroy :delete_files

  private
    def delete_files
      begin File.delete("./app/images/posts/#{self.post.folder_hash}/#{self.file_icon}");rescue; end
      begin File.delete("./app/images/posts/#{self.post.folder_hash}/#{self.file_preview}");rescue; end
      begin File.delete("./app/images/posts/#{self.post.folder_hash}/#{self.file_normal}");rescue; end
    end
end