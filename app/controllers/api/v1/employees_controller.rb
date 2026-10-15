# frozen_string_literal: true

# API v1 Employees Controller
# Provides CRUD endpoints for employee management
class Api::V1::EmployeesController < Api::V1::BaseController
  # GET /api/v1/employees
  # List all employees with optional filtering
  def index
    employees = Employee.includes(:department, :location, :current_salary)
    employees = employees.active if params[:status] == 'active' || params[:active] == 'true'
    employees = employees.inactive if params[:status] == 'inactive'
    employees = employees.search(params[:query]) if params[:query].present?
    employees = employees.where(department_id: params[:department_id]) if params[:department_id].present?
    employees = employees.joins(:location).where(locations: { country: params[:country] }) if params[:country].present?
    employees = employees.ordered

    render json: EmployeeSerializer.new(employees, is_collection: true)
  end

  # GET /api/v1/employees/:id
  # Show a specific employee
  def show
    employee = Employee.includes(:department, :location, :salaries).find(params[:id])
    render json: EmployeeSerializer.new(employee)
  end

  # POST /api/v1/employees
  # Create a new employee
  def create
    employee = Employee.new(employee_params)

    if employee.save
      render json: EmployeeSerializer.new(employee), status: :created
    else
      render_validation_errors(employee)
    end
  end

  # PATCH/PUT /api/v1/employees/:id
  # Update an employee
  def update
    employee = Employee.find(params[:id])

    if employee.update(employee_params)
      render json: EmployeeSerializer.new(employee)
    else
      render_validation_errors(employee)
    end
  end

  # DELETE /api/v1/employees/:id
  # Soft delete an employee (sets is_active to false)
  def destroy
    employee = Employee.find(params[:id])
    employee.soft_delete

    render json: null, status: :no_content
  end

  private

  # Strong parameters for employee attributes
  def employee_params
    params.require(:data).require(:attributes).permit(
      :first_name, :last_name, :email, :employee_id, :job_title,
      :hire_date, :department_id, :location_id, :is_active
    )
  end
end
