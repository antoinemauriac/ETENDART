module ApplicationHelper
  include Pagy::Frontend

  def replace_zero_with_dash(value)
    value == 0 ? '-' : "#{value}€"
  end
end
