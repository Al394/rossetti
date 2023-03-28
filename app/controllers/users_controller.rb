class UsersController < ApplicationController
  load_and_authorize_resource

  before_action :fetch_user, only: [:destroy, :show, :toggle_role, :edit, :update]

  def destroy
    begin
      @user.destroy!
      flash[:notice] = I18n::t('obj.destroyed', obj: User.model_name.human.downcase)
    rescue Exception => e
      flash[:alert] = I18n::t('obj.not_destroyed', obj: User.model_name.human.downcase, message: e.message)
    ensure
      redirect_to :users
    end
  end

  def new
    @user = User.new
    @user.password = SecureRandom.base64(8)
  end

  def create
    @user = User.new(create_params)
    if @user.save
      flash[:notice] = I18n::t('obj.created', obj: User.model_name.human.downcase)
      render js: 'location.reload();'
    else
      @error = I18n::t('obj.not_created', obj: User.model_name.human.downcase)
      render :new
    end
  end

  def index
    @users = User.all
    @users = @users.paginate(page: params[:page], per_page: params[:per_page])
    @users = @users.where('first_name LIKE :search OR last_name LIKE :search OR email LIKE :search', search: "%#{params[:search]}%") if params[:search].present?
  end

  def update
    old_value = Role.find_by(id: params[:old_value])
    if old_value.code == 'agent' && old_value != Role.find_by(id: params[:role_id])
      @user.update_customers_agent
    end
    if @user.update(update_params)
      flash[:notice] = I18n::t('obj.updated', obj: User.model_name.human.downcase)
      render js: 'location.reload();'
    else
      flash.now[:alert] = I18n::t('obj.not_updated', obj: User.model_name.human.downcase)
      render :edit
    end
  end

  def reset_psw
    if request.patch?
      if new_psw_params[:new_psw] == new_psw_params[:confirm_psw]
        begin
          @user.reset_psw!(new_psw_params[:new_psw])
          sign_in(@user, :bypass => true)
          flash[:notice] = I18n::t('obj.updated', obj: User.model_name.human.downcase)
          render js: 'location.reload();'
        rescue Exception => e
          @error = I18n::t('obj.not_updated_exception', obj: User.model_name.human.downcase, message: e.message)
          render :reset_psw
        end
      else
        @error = "Le due password non sono uguali."
        render :reset_psw
      end
    end
  end

  private

  def new_psw_params
    params.require(:user).permit(:new_psw, :confirm_psw)
  end

  def create_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :role_id)
  end

  def update_params
    params.require(:user).permit(:first_name, :last_name, :email, :role_id)
  end

  def fetch_user
    @user = User.find(params[:id])
  end
end
