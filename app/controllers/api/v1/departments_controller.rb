# frozen_string_literal: true

# API v1 Departments Controller
# Provides CRUD endpoints for department management
class Api::V1::DepartmentsController < Api::V1::BaseController
  # GET /api/v1/departments
  # List all departments
  def index
    departments = Department.ordered
    render json: DepartmentSerializer.new(departments, is_collection: true)
  end

  # GET /api/v1/departments/:id
  # Show a specific department
  def show
    department = Department.find(params[:id])
    render json: DepartmentSerializer.new(department)
  end

  # POST /api/v1/departments
  # Create a new department
  def create
    department = Department.new(department_params)

    if department.save
      render json: DepartmentSerializer.new(department), status: :created
    else
      render_validation_errors(department)
    end
  end

  # PATCH/PUT /api/v1/departments/:id
  # Update a department
  def update
    department = Department.find(params[:id])

    if department.update(department_params)
      render json: DepartmentSerializer.new(department)
    else
      render_validation_errors(department)
    end
  end

  # DELETE /api/v1/departments/:id
  # Delete a department
  def destroy
    department = Department.find(params[:id])
    department.destroy!

    render json: null, status: :no_content
  end

  private

  # Strong parameters for department attributes
  def department_params
    params.require(:data).require(:attributes).permit(:name, :budget, :manager_id)
  end
end