# frozen_string_literal: true
require 'csv'

class UsersController < ApplicationController
  before_action :authorize_resource!

  def index
    @users = User.search_by_criteria(params)
    respond_to do |format|
      format.html
      format.json { render_json_with_includes :users, @users, allowed: [:user_project_roles] }
      format.csv do
        redirect_to(new_csv_export_path(format: :csv, type: :users))
      end
    end
  end

  def new
    @user = User.new
  end

  def create
    name = params.require(:user).require(:name)
    @user = User.new(
      name: name,
      email: 'noreply@example.com',
      external_id: name.parameterize,
      integration: true
    )
    if @user.save
      redirect_to @user, notice: "User created!"
    else
      render 'new'
    end
  end

  def show
    @projects = Project.search_by_criteria(params).joins(:user_project_roles).
      where(user_project_roles: {user_id: user.id})
    if role_id = params[:role_id].presence
      @projects = @projects.where("user_project_roles.role_id >= ?", role_id)
    end
    @projects = @projects.select('projects.*, user_project_roles.role_id AS user_project_role_id').
      order(:name)

    @projects_without_role = (Project.all - @projects).sort_by(&:name)
  end

  def update
    if user.update_attributes(user_params)
      Rails.logger.info(
        "#{current_user.name_and_email} changed the role of #{user.name_and_email} to #{user.role.name}"
      )
      head :ok
    else
      head :bad_request
    end
  end

  def destroy
    user.soft_delete!
    Rails.logger.info("#{current_user.name_and_email} just deleted #{user.name_and_email})")
    redirect_to users_path
  end

  private

  def user
    @user ||= User.find(params[:id])
  end

  def user_params
    # also reset pending access request, so the user can request further access rights
    params.require(:user).permit(:role_id).merge(access_request_pending: false)
  end
end
