# frozen_string_literal: true

# API v1 Employees Controller
# Provides CRUD endpoints for employee management
class Api::V1::EmployeesController < Api::V1::BaseController
  # GET /api/v1/employees
  # List all employees with optional filtering
  def index
    render_collection(EmployeeSerializer, filtered_employees)
  end

  # GET /api/v1/employees/:id
  # Show a specific employee
  def show
    employee = User.employee_records.includes(:department, :location, :salaries).find(params[:id])
    render json: EmployeeSerializer.new(employee)
  end

  # POST /api/v1/employees
  # Create a new employee
  def create
    employee = nil
    User.transaction do
      employee = User.new(employee_params.merge(role: :employee))
      employee.save!

      if salary_amount.present?
        employee.salaries.create!(
          amount: salary_amount,
          currency: "USD",
          salary_type: Salary::SALARY_TYPES.fetch(:base),
          effective_date: employee.hire_date,
          is_current: true
        )
      end
    end

    if employee
      render json: EmployeeSerializer.new(employee), status: :created
    end
  rescue ActiveRecord::RecordInvalid => error
    render_validation_errors(error.record)
  end

  # PATCH/PUT /api/v1/employees/:id
  # Update an employee
  def update
    employee = User.employee_records.find(params[:id])

    if employee.update(employee_params)
      render json: EmployeeSerializer.new(employee)
    else
      render_validation_errors(employee)
    end
  end

  # DELETE /api/v1/employees/:id
  # Soft delete an employee (sets is_active to false)
  def destroy
    employee = User.employee_records.find(params[:id])
    employee.soft_delete

    head :no_content
  end

  private

  # Strong parameters for employee attributes
  def employee_params
    params.require(:data).require(:attributes).permit(
      :first_name, :last_name, :email, :job_title,
      :hire_date, :department_id, :location_id, :is_active
    )
  end

  def salary_amount
    params.require(:data).require(:attributes).permit(:salary)[:salary]
  end

  def filtered_employees
    employees = User.employee_records.includes(:department, :location, :current_salary)
    employees = employees.active if params[:status] == "active" || params[:active] == "true"
    employees = employees.inactive if params[:status] == "inactive"
    employees = employees.search(params[:query]) if params[:query].present?
    employees = employees.where(department_id: params[:department_id]) if params[:department_id].present?
    employees = employees.joins(:location).where(locations: { country: params[:country] }) if params[:country].present?
    employees.ordered
  end
end
