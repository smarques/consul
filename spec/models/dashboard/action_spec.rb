require 'rails_helper'

describe Dashboard::Action do
  subject do 
    build :dashboard_action, 
          title: title, 
          description: description,
          day_offset: day_offset,
          required_supports: required_supports,
          request_to_administrators: request_to_administrators,
          action_type: action_type
  end

  let(:title) { Faker::Lorem.sentence }
  let(:description) { Faker::Lorem.sentence }
  let(:day_offset) { 0 }
  let(:required_supports) { 0 }
  let(:request_to_administrators) { true }
  let(:action_type) { 'resource' }

  it 'is invalid when title is blank' do
    action = build(:dashboard_action, title: '')
    expect(action).not_to be_valid
  end

  it 'is invalid when title is too short' do
    action = build(:dashboard_action, title: 'abc')
    expect(action).not_to be_valid
  end

  it 'is invalid when title is too long' do
    action = build(:dashboard_action, title: 'a' * 81)
    expect(action).not_to be_valid
  end

  it 'is invalid when day_offset is not defined' do
    action = build(:dashboard_action, day_offset: nil)
    expect(action).not_to be_valid
  end

  it 'is invalid when day_offset is negative' do
    action = build(:dashboard_action, day_offset: -1)
    expect(action).not_to be_valid
  end

  it 'is invalid when day_offset not an integer' do
    action = build(:dashboard_action, day_offset: 1.23)
    expect(action).not_to be_valid
  end

  it 'is invalid when required_supports is nil' do
    action = build(:dashboard_action, required_supports: nil)
    expect(action).not_to be_valid
  end

  it 'is invalid when required_supports is negative' do
    action = build(:dashboard_action, required_supports: -1)
    expect(action).not_to be_valid
  end

  it 'is invalid when required_supports is not an integer' do
    action = build(:dashboard_action, required_supports: 1.23)
    expect(action).not_to be_valid
  end

  it 'is invalid when action_type is nil' do
    action = build(:dashboard_action, action_type: nil)
    expect(action).not_to be_valid
  end

  context '#active_for?' do
    it 'is active when required supports is 0 and day_offset is 0' do
      action = build(:dashboard_action, required_supports: 0, day_offset: 0)
      proposal = build(:proposal)

      expect(action).to be_active_for(proposal)
    end

    it 'is active when published after day_offset' do
      action = build(:dashboard_action, required_supports: 0, day_offset: 10)
      proposal = build(:proposal, published_at: Time.current - 10.days)
      
      expect(action).to be_active_for(proposal)
    end

    it 'is active when have enough supports' do
      action = build(:dashboard_action, required_supports: 10, day_offset: 0)
      proposal = build(:proposal, cached_votes_up: 10)

      expect(action).to be_active_for(proposal)
    end

    it 'is not active when not enough time published' do
      action = build(:dashboard_action, required_supports: 0, day_offset: 10)
      proposal = build(:proposal, published_at: Time.current - 9.days)
      
      expect(action).not_to be_active_for(proposal)
    end

    it 'is not active when not enough supports' do
      action = build(:dashboard_action, required_supports: 10, day_offset: 0)
      proposal = build(:proposal, cached_votes_up: 9)

      expect(action).not_to be_active_for(proposal)
    end
  end

  context '#requested_for?' do
    it 'is not requested when no administrator task' do
      proposal = create(:proposal)
      action = create(:dashboard_action, :active, :admin_request, :resource)

      expect(action).not_to be_requested_for(proposal)
    end

    it 'is requested when administrator task' do
      proposal = create(:proposal)
      action = create(:dashboard_action, :active, :admin_request, :resource)
      executed_action = create(:dashboard_executed_action, proposal: proposal, action: action)
      _task = create(:dashboard_administrator_task, :pending, source: executed_action)

      expect(action).to be_requested_for(proposal)
    end
  end

  context '#executed_for?' do
    it 'is not executed when no administrator task' do
      proposal = create(:proposal)
      action = create(:dashboard_action, :active, :admin_request, :resource)

      expect(action).not_to be_executed_for(proposal)
    end

    it 'is not executed when pending administrator task' do
      proposal = create(:proposal)
      action = create(:dashboard_action, :active, :admin_request, :resource)
      executed_action = create(:dashboard_executed_action, proposal: proposal, action: action)
      _task = create(:dashboard_administrator_task, :pending, source: executed_action)

      expect(action).not_to be_executed_for(proposal)
    end

    it 'is executed when done administrator task' do
      proposal = create(:proposal)
      action = create(:dashboard_action, :active, :admin_request, :resource)
      executed_action = create(:dashboard_executed_action, proposal: proposal, action: action)
      _task = create(:dashboard_administrator_task, :done, source: executed_action)

      expect(action).to be_executed_for(proposal)
    end
  end

  context '#active_for' do
    let!(:active_action) { create :dashboard_action, :active, day_offset: 0, required_supports: 0 }
    let!(:not_enough_supports_action) { create :dashboard_action, :active, day_offset: 0, required_supports: 10_000 }
    let!(:inactive_action) { create :dashboard_action, :inactive }
    let!(:future_action) { create :dashboard_action, :active, day_offset: 300, required_supports: 0 }
    let(:proposal) { create :proposal }

    it 'actions with enough supports or days are active' do
      expect(described_class.active_for(proposal)).to include(active_action)
    end

    it 'inactive actions are not included' do
      expect(described_class.active_for(proposal)).not_to include(inactive_action)
    end

    it 'actions without enough supports are not active' do
      expect(described_class.active_for(proposal)).not_to include(not_enough_supports_action)
    end

    it 'actions planned to be active in the future are not active' do
      expect(described_class.active_for(proposal)).not_to include(future_action)
    end 
  end

  context '#course_for' do
    let!(:proposed_action) { create :dashboard_action, :active, required_supports: 0 }
    let!(:inactive_resource) { create :dashboard_action, :inactive, :resource, required_supports: 0 }
    let!(:resource) { create :dashboard_action, :active, :resource, required_supports: 10_000 }
    let!(:achieved_resource) { create :dashboard_action, :active, :resource, required_supports: 0 }
    let(:proposal) { create :proposal }

    it "proposed actions are not part of proposal's course" do
      expect(described_class.course_for(proposal)).not_to include(proposed_action)
    end

    it "inactive resources are not part of proposal's course" do
      expect(described_class.course_for(proposal)).not_to include(inactive_resource)
    end

    it "achievements are not part of the proposal's course" do
      expect(described_class.course_for(proposal)).not_to include(achieved_resource)
    end

    it "active resources are part of proposal's course" do
      expect(described_class.course_for(proposal)).to include(resource)
    end
  end
end
