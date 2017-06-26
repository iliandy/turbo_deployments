class User < ActiveRecord::Base
	EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i
  belongs_to :dojo
  has_secure_password
  validates :first_name, :last_name, presence: true, length: {minimum:2}
  validates :email, presence: true, uniqueness: {case_sensitive: false}, format:{with: EMAIL_REGEX} 
end
