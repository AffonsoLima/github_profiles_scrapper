class GithubProfileScrapeJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :exponentially_longer, attempts: 5

  def perform(profile_id)
    profile = Profile.find(profile_id)

    if profile.processing? && profile.updated_at > 10.minutes.ago
      Rails.logger.info "[GithubProfileScrapeJob] Profile #{profile_id} already processing"
      return
    end

    profile.processing!

    data = Profiles::GithubScraper.new(profile.github_url).call

    profile.update!(
      github_username: data[:github_username],
      followers: data[:followers],
      following: data[:following],
      stars: data[:stars],
      contributions_last_year: data[:contributions_last_year],
      avatar_url: data[:avatar_url],
      location: data[:location],
      organizations: data[:organizations],
      last_scraped_at: Time.current
    )

    profile.success!
  rescue => e
    profile.failed! if profile&.persisted?

    Rails.logger.error <<~LOG
      [GithubProfileScrapeJob]
      Profile ID: #{profile_id}
      Error: #{e.class} - #{e.message}
    LOG

    raise e
  end
end
