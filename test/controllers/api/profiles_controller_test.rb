require "test_helper"

module Api
  class ProfilesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @profile = profiles(:one)
    end

    test "returns paginated profiles" do
      get api_profiles_url, params: { per_page: 1 }

      assert_response :success

      payload = JSON.parse(response.body)
      assert_equal 1, payload.fetch("data").size
      assert_equal %w[page per_page total_count total_pages], payload.fetch("pagination").keys.sort
    end

    test "creates a profile" do
      assert_difference("Profile.count") do
        post api_profiles_url,
             params: { profile: { name: "API Test", github_url: "https://github.com/api-test" } },
             as: :json
      end

      assert_response :created
      payload = JSON.parse(response.body)
      assert_equal "API Test", payload.dig("data", "name")
    end

    test "reprocesses an existing profile" do
      post reprocess_api_profile_url(@profile)

      assert_response :accepted
      payload = JSON.parse(response.body)
      assert_equal @profile.id, payload.dig("data", "id")
    end
  end
end
