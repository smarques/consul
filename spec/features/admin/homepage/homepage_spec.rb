require 'rails_helper'

feature 'Homepage' do

  background do
    admin = create(:administrator).user
    login_as(admin)

    Setting['feature.homepage.widgets.feeds.proposals'] = false
    Setting['feature.homepage.widgets.feeds.debates'] = false
    Setting['feature.homepage.widgets.feeds.processes'] = false
    Setting['feature.user.recommendations'] = false
  end

  let(:proposals_setting)    { Setting.where(key: 'feature.homepage.widgets.feeds.proposals').first }
  let(:debates_setting)      { Setting.where(key: 'feature.homepage.widgets.feeds.debates').first }
  let(:processes_setting)    { Setting.where(key: 'feature.homepage.widgets.feeds.processes').first }
  let(:user_recommendations) { Setting.where(key: 'feature.user.recommendations').first }
  let(:user)                 { create(:user) }

  scenario "Header" do
  end

  context "Feeds" do

    scenario "Proposals" do
      5.times { create(:proposal) }

      visit admin_homepage_path
      within("#setting_#{proposals_setting.id}") do
        click_button "Enable"
      end

      expect(page).to have_content "Value updated"

      visit root_path

      expect(page).to have_content "Most active proposals"
      expect(page).to have_css(".proposal", count: 3)
    end

    scenario "Debates" do
      5.times { create(:debate) }

      visit admin_homepage_path
      within("#setting_#{debates_setting.id}") do
        click_button "Enable"
      end

      expect(page).to have_content "Value updated"

      visit root_path

      expect(page).to have_content "Most active debates"
      expect(page).to have_css(".debate", count: 3)
    end

    scenario "Processes" do
      5.times { create(:legislation_process) }

      visit admin_homepage_path
      within("#setting_#{processes_setting.id}") do
        click_button "Enable"
      end

      expect(page).to have_content "Value updated"

      visit root_path

      expect(page).to have_content "Most active processes"
      expect(page).to have_css(".legislation_process", count: 3)
    end

    xscenario "Deactivate"

  end

  scenario "Cards" do
    card1 = create(:widget_card, label: "Card1 label",
                                 title: "Card1 text",
                                 description: "Card1 description",
                                 link_text: "Link1 text",
                                 link_url: "consul1.dev")

    card2 = create(:widget_card, label: "Card2 label",
                                 title: "Card2 text",
                                 description: "Card2 description",
                                 link_text: "Link2 text",
                                 link_url: "consul2.dev")

    visit root_path

    expect(page).to have_css(".card", count: 2)

    within("#widget_card_#{card1.id}") do
      expect(page).to have_content("Card1 label")
      expect(page).to have_content("Card1 text")
      expect(page).to have_content("Card1 description")
      expect(page).to have_content("Link1 text")
      expect(page).to have_link(href: "consul1.dev")
      expect(page).to have_css("img[alt='#{card1.image.title}']")
    end

    within("#widget_card_#{card2.id}") do
      expect(page).to have_content("Card2 label")
      expect(page).to have_content("Card2 text")
      expect(page).to have_content("Card2 description")
      expect(page).to have_content("Link2 text")
      expect(page).to have_link(href: "consul2.dev")
      expect(page).to have_css("img[alt='#{card2.image.title}']")
    end
  end

  scenario "Recomendations" do
    proposal1 = create(:proposal, tag_list: "Sport")
    proposal2 = create(:proposal, tag_list: "Sport")
    create(:follow, followable: proposal1, user: user)

    visit admin_homepage_path
    within("#setting_#{user_recommendations.id}") do
      click_button "Enable"
    end

    expect(page).to have_content "Value updated"

    login_as(user)
    visit root_path

    expect(page).to have_content("Recommendations that may interest you")
  end

end