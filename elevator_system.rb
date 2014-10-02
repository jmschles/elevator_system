require './elevator.rb'

class ElevatorSystem
  attr_reader :elevators, :floors

  def initialize(num_elevators, floors)
    @elevators = (1..num_elevators).map { |id| Elevator.new(id) }
    @floors    = floors
  end

  # Called when someone requests an elevator
  def receive_call(requested_direction, requested_floor)
    elevator = find_closest_eligible_elevator(requested_direction, requested_floor)
    elevator.add_floor_to_destination_queue(requested_floor)
    elevator.perform_moves unless elevator.in_use?
  end

  # Called when someone pushes a button inside an elevator
  def receive_internal_request(elevator_id, requested_floor)
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
end