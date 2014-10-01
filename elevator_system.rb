require './elevator.rb'

class ElevatorSystem
  attr_reader :elevators, :floors

  def initialize(elevators, floors)
    @elevators = (1..elevators).map { |id| Elevator.new(id) }
    @floors    = floors
  end
end