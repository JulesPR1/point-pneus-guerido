# Keeps an ordered list inside a parent record: sections inside a page, items
# inside a section. The order lives in the `position` column so the public site
# can sort in SQL rather than in Ruby.
module Positionable
  extend ActiveSupport::Concern

  included do
    scope :ordered, -> { order(:position, :id) }
    before_validation :assign_position, on: :create
  end

  class_methods do
    # positioned_within :page, list: :sections
    def positioned_within(parent, list:)
      define_method(:positionable_parent) { public_send(parent) }
      define_method(:positionable_siblings) do
        positionable_parent ? positionable_parent.public_send(list) : self.class.none
      end
    end

    # Applies an explicit order (drag & drop). Ids outside the list are left alone.
    def reposition!(scope, ordered_ids)
      by_id = scope.where(id: ordered_ids).index_by(&:id)
      transaction do
        ordered_ids.map(&:to_i).each_with_index do |id, index|
          by_id[id]&.update_column(:position, index)
        end
      end
    end
  end

  def move_up!   = swap_with(previous_sibling)
  def move_down! = swap_with(next_sibling)

  def first? = previous_sibling.nil?
  def last?  = next_sibling.nil?

  private
    def siblings = positionable_siblings.where.not(id: id)

    def previous_sibling = siblings.where(position: ...position).order(position: :desc, id: :desc).first
    def next_sibling     = siblings.where("position > ?", position).order(:position, :id).first

    def swap_with(other)
      return false if other.nil?

      self.class.transaction do
        mine, theirs = position, other.position
        theirs += 1 if mine == theirs
        other.update_column(:position, mine)
        update_column(:position, theirs)
      end
      true
    end

    def assign_position
      return if position.to_i.positive?

      self.position = (positionable_siblings.maximum(:position) || -1) + 1
    end
end
