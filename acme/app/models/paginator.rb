# Cuts a list of records in pages (the catalog has thousands of products).
class Paginator
  PER_PAGE = 50

  attr_reader :number, :total_pages

  def initialize(relation, requested_page)
    @relation = relation
    @total_pages = [(relation.count / PER_PAGE.to_f).ceil, 1].max
    # A wrong page ("abc", 0, 99999) gives the nearest real page.
    @number = requested_page.to_i.clamp(1, @total_pages)
  end

  def records
    @relation.offset((number - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def previous_page
    number - 1 if number > 1
  end

  def next_page
    number + 1 if number < total_pages
  end
end
