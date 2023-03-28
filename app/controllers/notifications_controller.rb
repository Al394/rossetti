class NotificationsController < ApplicationController
  before_action :fetch_notification, only: [:set_read]

  def index
    @notifications = current_user.notifications.order(id: :desc).paginate(page: params[:page], per_page: params[:per_page])
  end

  def set_all_read
    begin
      current_user.notifications.update_all(read: true)
    rescue Exception => e
      flash[:alert] = t('obj.not_updated_exception', obj: Notification.model_name.human.downcase, message: e.message)
    ensure
      render js: 'location.reload();'
    end
  end

  def set_read
    begin
      @notification.update!(read: true)
      if @notification.kind == "missing_industry_data"
        redirect_to [:customer_machines]
      else
        redirect_back(fallback_location: :root)
      end
    rescue Exception => e
      flash[:alert] = t('obj.not_updated_exception', obj: Notification.model_name.human.downcase, message: e.message)
    end
  end

  private

  def fetch_notification
    @notification = Notification.find(params[:id])
  end
end
