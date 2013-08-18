module ApplicationHelper
  def state_of(alliance)
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
