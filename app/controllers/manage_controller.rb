class ManageController < ApplicationController
	
  # CanCan Permissions
  authorize_resource :class => false
  
  def index

  end

  def withdraw
    @withdrawal = Withdrawal.new
  end

  def deposits
  	@deposits = Deposit.where(:status => :failed).reorder(id: :desc).page(params[:page]).per(100)
  end

  def redemptions
  	@redemptions = Redemption.all.reorder(id: :desc).page(params[:page]).per(100)
  end

  def process_redemption
    
    @redemption = Redemption.find(params[:id])

    if @redemption
      if Engine::RedemptionEngine.reprocess_redemption(@redemption)
        flash[:notice] = 'Redemption processed'
      else
        flash[:error] = 'Redemption processing failed, look at redemption message'
      end
    else
      flash[:error] = 'Redemption not found'
    end

    respond_to do |format|
      format.html { return redirect_to controller: :manage, action: :redemptions }
    end
  end

  def revenues
  	@revenues = Revenue.all.reorder(id: :desc).page(params[:page]).per(100)
  end
end
