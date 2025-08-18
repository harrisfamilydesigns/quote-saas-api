class Api::V1::ProjectsController < Api::V1::BaseController
  before_action :require_contractor, except: [ :show, :index ]
  before_action :set_project, only: [ :show, :update, :destroy ]

  # GET /api/v1/projects
  def index
    if current_user.contractor_user?
      projects = current_user.contractor.projects
    elsif current_user.supplier_user?
      # Suppliers see projects with material requests they've quoted on
      projects = Project.joins(material_requests: :quotes)
                       .where(material_requests: { quotes: { supplier_id: current_user.supplier_id } })
                       .distinct
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end

    render json: ProjectSerializer.new(projects).serialize
  end

  # GET /api/v1/projects/:id
  def show
    if current_user.contractor_user? && @project.contractor_id != current_user.contractor_id
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end

    if current_user.supplier_user? && !supplier_has_access_to_project?
      render json: { error: 'Unauthorized' }, status: :unauthorized
      return
    end

    render json: ProjectSerializer.new(@project).serialize
  end

  # POST /api/v1/projects
  def create
    project = current_user.contractor.projects.new(project_params)

    if project.save
      render json: ProjectSerializer.new(project).serialize, status: :created
    else
      render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/projects/:id
  def update
    if @project.update(project_params)
      render json: ProjectSerializer.new(@project).serialize
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/projects/:id
  def destroy
    @project.destroy
    head :no_content
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :status)
  end

  def supplier_has_access_to_project?
    @project.material_requests.joins(:quotes)
           .where(quotes: { supplier_id: current_user.supplier_id })
           .exists?
  end
end
