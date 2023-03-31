class IndustryDataController < ApplicationController
  load_and_authorize_resource

  before_action :fetch_industry_datum, only: [:resend]

  def index
    @industry_data = IndustryDatum.all.ordered
    @industry_data = @industry_data.where('file_name LIKE :file_name', file_name: "%#{params[:file_name]}%") if params[:file_name].present?
    @industry_data = @industry_data.where('customer_machine_id LIKE :customer_machine_id', customer_machine_id: "%#{params[:customer_machine_id]}%") if params[:customer_machine_id].present?
    @industry_data = @industry_data.where("starts_at >= :from_create", from_create: params[:from_create].to_date) if params[:from_create].present?
    @industry_data = @industry_data.where("starts_at <= :to_create", to_create: params[:to_create].to_date) if params[:to_create].present?
    @industry_data = @industry_data.where("ends_at >= :from_end", from_end: params[:from_end].to_date) if params[:from_end].present?
    @industry_data = @industry_data.where("ends_at <= :from_end", to_create: params[:from_end].to_date) if params[:from_end].present?
    if params[:sent_to_gest].present?
      if params[:sent_to_gest].to_boolean
        @industry_data = @industry_data.sent
      else
        @industry_data = @industry_data.unsent
      end
    end
    @industry_data = @industry_data.paginate(page: params[:page], per_page: params[:per_page])
  end

  def resend
    begin
      @industry_datum.customer_machine.update!(token: nil)
      SendToFilemaker.perform_later(@industry_datum.id)
      flash[:notice] = I18n::t('obj.updated', obj: IndustryDatum.model_name.human.downcase)
    rescue Exception => e
      flash[:danger] = I18n::t('obj.not_uploaded', obj: IndustryDatum.model_name.human.downcase, message: e.message)
    ensure
      redirect_to [:industry_data]
    end
  end

  def sent_all
    begin
      if params[:industry_datum_id].present?
        SendToFilemaker.perform_later(params[:industry_datum_id])
      else
        IndustryDatum.unsent.each do |industry_datum|
          SendToFilemaker.perform_later(industry_datum.id)
        end
      end
      sleep(0.4)
      redirect_to [:industry_data, page: params[:page]]
      flash[:warning] = t('obj.sending', obj: IndustryDatum.model_name.human(count: 0).downcase)
    rescue Exception => e
      raise "#{e.message}"
      redirect_to [:industry_data, page: params[:page]]
      flash[:notice] = t('strings.not_sent_exception', obj: IndustryDatum.model_name.human(count: 0))
    end
  end
  private

  def fetch_industry_datum
    @industry_datum = IndustryDatum.find(params[:id])
  end
end
