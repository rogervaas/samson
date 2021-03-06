# frozen_string_literal: true
class UserMergesController < ApplicationController
  before_action :authorize_resource!
  before_action :find_user

  def new
  end

  def create
    target = User.find(params[:merge_target_id])
    @user.update_attributes!(external_id: target.external_id)
    target.soft_delete!
    redirect_to @user, notice: "Merge successful."
  end

  private

  def find_user
    @user = User.find(params[:user_id])
  end
end
