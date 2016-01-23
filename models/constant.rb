class Constant < ActiveRecord::Base
    validates :key, uniqueness: true
end