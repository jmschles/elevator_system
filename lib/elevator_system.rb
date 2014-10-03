require_relative './elevator.rb'

class ElevatorSystem
  attr_reader :elevators, :floors

  def initialize(num_elevators, floors)
    @elevators = (1..num_elevators).map { |id| Elevator.new(id) }
    @floors    = floors
  end

  # Called when someone requests an elevator
  def receive_call(requested_direction, requested_floor)
    (invalid_direction_warning(requested_direction) and return) unless valid_direction?(requested_direction)
    (invalid_floor_warning(requested_floor) and return) unless valid_floor?(requested_floor)

    elevator = find_closest_eligible_elevator(requested_direction, requested_floor)
    elevator.add_floor_to_destination_queue(requested_floor)
    elevator.perform_moves unless elevator.in_use?
  end

  # Called when someone pushes a button inside an elevator
  def receive_internal_request(elevator_id, requested_floor)
    (invalid_elevator_warning(elevator_id) and return) unless valid_elevator_id?(elevator_id)
    (invalid_floor_warning(requested_floor) and return) unless valid_floor?(requested_floor)

    elevator = @elevators.detect { |e| e.id == elevator_id }
    elevator.add_floor_to_destination_queue(requested_floor)
    elevator.perform_moves unless elevator.in_use?
  end

  private

  def elevators_sorted_by_call_proximity(requested_floor)
    @elevators.sort_by { |e| (e.current_floor - requested_floor).abs }
  end

  # Finds the nearest elevator that's headed in the right direction or not in use
  # Runs in a loop until an eligible elevator is found
  # Should be threaded and on a timeout (1 second?) so it can run in the background
  # while the system processes other requests
  def find_closest_eligible_elevator(requested_direction, requested_floor)
    closest_eligible_elevator = elevators_sorted_by_call_proximity(requested_floor).detect do |e|
      e.eligible_for_pickup?(requested_direction, requested_floor)
    end
    if closest_eligible_elevator
      closest_eligible_elevator
    else
      find_closest_eligible_elevator(requested_direction, requested_floor)
    end
  end

  def invalid_direction_warning(requested_direction)
    warn "Elevator can only go up or down, ignoring request"
    true
  end

  def invalid_elevator_warning(elevator_id)
    warn "Elevator #{elevator_id} does not exist, ignoring request"
    true
  end

  def invalid_floor_warning(requested_floor)
    warn "Floor #{requested_floor} does not exist, ignoring request"
    true
  end

  def valid_direction?(requested_direction)
    %i[up down].include?(requested_direction)
  end

  def valid_elevator_id?(elevator_id)
    (1..@elevators.count).include?(elevator_id)
  end

  def valid_floor?(requested_floor)
    # no basements, for now
    (1..@floors).include?(requested_floor)
  end
end