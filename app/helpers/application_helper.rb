module ApplicationHelper
  def pdf_stylesheet_pack_tag(source)
    if Rails.env == 'development'
      wicked_pdf_stylesheet_link_tag('bootstrap')
    else
      wicked_pdf_stylesheet_pack_tag(source)
    end
  end

  def pdf_javascript_pack_tag(source)
    if Rails.env == 'development'
      wicked_pdf_javascript_link_tag(source)
    else
      wicked_pdf_javascript_pack_tag(source)
    end
  end

  def boolean(value, options = {})
    content_tag :span, class: "badge badge-#{value ? 'success' : 'danger'}" do
      content_tag :i, nil, class: "fa fa-#{value ? :check : :times}"
    end
  end

  def number_to_hour_minutes(number)
    time = ''
    if number > 86400
      days = (number / 86400).to_i
      number = number - days * 86400
      time = "#{days}g "
    end
    time += Time.at(number).utc.strftime("%Hh %Mmin %Ssec").to_s
  end

  def number_to_hour_minutes_no_sec(number)
    time = ''
    if number > 86400
      days = (number / 86400).to_i
      number = number - days * 86400
      time = "#{days}g "
    end
    time += Time.at(number).utc.strftime("%Hh %Mmin").to_s
  end

  def toggle(url, value, options = {})
    options.deep_merge!({ class: :'btn btn-secondary', data: { checkbox: true, disable: true, url: url } })
    if value
      yes = content_tag :span, (content_tag :i, nil, class: :'fa fa-check'), class: :'btn btn-success'
      no = link_to (content_tag :i, nil, class: :'fa fa-times'), '#', options
    else
      yes = link_to (content_tag :i, nil, class: :'fa fa-check'), '#', options
      no = content_tag :span, (content_tag :i, nil, class: :'fa fa-times'), class: :'btn btn-danger'
    end
    content_tag :div, class: :'btn-group btn-group-xs', data: { behaviour: :toggle } do
      "#{yes} #{no}".html_safe
    end
  end
end
