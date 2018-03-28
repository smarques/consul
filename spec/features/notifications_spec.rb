require 'rails_helper'

feature "Notifications" do

  let(:user) { create :user }

  background do
    login_as(user)
    visit root_path
  end

  scenario "View all" do
    read1 = create(:notification, :read, user: user)
    read2 = create(:notification, :read, user: user)
    unread = create(:notification, user: user)

    click_notifications_icon
    click_link "Read"

    expect(page).to have_css(".notification", count: 2)
    expect(page).to have_content(read1.notifiable_title)
    expect(page).to have_content(read2.notifiable_title)
    expect(page).to_not have_content(unread.notifiable_title)
  end

  scenario "View unread" do
    unread1 = create(:notification, user: user)
    unread2 = create(:notification, user: user)
    read = create(:notification, :read, user: user)

    click_notifications_icon
    click_link "Unread"

    expect(page).to have_css(".notification", count: 2)
    expect(page).to have_content(unread1.notifiable_title)
    expect(page).to have_content(unread2.notifiable_title)
    expect(page).to_not have_content(read.notifiable_title)
  end

  scenario "View single notification" do
    proposal = create(:proposal)
    notification = create(:notification, user: user, notifiable: proposal)

    click_notifications_icon

    first(".notification a").click
    expect(page).to have_current_path(proposal_path(proposal))

    visit notifications_path
    expect(page).to have_css ".notification", count: 0

    visit read_notifications_path
    expect(page).to have_css ".notification", count: 1
  end

  scenario "Mark as read", :js do
    notification1 = create(:notification, user: user)
    notification2 = create(:notification, user: user)

    click_notifications_icon

    within("#notification_#{notification1.id}") do
      click_link "Mark as read"
    end

    expect(page).to have_css(".notification", count: 1)
    expect(page).to have_content(notification2.notifiable_title)
    expect(page).to_not have_content(notification1.notifiable_title)
  end

  scenario "Mark all as read" do
    notification1 = create(:notification, user: user)
    notification2 = create(:notification, user: user)

    click_notifications_icon

    expect(page).to have_css(".notification", count: 2)
    click_link "Mark all as read"

    expect(page).to have_css(".notification", count: 0)
  end

  scenario "Mark as unread", :js do
    notification1 = create(:notification, :read, user: user)
    notification2 = create(:notification, user: user)

    click_notifications_icon
    click_link "Read"

    expect(page).to have_css(".notification", count: 1)
    within("#notification_#{notification1.id}") do
      click_link "Mark as unread"
    end

    expect(page).to have_css(".notification", count: 0)

    visit notifications_path
    expect(page).to have_css(".notification", count: 2)
    expect(page).to have_content(notification1.notifiable_title)
    expect(page).to have_content(notification2.notifiable_title)
  end

  scenario "Bell" do
    create(:notification, user: user)
    visit root_path

    within("#notifications") do
      expect(page).to have_css(".icon-circle")
    end

    click_notifications_icon
    first(".notification a").click

    within("#notifications") do
      expect(page).to_not have_css(".icon-circle")
    end
  end

  scenario "No notifications" do
    click_notifications_icon
    expect(page).to have_content "You don't have new notifications."
  end

  scenario "User not logged in" do
    logout
    visit root_path

    expect(page).to_not have_css("#notifications")
  end

end
