class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :timeoutable, :trackable

  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true
end
