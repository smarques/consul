require "rails_helper"

describe Poll::Officer do

  describe "#name" do
    let(:officer) { create(:poll_officer) }

    it "returns user name if user is not deleted" do
      expect(officer.name).to eq officer.user.name
    end

    it "returns 'User deleted' if user is deleted" do
      officer.user.destroy

      expect(officer.reload.name).to eq "User deleted"
    end
  end

  describe "#email" do
    let(:officer) { create(:poll_officer) }

    it "returns user email if user is not deleted" do
      expect(officer.email).to eq officer.user.email
    end

    it "returns 'Email deleted' if user is deleted" do
      officer.user.destroy

      expect(officer.reload.email).to eq "Email deleted"
    end
  end

  describe "#voting_days_assigned_polls" do
    it "returns all polls with this officer assigned during voting days" do
      officer = create(:poll_officer)

      poll_1 = create(:poll)
      poll_2 = create(:poll)
      poll_3 = create(:poll)

      create(:poll_officer_assignment, poll: poll_1, officer: officer, date: poll_1.starts_at)
      create(:poll_officer_assignment, poll: poll_1, officer: officer, date: poll_1.ends_at)
      create(:poll_officer_assignment, poll: poll_2, officer: officer)
      create(:poll_officer_assignment, poll: poll_3, officer: officer, final: true)

      assigned_polls = officer.voting_days_assigned_polls

      expect(assigned_polls).to match_array [poll_1, poll_2]
    end

    it "does not return polls with this officer assigned for final recount/results" do
      officer = create(:poll_officer)

      poll_1 = create(:poll)
      poll_2 = create(:poll)

      create(:poll_officer_assignment, poll: poll_1, officer: officer, date: poll_1.starts_at)
      create(:poll_officer_assignment, poll: poll_2, officer: officer, final: true)

      assigned_polls = officer.voting_days_assigned_polls

      expect(assigned_polls).to eq [poll_1]
    end

    it "returns polls ordered by end date (desc)" do
      officer = create(:poll_officer)

      poll_1 = create(:poll, ends_at: 1.day.ago)
      poll_2 = create(:poll, ends_at: 10.days.from_now)
      poll_3 = create(:poll, ends_at: 10.days.ago)

      [poll_1, poll_2, poll_3].each do |poll|
        create(:poll_officer_assignment, officer: officer, poll: poll)
      end

      assigned_polls = officer.voting_days_assigned_polls

      expect(assigned_polls.first).to eq(poll_2)
      expect(assigned_polls.second).to eq(poll_1)
      expect(assigned_polls.last).to eq(poll_3)
    end
  end

  describe "#final_days_assigned_polls" do
    it "returns all polls with this officer assigned for final recount/results" do
      officer = create(:poll_officer)

      poll_1 = create(:poll)
      poll_2 = create(:poll)
      poll_3 = create(:poll)

      create(:poll_officer_assignment, poll: poll_1, officer: officer, date: poll_1.starts_at, final: true)
      create(:poll_officer_assignment, poll: poll_1, officer: officer, date: poll_1.ends_at, final: true)
      create(:poll_officer_assignment, poll: poll_2, officer: officer, final: true)
      create(:poll_officer_assignment, poll: poll_3, officer: officer)

      assigned_polls = officer.final_days_assigned_polls

      expect(assigned_polls).to match_array [poll_1, poll_2]
    end

    it "does not return polls with this officer assigned for voting days" do
      officer = create(:poll_officer)

      poll_1 = create(:poll)
      poll_2 = create(:poll)

      create(:poll_officer_assignment, poll: poll_1, officer: officer, date: poll_1.starts_at)
      create(:poll_officer_assignment, poll: poll_2, officer: officer, final: true)

      assigned_polls = officer.final_days_assigned_polls

      expect(assigned_polls).to eq [poll_2]
    end

    it "returns polls ordered by end date (desc)" do
      officer = create(:poll_officer)

      poll_1 = create(:poll, ends_at: 1.day.ago)
      poll_2 = create(:poll, ends_at: 10.days.from_now)
      poll_3 = create(:poll, ends_at: 10.days.ago)

      [poll_1, poll_2, poll_3].each do |poll|
        create(:poll_officer_assignment, officer: officer, poll: poll, final: true)
      end

      assigned_polls = officer.final_days_assigned_polls

      expect(assigned_polls.first).to eq(poll_2)
      expect(assigned_polls.second).to eq(poll_1)
      expect(assigned_polls.last).to eq(poll_3)
    end
  end

  describe "todays_booths" do
    let(:officer) { create(:poll_officer) }

    it "returns booths for the application's time zone date", :with_different_time_zone do
      assignment_with_local_time_zone = create(:poll_officer_assignment,
                                               date:    Date.today,
                                               officer: officer)

      assignment_with_application_time_zone = create(:poll_officer_assignment,
                                                     date:    Date.current,
                                                     officer: officer)

      expect(officer.todays_booths).to include(assignment_with_application_time_zone.booth)
      expect(officer.todays_booths).not_to include(assignment_with_local_time_zone.booth)
    end
  end
end
