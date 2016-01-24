class Constant < ActiveRecord::Base
  validates :key, uniqueness: true


  def self.get(key)
    c = Constant.find_by(key: key)
    if c.nil?
      return ""
    else
      c.value.gsub(/\n/, '<br>') 
    end
  end

end