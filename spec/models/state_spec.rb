require 'spec_helper'

describe State do

  context "validations" do 
    it { should have_valid_factory(:state) }
    it { should belong_to(:country) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:country) }

    it { should allow_mass_assignment_of :name }
    it { should allow_mass_assignment_of :name_ascii }
    it { should allow_mass_assignment_of :abbr }
    it { should allow_mass_assignment_of :code }
  end

  before(:all) do
    State.destroy_all
  end

  it "can find a state by name or abbr" do
    state = Factory(:state, :name => "California", :abbr => "CA")
    State.find_all_by_name_or_abbr("California").should include(state)
    State.find_all_by_name_or_abbr("CA").should include(state)
  end

  it "can find all states group by country numcode" do
    state = Factory(:state)
    State.states_group_by_country_numcode.should == { state.country_numcode.to_s => [[state.id, state.name]] }
  end
end
