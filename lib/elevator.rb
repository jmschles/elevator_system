class Elevator
  attr_reader   :current_floor, :destination_queue, :direction, :secondary_queue, :id

  # @current_floor and @direction would be updated by an external API,
  # assuming the elevators are telling us their status somehow
  # For now, we're moving/updating the elevators ourselves
  # (see #move_one_floor and #stop_at_current_floor)
  def initialize(id)
    @id                = id
    @destination_queue = []
    @secondary_queue   = []
    @current_floor     = 1
    @direction         = :stopped
  end

  # Adds a new destination to the queue, then reorders the queue
  def add_floor_to_destination_queue(destination_floor)
    if valid_primary_destination?(destination_floor)
      @destination_queue.push(destination_floor)
      sort_destination_queue
    else
      @secondary_queue.push(destination_floor)
    end
  end

  def eligible_for_pickup?(requested_direction, requested_floor)
    return true unless in_use?
    return false unless @direction == requested_direction
    moving_toward_request?(requested_floor)
  end

  def in_use?
    @direction != :stopped
  end

  # Empties out the destination queue, one stop at a time
  # Empties the secondary queue afterwards if
  # Stops the elevator when the queues are empty
  def perform_moves
    set_direction(next_destination)
    # if we're stopped, it means we're already at our next destination
    stopped? ? stop_at_current_floor : move_to_next_destination
    if @destination_queue.empty?
      if @secondary_queue.empty?
        stop_moving
      else
        switch_direction
        switch_to_secondary_queue
        sort_destination_queue
        perform_moves
      end
    else
      perform_moves
    end
  end

  def stopped?
    @direction == :stopped
  end

  private

  def set_direction(destination_floor)
    @direction =
      case @current_floor <=> destination_floor
      when -1
        :up
      when 1
        :down
      else
        :stopped
      end
  end

  def going_down?
    @direction == :down
  end

  def going_up?
    @direction == :up
  end

  # OPTIMIZE: run this in its own thread, so the system could
  # continue to run while elevators are moving.
  # Wrapping this method in a Thread.new block won't work, because the calling code
  # won't wait for it to finish
  def move_one_floor
    sleep 0.5
    @direction == :up ? @current_floor += 1 : @current_floor -= 1
  end

  def move_to_next_destination
    move_one_floor until @current_floor == next_destination
    stop_at_current_floor
  end

  def moving_toward_request?(requested_floor)
    (going_up? && requested_floor >= @current_floor) || (going_down? && requested_floor <= @current_floor)
  end

  def next_destination
    @destination_queue.first
  end

  def sort_destination_queue
    @destination_queue.sort!
    @destination_queue.reverse! if @direction == :down
  end

  # OPTIMIZE: run this in its own thread, so the system could
  # continue to run while elevators are moving.
  def stop_at_current_floor
    @destination_queue.shift
    sleep 1
  end

  def stop_moving
    @direction = :stopped
  end

  def switch_direction
    return if @direction == :stopped
    @direction = (@direction == :up ? :down : :up)
  end

  def switch_to_secondary_queue
    @destination_queue = @secondary_queue.dup
    @secondary_queue   = []
  end

  def valid_primary_destination?(requested_floor)
    return true unless in_use?
    moving_toward_request?(requested_floor)
  end
end