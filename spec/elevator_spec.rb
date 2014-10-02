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

    it "warns and returns if the requested floor is in the wrong direction" do
      elevator.instance_variable_set("@direction", :down)
      elevator.instance_variable_set("@destination_queue", [3, 2, 1])
      elevator.instance_variable_set("@current_floor", 4)
      destination_floor = 5
      expect(elevator).to receive(:warn).with("Cannot go to floor #{destination_floor}: elevator moving wrong way")
      elevator.add_floor_to_destination_queue(5)
      expect(elevator.destination_queue).to eq([3, 2, 1])
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
end