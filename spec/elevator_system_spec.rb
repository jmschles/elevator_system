require 'elevator_system.rb'

describe ElevatorSystem do
  describe "#initialize" do
    subject { ElevatorSystem.new(3, 5) }

    it "has the correct number of floors" do
      expect(subject.floors).to eq(5)
    end

    it "has the right number of elevator objects in an array" do
      expect(subject.elevators).to be_an(Array)
      expect(subject.elevators.count).to eq(3)
      expect(subject.elevators.first).to be_an(Elevator)
    end
  end

  describe "#receive_call" do
    let(:system) { ElevatorSystem.new(2, 5) }

    it "finds an eligible elevator and sends it to the requested floor" do
      e1, e2 = system.elevators
      e2.instance_variable_set("@current_floor", 4)
      allow(e1).to receive(:eligible_for_pickup?).with(any_args).and_return(false)
      allow(e2).to receive(:eligible_for_pickup?).with(any_args).and_return(true)
      allow(e2).to receive(:perform_moves).with(any_args).and_return(nil)
      requested_floor = 2
      expect(e2).to receive(:add_floor_to_destination_queue).with(requested_floor)
      system.receive_call(:up, requested_floor)
    end
  end

  describe "#receive_internal_request" do
    let(:system) { ElevatorSystem.new(2, 5) }

    it "adds a floor to the queue of the correct elevator" do
      e1, e2 = system.elevators
      e1.instance_variable_set("@current_floor", 4)
      allow(e1).to receive(:eligible_for_pickup?).with(any_args).and_return(true)
      allow(e1).to receive(:perform_moves).with(any_args).and_return(nil)
      requested_floor = 2
      expect(e1).to receive(:add_floor_to_destination_queue).with(requested_floor)
      system.receive_internal_request(e1.id, requested_floor)
    end
  end

  describe "#elevators_sorted_by_call_proximity" do
    let(:system) { ElevatorSystem.new(3, 5) }

    it "sorts the system's elevators in ascending order of distance from the requested floor" do
      e1, e2, e3 = system.elevators
      e1.instance_variable_set("@current_floor", 2)
      e2.instance_variable_set("@current_floor", 4)
      e3.instance_variable_set("@current_floor", 5)
      expect(system.send(:elevators_sorted_by_call_proximity, 4)).to eq([e2, e3, e1])
    end
  end

  describe "#find_closest_eligible_elevator" do
    let(:system) { ElevatorSystem.new(3, 5) }

    context "when elevators are available" do
      it "returns the closest elevator that's able to do a pickup" do
        e1, e2, e3 = system.elevators
        e1.instance_variable_set("@current_floor", 5)
        e2.instance_variable_set("@current_floor", 2)
        e3.instance_variable_set("@current_floor", 1)
        allow(e1).to receive(:eligible_for_pickup?).with(any_args).and_return(false)
        allow(e2).to receive(:eligible_for_pickup?).with(any_args).and_return(true)
        allow(e3).to receive(:eligible_for_pickup?).with(any_args).and_return(true)
        expect(system.send(:find_closest_eligible_elevator, :up, 4)).to eq(e2)
      end
    end

    context "when no elevators are available" do
      it "loops until it finds an eligible elevator" do
        pending "NYI: threading required for this functionality"
        e1, e2, e3 = system.elevators
        e1.instance_variable_set("@current_floor", 5)
        e2.instance_variable_set("@current_floor", 2)
        e3.instance_variable_set("@current_floor", 1)
        allow(e1).to receive(:eligible_for_pickup?).with(any_args).and_return(false)
        allow(e2).to receive(:eligible_for_pickup?).with(any_args).and_return(false)
        allow(e3).to receive(:eligible_for_pickup?).with(any_args).and_return(false)
        eligible_elevator = system.send(:find_closest_eligible_elevator, :up, 4)
        sleep 1
        allow(e1).to receive(:eligible_for_pickup?).with(any_args).and_return(true)
        expect(eligible_elevator).to eq(e1)
      end
    end
  end
end