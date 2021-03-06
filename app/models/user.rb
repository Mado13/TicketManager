class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :role
  has_many :projects
  has_many :comments
  has_many :ticket_assignments, foreign_key: :developer_id

  # Scope to count all tickets assigned to a developer and show them on the dashboard
  scope :tickets_by_developer, lambda {
    joins(:ticket_assignments)
      .select('users.*, COUNT(ticket_assignments) AS tickets_count')
      .group('users.id')
      .order('tickets_count DESC')
  }

  # A custom join scope to join table users and projects on user.id to the foreign_key
  # lead_developer_id/project_manager_id according to what is passed in.
  scope :custom_join, ->(role) { joins("INNER JOIN \"projects\" ON \"projects\".\"#{role}_id\" = \"users\".\"id\"") }

  # Scope to count all projects assosciated with a specific role,
  # call the custom_join scope with the role passed as an argument from
  # the controller.
  scope :count_projects, lambda { |role|
    custom_join(role)
      .select('users.*, COUNT(projects) AS projects_count')
      .group('users.id')
      .order('projects_count DESC')
  }

  def self.users_by_role(role)
    Role.find_by(name: role).users
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def role_name
    role.name
  end
end
