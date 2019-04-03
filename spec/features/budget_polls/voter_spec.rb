require "rails_helper"

feature "BudgetPolls", :with_frozen_time do
  let(:budget) { create(:budget, :balloting) }
  let(:group) { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group) }
  let(:investment) { create(:budget_investment, :selected, heading: heading) }
  let(:poll) { create(:poll, :current, budget: budget) }
  let(:booth) { create(:poll_booth) }
  let(:officer) { create(:poll_officer) }
  let(:admin) { create(:administrator) }

  background do
    create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)
    booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
    create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment, date: Date.current)
  end

  context "Offline" do
    scenario "A citizen can cast a paper vote", :js do
      user = create(:user, :in_census)

      login_through_form_as_officer(officer.user)

      visit new_officing_residence_path
      officing_verify_residence

      expect(page).to have_content poll.name

      within("#poll_#{poll.id}") do
        click_button("Confirm vote")
        expect(page).not_to have_button("Confirm vote")
        expect(page).to have_content "Vote introduced!"
      end

      expect(Poll::Voter.count).to eq(1)
      expect(Poll::Voter.first.origin).to eq("booth")

      visit root_path
      click_link "Sign out"
      login_as(admin.user)
      visit admin_poll_recounts_path(poll)

      within("#total_system") do
        expect(page).to have_content "1"
      end

      within("#poll_booth_assignment_#{Poll::BoothAssignment.where(poll: poll, booth: booth).first.id}_recounts") do
        expect(page).to have_content "1"
      end
    end

    scenario "A citizen cannot vote offline again", :js do
      user = create(:user, :in_census)

      login_through_form_as_officer(officer.user)

      visit new_officing_residence_path
      officing_verify_residence

      within("#poll_#{poll.id}") do
        click_button("Confirm vote")
      end

      visit new_officing_residence_path
      officing_verify_residence

      within("#poll_#{poll.id}") do
        expect(page).to have_content "Has already participated in this poll"
      end
    end

    scenario "A citizen cannot vote online after voting offline", :js do
      user = create(:user, :in_census)

      login_through_form_as_officer(officer.user)

      visit new_officing_residence_path
      officing_verify_residence

      within("#poll_#{poll.id}") do
        click_button("Confirm vote")
      end

      expect(page).to have_content "Vote introduced!"

      login_as(user)

      visit budget_investment_path(budget, investment)
      find("div.ballot").hover

      within("#budget_investment_#{investment.id}") do
        expect(page).to have_content "You have already participated offline"
        expect(page).to have_css(".add a", visible: false)
      end
    end
  end

  context "Online" do
    scenario "A citizen can cast vote online" do
      # Login as User
      # Cast a vote for an investment
    end

    scenario "A citizen cannot vote offline after voting online" do
      # create scenario for an user that voted online

      # Login as Poll Officer
      # Check the citizen cannot vote offline
    end

  end
end
