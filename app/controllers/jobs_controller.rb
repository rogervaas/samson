# frozen_string_literal: true
class JobsController < ApplicationController
  include CurrentProject

  skip_before_action :require_project, only: [:enabled]

  before_action :authorize_project_deployer!, except: [:index, :show, :enabled]
  before_action :find_job, only: [:show, :destroy]

  def index
    @jobs = @project.jobs.non_deploy.page(page)
  end

  def show
    respond_to do |format|
      format.html
      format.text do
        datetime = @job.updated_at.strftime("%Y%m%d_%H%M%Z")
        send_data @job.output,
          type: 'text/plain',
          filename: "#{@project.permalink}-#{@job.id}-#{datetime}.log"
      end
    end
  end

  def enabled
    if JobQueue.enabled
      head :no_content
    else
      head :accepted
    end
  end

  def destroy
    if @job.can_be_cancelled_by?(current_user)
      @job.cancel(current_user)
      flash[:notice] = "Cancelled!"
    else
      flash[:error] = "You are not allowed to cancel this job."
    end

    redirect_back fallback_location: [@project, @job]
  end

  private

  def find_job
    @job = current_project.jobs.find(params[:id])
  end
end
