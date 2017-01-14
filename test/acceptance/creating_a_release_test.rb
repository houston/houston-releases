require "test_helper"

class CreatingAReleaseTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  attr_reader :user, :project, :commit0, :commit1
  fixtures :all


  setup do
    @commit0 = "bd3e9e2"
    @commit1 = "b91a4fe"

    @user = User.first
    @project = Project.create!(
      team: Team.first,
      name: "Test",
      slug: "test",
      version_control_name: "Git",
      props:  {"git.location" => Rails.root.join("test", "data", "bare_repo.git").to_s})

    visit "/users/sign_in"
    fill_in "user_email", with: @user.email
    fill_in "user_password", with: "password"
    click_button "Sign in"
  end

  teardown do
    Capybara.reset_sessions!
  end


  context "Given a valid commit range" do
    setup do
      visit new_release_path
    end

    should "show the release form" do
      assert page.has_content?("New Release to Production")
    end

    should "show all the commits" do
      project.commits.between(commit0, commit1).each do |commit|
        assert page.has_content?(commit.summary), "Expected to find commit #{commit} on the page"
      end
    end

    context "clicking 'Create Release'" do
      should "create the release" do
        assert_difference "Houston::Releases::Release.count", +1 do
          click_button "Create Release"
        end
      end
    end
  end


private

  def new_release_path
    "/projects/test/environments/Production/releases/new?commit0=#{commit0}&commit1=#{commit1}"
  end

end
