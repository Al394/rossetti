class NotificationMailer < ApplicationMailer
  def custom_delivery_options
    {
      address: Customization.smtp_address,
      port: Customization.smtp_port,
      enable_starttls_auto: Customization.smtp_starttls,
      ssl: Customization.smtp_ssl_tls,
      authentication: Customization.smtp_authentication_method,
      user_name: Customization.smtp_username,
      password: Customization.smtp_password,
      openssl_verify_mode: 'none'
    }
  end

  def created(user, resource)
    @user = user
    @resource = resource
    mail to: @user.email, subject: I18n::t('mailer.notification.created.subject', obj: @resource.model_name.human, text: @resource.to_s), delivery_method_options: custom_delivery_options, template_name: 'created'
  end

  def updated(user, resource, notes = nil)
    @user = user
    @resource = resource
    @notes = notes
    mail to: @user.email, subject: I18n::t('mailer.notification.updated.subject', obj: @resource.model_name.human, text: @resource.to_s), delivery_method_options: custom_delivery_options, template_name: 'updated'
  end

  def deleted(user, resource)
    @user = user
    @resource = resource
    mail to: @user.email, subject: I18n::t('mailer.notification.deleted.subject', obj: @resource.model_name.human, text: @resource.to_s), delivery_method_options: custom_delivery_options, template_name: 'deleted'
  end

  def concluded(user, resource)
    @user = user
    @resource = resource
    if @resource.is_a?(JobOperation)
      resource = Operation.model_name.human
    else
      resource = @resource.model_name.human
    end
    mail to: @user.email, subject: I18n::t('mailer.notification.concluded.subject', obj: resource, text: @resource.to_s), delivery_method_options: custom_delivery_options, template_name: 'concluded'
  end

  def understock(user, resource)
    @user = user
    @resource = resource
    mail to: @user.email, subject: I18n::t('mailer.notification.understock.subject', obj: resource, text: @resource.to_s), delivery_method_options: custom_delivery_options
  end

  def missing_data(user, text)
    @user = user
    @text = text
    mail to: @user.email, subject: I18n::t('mailer.notification.missing_data.subject'), delivery_method_options: custom_delivery_options, template_name: 'missing_data'
  end
end
