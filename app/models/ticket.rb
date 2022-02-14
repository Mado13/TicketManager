class Ticket < ApplicationRecord
  belongs_to :lead_developer, class_name: "User"
  belongs_to :project
  has_many :ticket_assignments
  has_many :developers, through: :ticket_assignments, foreign_key: :developer_id, validate: false
  has_one :project_manager, through: :project
end
