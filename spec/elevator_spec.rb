require 'elevator.rb'

describe Elevator do
  describe "upon #initialize" do
    subject { Elevator.new(1) }
    it "@id is set to the passed argument" do
      expect(subject.id).to eq(1)
    end

    it "@destination_queue is an empty array" do
      expect(subject.destination_queue).to be_an Array
      expect(subject.destination_queue).to be_empty
    end

    it "is on the first floor" do
      expect(subject.current_floor).to eq(1)
    end

    it "is not moving" do
      expect(subject.direction).to eq(:stopped)
    end
  end

  describe "#in_use?" do
    let(:elevator) { Elevator.new(1) }

    it "returns false if the elevator is stopped" do
      elevator.instance_variable_set("@direction", :stopped)
      expect(elevator.in_use?).to eq(false)
    end

    it "returns true if the elevator is going down" do
      elevator.instance_variable_set("@direction", :down)
      expect(elevator.in_use?).to eq(true)
    end

    it "returns true if the elevator is going up" do
      elevator.instance_variable_set("@direction", :up)
      expect(elevator.in_use?).to eq(true)
    end
  end

  describe "#stopped?" do
    let(:elevator) { Elevator.new(1) }

    it "returns true if the elevator is stopped" do
      elevator.instance_variable_set("@direction", :stopped)
      expect(elevator.stopped?).to eq(true)
    end

    it "returns false if the elevator is going down" do
      elevator.instance_variable_set("@direction", :down)
      expect(elevator.stopped?).to eq(false)
    end

    it "returns false if the elevator is going up" do
      elevator.instance_variable_set("@direction", :up)
      expect(elevator.stopped?).to eq(false)
    end
  end

  describe "#add_floor_to_destination_queue" do
    let(:elevator) { Elevator.new(1) }

    it "adds to the secondary queue if the requested floor is in the wrong direction" do
      elevator.instance_variable_set("@direction", :down)
      elevator.instance_variable_set("@destination_queue", [3, 2, 1])
      elevator.instance_variable_set("@current_floor", 4)
      destination_floor = 5
      elevator.add_floor_to_destination_queue(5)
      expect(elevator.destination_queue).to eq([3, 2, 1])
      expect(elevator.secondary_queue).to eq([5])
    end

    it "inserts the requested floor and sorts the queue ascending if the elevator is going up" do
      elevator.instance_variable_set("@direction", :up)
      elevator.instance_variable_set("@destination_queue", [2, 4])
      elevator.instance_variable_set("@current_floor", 1)
      elevator.add_floor_to_destination_queue(3)
      expect(elevator.destination_queue).to eq([2, 3, 4])
    end

    it "inserts the requested floor and sorts the queue descending if the elevator is going down" do
      elevator.instance_variable_set("@direction", :down)
      elevator.instance_variable_set("@destination_queue", [3, 1])
      elevator.instance_variable_set("@current_floor", 5)
      elevator.add_floor_to_destination_queue(2)
      expect(elevator.destination_queue).to eq([3, 2, 1])
    end
  end

  describe "#set_direction" do
    let(:elevator) { Elevator.new(1) }

    it "stays put if it's already at the destination floor" do
      elevator.instance_variable_set("@current_floor", 3)
      elevator.send(:set_direction, 3)
      expect(elevator.direction).to eq(:stopped)
    end

    it "returns :down if the destination is below" do
      elevator.instance_variable_set("@current_floor", 3)
      elevator.send(:set_direction, 1)
      expect(elevator.direction).to eq(:down)
    end

    it "returns :up if the destination is above" do
      elevator.instance_variable_set("@current_floor", 3)
      elevator.send(:set_direction, 50)
      expect(elevator.direction).to eq(:up)
    end
  end

  describe "#eligible_for_pickup?" do
    let(:elevator) { Elevator.new(1) }

    context "when the elevator is not in use" do
      it "returns true" do
        elevator.instance_variable_set("@direction", :stopped)
        requested_direction = :up
        requested_floor     = 3
        expect(elevator.eligible_for_pickup?(requested_direction, requested_floor)).to eq(true)
      end
    end

    context "when the elevator is in use" do
      it "returns false if the elevator's direction and the requested direction don't match" do
        elevator.instance_variable_set("@direction", :up)
        requested_direction = :down
        requested_floor     = 3
        expect(elevator.eligible_for_pickup?(requested_direction, requested_floor)).to eq(false)
      end

      it "returns true if it's moving towards the request" do
        elevator.instance_variable_set("@direction", :up)
        elevator.instance_variable_set("@current_floor", 2)
        requested_direction = :up
        requested_floor     = 3
        expect(elevator.eligible_for_pickup?(requested_direction, requested_floor)).to eq(true)
      end

      it "returns false if it's not moving towards the request" do
        elevator.instance_variable_set("@direction", :up)
        elevator.instance_variable_set("@current_floor", 4)
        requested_direction = :up
        requested_floor     = 3
        expect(elevator.eligible_for_pickup?(requested_direction, requested_floor)).to eq(false)
      end
    end
  end

  describe "#perform_moves" do
    let(:elevator) { Elevator.new(1) }

    it "goes through the destination queue until it's empty" do
      elevator.instance_variable_set("@destination_queue", [2, 3, 4])
      elevator.perform_moves
      expect(elevator.current_floor).to eq(4)
      expect(elevator.destination_queue).to be_empty
    end
  end

  describe "#stop_at_current_floor" do
    let(:elevator) { Elevator.new(1) }

    it "shifts the first element off the destination queue" do
      elevator.instance_variable_set("@destination_queue", [1, 2])
      elevator.send(:stop_at_current_floor)
      expect(elevator.destination_queue).to eq([2])
    end
  end
end