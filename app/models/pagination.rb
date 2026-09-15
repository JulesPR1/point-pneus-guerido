# Minimal offset pagination — enough for the two admin lists, no extra gem.
class Pagination
  PER_PAGE = 25

  attr_reader :page, :per_page, :total_count, :total_pages

  def initialize(scope, page:, per_page: PER_PAGE)
    @scope       = scope
    @per_page    = per_page
    counted      = scope.except(:select, :order, :limit, :offset).count
    @total_count = counted.is_a?(Hash) ? counted.size : counted
    @total_pages = [ (@total_count / per_page.to_f).ceil, 1 ].max
    @page        = page.to_i.clamp(1, @total_pages)
  end

  def records = @scope.limit(per_page).offset((page - 1) * per_page)

  def many? = total_pages > 1
  def first? = page == 1
  def last?  = page == total_pages
  def previous_page = page - 1
  def next_page = page + 1
  def range = ((page - 1) * per_page + 1)..[ page * per_page, total_count ].min
end
