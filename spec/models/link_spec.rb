require 'rails_helper'

describe Link do
  subject do 
    build :link,
          linkable: proposal_dashboard_action, 
          label: label,
          url: url,
          open_in_new_tab: true 
  end

  let(:proposal_dashboard_action) { build :proposal_dashboard_action }
  let(:label) { Faker::Lorem.sentence }
  let(:url) { Faker::Internet.url }

  it { should be_valid }

  context 'when label is blank' do
    let(:label) { '' }

    it { should_not be_valid }
  end

  context 'when url is blank' do
    let(:url) { '' }

    it { should_not be_valid }
  end
end
