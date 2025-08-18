class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  belongs_to :contractor, optional: true
  belongs_to :supplier, optional: true

  validates :email, presence: true, uniqueness: true
  validates :role, presence: true

  # Define valid roles
  ROLES = [
    ROLE_CONTRACTOR = 'contractor',
    ROLE_SUPPLIER = 'supplier',
    ROLE_ADMIN = 'admin'
  ].freeze
  validates :role, inclusion: { in: ROLES }

  def contractor_user?
    role == 'contractor'
  end

  def supplier_user?
    role == 'supplier'
  end

  def admin_user?
    role == 'admin'
  end
end
