require 'spec_helper'

feature "user resets password" do
  scenario "user successfully resets password" do
    alice = Fabricate(:user, password: "old_password")
    visit sign_in_path
    click_link "Forgot password?"
    fill_in "Email Address", with: alice.email
    click_button "Send Email"

    open_email(alice.email)
    current_email.click_link("Reset my password")

    fill_in "New Password", with: "new_password"
    click_button "Reset Password"

    fill_in "Email Address", with: alice.email
    fill_in "Password", with: "new_password"
    click_button "Sign in"
    expect(page).to have_content("Welcome, #{alice.full_name}")

    clear_email
  end
end
