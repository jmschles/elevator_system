class Elevator
  attr_reader :id, :floor, :direction

  def initialize(id)
    @id        = id
    @floor     = 1
    @direction = nil
  end
end