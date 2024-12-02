module ApplicationHelper
  include Pagy::Frontend

  def replace_zero_with_dash(value, add_currency = true)
    value == 0 ? '-' : "#{value}#{'€' if add_currency}"
  end
end
