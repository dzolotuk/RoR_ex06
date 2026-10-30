module ApplicationHelper
  # 19.9 => "19.90 €"
  def price_tag(amount)
    number_to_currency(amount, unit: '€', format: '%n %u')
  end
end
