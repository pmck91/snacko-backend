class User < ApplicationRecord
  has_secure_password

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, uniqueness: true, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password_digest, presence: true, length: { minimum: 6 }

  before_validation do
    (self.email = self.email.to_s.downcase) &&
    (self.first_name = self.first_name.to_s.downcase) &&
    (self.last_name = self.last_name.to_s.downcase)
  end

  def can_modify_user?(user_id)
    role == 'admin' || id.to_s == user_id.to_s
  end

  def is_admin?
    role == 'admin'
  end
end
