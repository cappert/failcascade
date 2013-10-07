module ApplicationHelper
  def state_of(alliance)
    if alliance.collapsed?
      'dead and gone'
    elsif !alliance.significant?
      'insignificant'
    else
      case alliance.growth_ratio
      when (0..0.5) then 'failcascading'
      when (0.5..0.7) then 'bleeding members'
      when (0.7..0.95) then 'dimnishing'
      when (0.95..1.05) then 'carrying on'
      when (1.05..1.3) then 'growing'
      else 'growing rapidly'
      end
    end
  end

  def l(date, *args)
    date.present? ? super : ''
  end

  def icon_class(attribute)
    case attribute
    when :current_member_count then 'icon-user'
    when :sov_held then 'icon-map-marker'
    end
  end

  def attribute(object, attribute, data: {}, display: :attribute)
    dt_content = case display
                 when :attribute then object.class.human_attribute_name(attribute)
                 else link_to(object.full_name, polymorphic_path(object))
                 end

    value = object.send attribute
    value = l(value) if value.respond_to? :to_date

    dd_content = h(value) + '&nbsp;'.html_safe + content_tag(:i, nil, class: icon_class(attribute))

    content_tag(:dt, dt_content, data: data) + content_tag(:dd, dd_content, title: object.class.human_attribute_name(attribute))
  end
end
