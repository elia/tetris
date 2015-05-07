require 'color'
require 'forwardable'
class Piece
  extend Forwardable
  ORIGIN_X = 2
  ORIGIN_Y = 2
  NUM_COLORS = 20
  attr_reader :position, :color, :bitmask, :locked
  def_delegators :bitmask, :rotate, :unrotate

  def initialize(bitmask:, position: [5,0], locked: false, color: nil)
    @bitmask  = bitmask
    @locked   = locked
    @position = position
    @color    = color || self.class.palette.sample
  end

  def self.palette
    @colors ||= (1..NUM_COLORS).map { Color.new }
  end

  def x
    position[0]
  end

  def y
    position[1]
  end

  def position=(new_position)
    @position = new_position if unlocked? && legal_move?(new_position)
  end

  def current_bitmask
    bitmask.dup
  end

  def legal_move?(position)
    allowed = true
    proposed_piece = Piece.new(position: position, bitmask: current_bitmask)
    proposed_piece.occupied_coordinates do |occ_x, occ_y|
      next unless !Board.valid_x_y?(occ_x,occ_y)
      allowed = false
    end
    allowed
  end


  def current_position
    position.dup
  end

  def unlocked?
    !locked?
  end

  def lock
    @locked = true
  end
  alias_method  :lock!, :lock
  alias_method  :locked?, :locked

  def descend
    @position[1] += 1 unless locked?
  end

  def occupied_coordinates
    return enum_for(:occupied_coordinates) unless block_given?
    ((x - 2)...(x + 2)).each do |x1|
      ((y - 2)...(y + 2)).each do |y1|
        yield [x1,y1] if bitmask.occupy?(x1 - x + ORIGIN_X, y1 - y + ORIGIN_Y)
      end
    end
  end

  def occupy?(x, y)
    mask_x = x - position[0] + ORIGIN_X
    mask_y = y - position[1] + ORIGIN_Y
    if !Board.valid_x_y?(x,y)
      true #shortcut to avoid testing out of bounds squares
    elsif Bitmask.valid_mask_x_y?(mask_x,mask_y)
      bitmask.occupy?(mask_x, mask_y)
    end
  end
end