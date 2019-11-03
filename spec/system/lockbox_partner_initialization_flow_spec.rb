require 'rails_helper'
require './lib/capybara_sessions_helper'

RSpec.describe "Lockbox Partner Initialization Flow", type: :system do
  let!(:user) { FactoryBot.create(:user) }

  it 'flows' do
    # MAC coordinator makes a new lockbox partner
    in_session "MAC Coordinator" do
      login_as(user, :scope => :user)
      visit "/"
      click_on "Create new lockbox partner"

      fill_in "Name", with: "#{Faker::Cannabis.strain.titleize} Clinic"
      fill_in "Street address", with: Faker::Address.street_address
      fill_in "City", with: "Chicago"
      fill_in "State", with: "IL"
      fill_in "Zip code", with: "60606"
      fill_in "Phone number", with: Faker::PhoneNumber.phone_number
      click_on "Add New Partner"
      expect(LockboxPartner.count).to eq 1
    end

    # TODO specify how the coordinator is informed that the lockbox parner has been created

    # MAC coordinator invites a user to the new lockbox partner
    in_session "MAC Coordinator" do
      expect(current_url.include?("/users/new")).to be true
      fill_in "Email", with: Faker::Internet.email
      click_on "Invite user to Lockbox Partner"
      assert_text "New user created for"

      expect(ActionMailer::Base.deliveries.length).to be 1
      email = ActionMailer::Base.deliveries.last
      new_user = User.last
      expect(email.subject).to include("Confirmation")
      expect(email.body).to include("confirmation_token=#{new_user.confirmation_token}")
    end

    # TODO Specify how the coordinator is informed that the user has been invited

    # The new user clicks the link in the email and confirms their name and password
    in_session "Partner User" do
      new_user = User.last
      visit "/users/confirmation?confirmation_token=#{new_user.confirmation_token}"
      fill_in "Name", with: Faker::Name.name
      password = "Password1234"
      fill_in "New password", with: password
      fill_in "Confirm new password", with: password
      click_on "Submit"

      assert_text "Your account has been created"
      # TODO add to specification of how the user is informed that their account has been created
      expect(new_user.reload.confirmed?).to be true
    end

    # TODO Coordinator can manage users from the "Manage Lockbox Partner" page
    # This functionality will come from the completion of issue 191

    # TODO Email is sent to coordinator, reminding them to add money to the lockbox partner

    # MAC Coordinator adds money to the Lockbox Partner
    in_session "MAC Coordinator" do
      lockbox_partner = LockboxPartner.last
      visit "lockbox_partners/#{lockbox_partner.id}/add_cash/new"
      fill_in "Cash Added", with: "1000"
      click_on "Submit"
      assert_text "added to"
      expect(lockbox_partner.reload.cash_addition_confirmation_pending?).to be true
    end

    # TODO Specify how the coordinator is informed that the cash has been added

    # Lockbox Partner user confirms receipt of check
    in_session "Partner User" do
      visit "/"
      assert_text "please confirm it was received"
      click_on "Confirm Cash Addition"
      lockbox_partner = LockboxPartner.last
      expect(lockbox_partner.cash_addition_confirmation_pending?).to be false
      expect(lockbox_partner.balance.to_s).to eq "1000.00"
    end

    # TODO Specify how the user is informed that the cash addition has been confirmed

    # "File a support request" tab is live after confirmation
    in_session "MAC Coordinator" do
      lockbox_partner = LockboxPartner.last
      visit new_lockbox_partner_support_request_path(lockbox_partner)
      expect(lockbox_partner.active).to be true
      assert_no_text "Lockbox partner not yet active"
      assert_text "File a support request"
    end

  end
end
