require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @profile = profiles(:one)
  end

  test "should get index" do
    get profiles_url
    assert_response :success
  end

  test "should get show" do
    get profile_url(@profile)
    assert_response :success
  end

  test "should get new" do
    get new_profile_url
    assert_response :success
  end

  test "should get create" do
    assert_difference("Profile.count") do
      post profiles_url, params: { profile: { name: "Test", github_url: "https://github.com/test" } }
    end

    assert_redirected_to profile_url(Profile.last)
  end

  test "should get edit" do
    get edit_profile_url(@profile)
    assert_response :success
  end

  test "should update profile" do
    patch profile_url(@profile), params: { profile: { name: "Updated", github_url: "https://github.com/updated" } }

    assert_redirected_to profile_url(@profile)
    @profile.reload
    assert_equal "Updated", @profile.name
  end

  test "should destroy profile" do
    assert_difference("Profile.count", -1) do
      delete profile_url(@profile)
    end

    assert_redirected_to profiles_url
  end
end
