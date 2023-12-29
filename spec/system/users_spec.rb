require "rails_helper"

RSpec.describe "Users" do
  it "shows the title" do
    visit new_user_path
    expect(page).to have_content("New user")
  end
end
