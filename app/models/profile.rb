require "uri"

class Profile < ApplicationRecord
  enum :scrape_status, {
    pending: 0,
    processing: 1,
    success: 2,
    failed: 3
  }

  validates :name, presence: true
  validates :github_url, presence: true, uniqueness: { case_sensitive: false }
  validate :github_url_must_point_to_github
  validates :github_username, uniqueness: { allow_nil: true }

  before_validation :normalize_github_url
  before_save :assign_short_github_url

  after_create_commit :enqueue_initial_scrape
  after_update_commit :enqueue_scrape_if_url_changed

  scope :recent, -> { order(created_at: :desc) }

  def enqueue_scrape!(force: false)
    if processing?
      return false unless force
      return false if updated_at && updated_at > 10.minutes.ago
    end

    pending! unless pending?
    GithubProfileScrapeJob.perform_later(id)
    true
  end

  private

  def normalize_github_url
    return if github_url.blank?

    normalized = github_url.strip
    normalized = "https://#{normalized}" unless normalized.start_with?("http")
    self.github_url = normalized
  end

  def assign_short_github_url
    return if github_url.blank?

    self.short_github_url = github_url.gsub(%r{\Ahttps?://(www\.)?}, "")
  end

  def github_url_must_point_to_github
    return if github_url.blank?

    uri = URI.parse(github_url)
    errors.add(:github_url, :invalid) unless uri.host&.end_with?("github.com")
  rescue URI::InvalidURIError
    errors.add(:github_url, :invalid)
  end

  def enqueue_initial_scrape
    enqueue_scrape!
  end

  def enqueue_scrape_if_url_changed
    enqueue_scrape!(force: true) if saved_change_to_github_url?
  end
end
