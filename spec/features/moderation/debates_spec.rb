require "rails_helper"

describe "Moderate debates" do
  scenario "Disabled with a feature flag" do
    Setting["process.debates"] = nil
    moderator = create(:moderator)
    login_as(moderator.user)

    expect { visit moderation_debates_path }.to raise_exception(FeatureFlags::FeatureDisabled)
  end

  scenario "Hide", :js do
    citizen = create(:user)
    moderator = create(:moderator)

    debate = create(:debate)

    login_as(moderator.user)
    visit debate_path(debate)

    within("#debate_#{debate.id}") do
      accept_confirm { click_link "Hide" }
    end

    expect(find("div#debate_#{debate.id}.faded")).to have_text debate.title

    login_as(citizen)
    visit debates_path

    expect(page).to have_css(".debate", count: 0)
  end

  scenario "Can not hide own debate" do
    moderator = create(:moderator)
    debate = create(:debate, author: moderator.user)

    login_as(moderator.user)
    visit debate_path(debate)

    within("#debate_#{debate.id}") do
      expect(page).not_to have_link("Hide")
      expect(page).not_to have_link("Block author")
    end
  end

  describe "/moderation/ screen" do
    before do
      moderator = create(:moderator)
      login_as(moderator.user)
    end

    describe "moderate in bulk" do
      describe "When a debate has been selected for moderation" do
        let!(:debate) { create(:debate) }

        before do
          visit moderation_debates_path
          within(".menu.simple") do
            click_link "All"
          end

          within("#debate_#{debate.id}") do
            check "debate_#{debate.id}_check"
          end

          expect(page).not_to have_css("debate_#{debate.id}")
        end

        scenario "Hide the debate" do
          click_on "Hide debates"
          expect(page).not_to have_css("debate_#{debate.id}")
          expect(debate.reload).to be_hidden
          expect(debate.author).not_to be_hidden
        end

        scenario "Block the author" do
          click_on "Block authors"
          expect(page).not_to have_css("debate_#{debate.id}")
          expect(debate.reload).to be_hidden
          expect(debate.author).to be_hidden
        end

        scenario "Ignore the debate" do
          click_on "Mark as viewed"
          expect(page).not_to have_css("debate_#{debate.id}")
          expect(debate.reload).to be_ignored_flag
          expect(debate.reload).not_to be_hidden
          expect(debate.author).not_to be_hidden
        end
      end

      scenario "select all/none", :js do
        create_list(:debate, 2)

        visit moderation_debates_path

        within(".js-check") { click_on "All" }

        expect(all("input[type=checkbox]")).to all(be_checked)

        within(".js-check") { click_on "None" }

        all("input[type=checkbox]").each do |checkbox|
          expect(checkbox).not_to be_checked
        end
      end

      scenario "remembering page, filter and order" do
        create_list(:debate, 52)

        visit moderation_debates_path(filter: "all", page: "2", order: "created_at")

        click_on "Mark as viewed"

        expect(page).to have_selector(".js-order-selector[data-order='created_at']")

        expect(current_url).to include("filter=all")
        expect(current_url).to include("page=2")
        expect(current_url).to include("order=created_at")
      end
    end

    scenario "Current filter is properly highlighted" do
      visit moderation_debates_path
      expect(page).not_to have_link("Pending")
      expect(page).to have_link("All")
      expect(page).to have_link("Marked as viewed")

      visit moderation_debates_path(filter: "all")
      within(".menu.simple") do
        expect(page).not_to have_link("All")
        expect(page).to have_link("Pending")
        expect(page).to have_link("Marked as viewed")
      end

      visit moderation_debates_path(filter: "pending_flag_review")
      within(".menu.simple") do
        expect(page).to have_link("All")
        expect(page).not_to have_link("Pending")
        expect(page).to have_link("Marked as viewed")
      end

      visit moderation_debates_path(filter: "with_ignored_flag")
      within(".menu.simple") do
        expect(page).to have_link("All")
        expect(page).to have_link("Pending")
        expect(page).not_to have_link("Marked as viewed")
      end
    end

    scenario "Filtering debates" do
      create(:debate, title: "Regular debate")
      create(:debate, :flagged, title: "Pending debate")
      create(:debate, :hidden, title: "Hidden debate")
      create(:debate, :flagged, :with_ignored_flag, title: "Ignored debate")

      visit moderation_debates_path(filter: "all")
      expect(page).to have_content("Regular debate")
      expect(page).to have_content("Pending debate")
      expect(page).not_to have_content("Hidden debate")
      expect(page).to have_content("Ignored debate")

      visit moderation_debates_path(filter: "pending_flag_review")
      expect(page).not_to have_content("Regular debate")
      expect(page).to have_content("Pending debate")
      expect(page).not_to have_content("Hidden debate")
      expect(page).not_to have_content("Ignored debate")

      visit moderation_debates_path(filter: "with_ignored_flag")
      expect(page).not_to have_content("Regular debate")
      expect(page).not_to have_content("Pending debate")
      expect(page).not_to have_content("Hidden debate")
      expect(page).to have_content("Ignored debate")
    end

    scenario "sorting debates" do
      flagged_debate = create(:debate, title: "Flagged debate", created_at: Time.current - 1.day, flags_count: 5)
      flagged_new_debate = create(:debate, title: "Flagged new debate", created_at: Time.current - 12.hours, flags_count: 3)
      newer_debate = create(:debate, title: "Newer debate", created_at: Time.current)

      visit moderation_debates_path(order: "created_at")

      expect(flagged_new_debate.title).to appear_before(flagged_debate.title)

      visit moderation_debates_path(order: "flags")

      expect(flagged_debate.title).to appear_before(flagged_new_debate.title)

      visit moderation_debates_path(filter: "all", order: "created_at")

      expect(newer_debate.title).to appear_before(flagged_new_debate.title)
      expect(flagged_new_debate.title).to appear_before(flagged_debate.title)

      visit moderation_debates_path(filter: "all", order: "flags")

      expect(flagged_debate.title).to appear_before(flagged_new_debate.title)
      expect(flagged_new_debate.title).to appear_before(newer_debate.title)
    end
  end
end
