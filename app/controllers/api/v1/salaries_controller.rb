# frozen_string_literal: true

# API v1 Salaries Controller
# Provides CRUD endpoints for salary management
class Api::V1::SalariesController < Api::V1::BaseController
  # GET /api/v1/salaries
  # List all salaries with optional filtering
  def index
    salaries = Salary.includes(:employee)
    salaries = salaries.by_employee(params[:employee_id]) if params[:employee_id].present?
    salaries = salaries.active_salaries if params[:active] == 'true'
    salaries = salaries.ordered

    render json: SalarySerializer.new(salaries, is_collection: true)
  end

  # GET /api/v1/salaries/:id
  # Show a specific salary record
  def show
    salary = Salary.includes(:employee).find(params[:id])
    render json: SalarySerializer.new(salary)
  end

  # POST /api/v1/salaries
  # Create a new salary record
  def create
    salary = Salary.new(salary_params)

    if salary.save
      render json: SalarySerializer.new(salary), status: :created
    else
      render_validation_errors(salary)
    end
  end

  # PATCH/PUT /api/v1/salaries/:id
  # Update a salary record
  def update
    salary = Salary.find(params[:id])

    if salary.update(salary_params)
      render json: SalarySerializer.new(salary)
    else
      render_validation_errors(salary)
    end
  end

  # DELETE /api/v1/salaries/:id
  # Delete a salary record
  def destroy
    salary = Salary.find(params[:id])
    salary.destroy!

    render json: null, status: :no_content
  end

  private

  # Strong parameters for salary attributes
  def salary_params
    params.require(:data).require(:attributes).permit(
      :employee_id, :amount, :currency, :salary_type,
      :effective_date, :is_current
    )
  end
end
