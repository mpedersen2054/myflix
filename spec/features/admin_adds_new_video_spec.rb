require 'spec_helper'

feature "admin adds a new video" do
  scenario "admin successfully adds a new video" do
    comedy = Fabricate(:category, name: "Comedy")
    admin = Fabricate(:admin)

    sign_in(admin)
    visit new_admin_video_path
    fill_in "Title", with: "Monk"
    select "Comedy", from: "Category"
    fill_in "Description", with: "A low tier comedy show"
    attach_file "Large cover", "spec/support/uploads/monk_large.jpg"
    attach_file "Small cover", "spec/support/uploads/monk.jpg"
    fill_in "Video URL", with: "http://www.example.com/a_vid.mp4"
    click_button "Add Video"
    sign_out

    sign_in
    visit video_path(Video.first)
    expect(page).to have_selector("img[src='/uploads/monk_large.jpg']")
    expect(page).to have_selector("a[href='http://www.example.com/a_vid.mp4']")
  end
end
