Dir["./spec/support/common_actions/*.rb"].each { |f| require f }

module CommonActions
  include Budgets
  include Comments
  include Debates
  include Emails
  include Notifications
  include Polls
  include Proposals
  include Tags
  include Users
  include Verifications
  include Votes

  def fill_in_signup_form(email = "manuela@consul.dev", password = "judgementday")
    fill_in "user_username",              with: "Manuela Carmena #{rand(99999)}"
    fill_in "user_email",                 with: email
    fill_in "user_password",              with: password
    fill_in "user_password_confirmation", with: password
    check "user_terms_of_service"
  end

  def validate_officer
    allow_any_instance_of(Officing::ResidenceController).
    to receive(:validate_officer_assignment).and_return(true)
  end

end
