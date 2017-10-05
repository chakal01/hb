class Constant < ActiveRecord::Base
  validates :key, uniqueness: true


  def self.get(key, default = "")
    c = Constant.find_by(key: key)
    if c.nil? or c.value.nil?
      return default
    else
      c.value.gsub(/\n/, '<br>') 
    end
  end

end