class Elevator
  attr_reader   :current_floor, :id, :direction
  attr_accessor :destination_queue

  def initialize(id)
    @id                = id
    @current_floor     = 1
    @destination_queue = []
    @direction         = :stopped
  end

  def add_floor_to_destination_queue(destination_floor)
    unless valid_destination(destination_floor)
      warn "Cannot go to floor #{destination_floor}: elevator moving wrong way"
      return
    end
    @destination_queue.push(destination_floor)
    @destination_queue.sort!
    @destination_queue.reverse! if going_down?
  end

  def eligible_for_pickup?(requested_direction, requested_floor)
    return true unless in_use?
    return false unless @direction == requested_direction
    return true if moving_in_right_direction?(requested_floor)
    false
  end

  def in_use?
    @direction != :stopped
  end

  def perform_moves
    @direction = determine_direction(next_destination)
    stop_at_current_floor if stopped?   # already at next destination
    move_to_next_destination
    if @destination_queue.empty?
      @direction = :stopped
    else
      perform_moves
    end
  end

  def stopped?
    @direction == :stopped
  end

  private

  def determine_direction(destination_floor)
    return nil if @current_floor == destination_floor
    (@current_floor < destination_floor) ? :up : :down
  end

  def going_down?
    @direction == :down
  end

  def going_up?
    @direction == :up
  end

  def move_one_floor
    Thread.new do
      sleep 1.5
      @direction == :up ? @current_floor += 1 : @current_floor -= 1
    end
  end

  def move_to_next_destination
    move_one_floor until @current_floor == next_destination
    stop_at_current_floor
  end

  def moving_in_right_direction?(requested_floor)
    (going_up? && requested_floor > @current_floor) || (going_down? && requested_floor < @current_floor)
  end

  def next_destination
    @destination_queue.first
  end

  def stop_at_current_floor
    puts "Ding! Elevator #{@id} arriving at floor #{@destination_queue.last}"
    @destination_queue.pop
  end

  def valid_destination?(requested_floor)
    return true unless in_use?
    moving_in_right_direction?(requested_floor)
  end
end