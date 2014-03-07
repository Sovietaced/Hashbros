  class WorkersController < ApplicationController

  before_filter :authenticate_user!

  # CanCan Permissions
  load_and_authorize_resource

  def index
    @rounds = Round.page(params[:page])
    @workers = current_user.valid_workers
  end

  def show
    @worker = Worker.find(params[:id])
    @worker_credits = @worker.worker_credits.reorder(id: :desc).page(params[:worker_credits_page])
  end

  def new
    @worker = Worker.new
  end

  def create

    # Check to see if the user did not put their username plus '.' in the worker field
    if !(worker_params['username'] =~ /^#{current_user.username}\./) and current_user
      # Check to see if this worker already exists (the case where we are actually re-enabling a deleted worker)
      @worker = Worker.where(:user => current_user, :username => current_user.username + '.' + worker_params['username']).first
      if @worker.nil?
        begin
          @worker = Worker.create!(:user => current_user, :username => current_user.username + '.' + worker_params['username'])
        rescue ActiveRecord::RecordNotUnique
          flash[:error] = 'Worker username has already been taken. Please try a new one'
          return render :action => :new
        end
      else
        if @worker.is_enabled
          flash[:error] = 'Worker username has already been taken. Please try a new one'
          return render :action => :new
        else
          @worker.update_attributes!(:is_enabled => true)
        end
      end

      if @worker
        flash[:success] = 'Successfully saved a new worker!'
        return redirect_to :action => 'index'
      end
    end
    # This line overrides the default rendering behavior, which
    # would have been to render the "create" view.
    render "new"
  end

  def destroy
    worker = Worker.find(params[:id])
    if worker.user == current_user
      worker.update_attributes(:is_enabled => false)
      flash[:success] = 'Successfully deleted worker'
    else
      flash[:error] = 'You do not have permission to delete that worker'
    end
    return redirect_to :action => 'index'
  end

  private

  def worker_params
    params.required(:worker).permit(:user, :username, :hash_rate_mhs, :difficulty)
  end
end
