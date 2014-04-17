require 'spec_helper'

feature "Admin sees payments" do
  background do
    tom = Fabricate(:user, full_name: "Tom Beck", email: "tom@example.com")
    Fabricate(:payment, amount: 999, user: tom)
  end

  scenario "admin can see payments" do
    sign_in(Fabricate(:admin))
    visit admin_payments_path
    expect(page).to have_content("$9.99")
    expect(page).to have_content("Tom Beck")
    expect(page).to have_content("tom@example.com")
  end

  scenario "user cannot see payments" do
    sign_in(Fabricate(:user))
    visit admin_payments_path
    expect(page).not_to have_content("$9.99")
    expect(page).not_to have_content("Tom Beck")
    expect(page).to have_content("You are not authorized to do that.")
  end
end
