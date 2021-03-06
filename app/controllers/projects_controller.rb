class ProjectsController < ApplicationController
  before_action :set_project, only: %I[show edit update]

  def index
    # @project is being populated with the relevant data according to user role
    @project = Project.new
    # includes 'lead_developer' and 'project_manager' in order the reduce DB queries,
    # both of them refer to Users table, but on different foreign keys
    @projects = policy_scope(Project.all.includes(:lead_developer).includes(:project_manager))
  end

  def show
    @developer_tickets = Ticket.developer_tickets(current_user)
    @project_tickets = Ticket.includes(:project).where(project_id: @project)
  end

  def new
    # Authorize the instance of Project to check if the user has the right
    # priviliges to create a new project
    authorize Project
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    # Authorization is preformed after instantiation to prevent from the user
    # to change their id in the inspect tool and create new projects.
    authorize @project
    if @project.save
      redirect_to project_path(@project)
      flash[:notice] = "Project #{@project.title} Created Successfully"
    else
      @project ||= Project.new
      render :new
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project
    if @project.update(project_params)
      redirect_to project_path(@project)
      flash[:notice] = "#{@project.title} Updated Successfully"
    else
      @project ||= Project.new
      render :edit
    end
  end

  private

  def project_params
    params.require(:project).permit(
      :title,
      :description,
      :project_manager_id,
      :lead_developer_id
    )
  end

  def set_project
    @project = Project.find(params[:id])
  end
end
