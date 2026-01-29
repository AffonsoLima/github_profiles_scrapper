require 'faraday'
require 'nokogiri'

module Profiles
  class GithubScraper
    GITHUB_BASE_URL = "https://github.com"

    def initialize(profile_url)
      @profile_url = profile_url
    end

    def call
      response = Faraday.get(@profile_url)
      document = Nokogiri::HTML(response.body)

      {
        github_username: extract_username(document),
        followers: extract_number(document, 'a[href$="?tab=followers"] span'),
        following: extract_number(document, 'a[href$="?tab=following"] span'),
        stars: extract_number(document, 'a[href$="?tab=stars"] span'),
        contributions_last_year: extract_contributions(document),
        avatar_url: extract_avatar(document),
        location: extract_optional_text(document, 'li[itemprop="homeLocation"] span'),
        organizations: extract_organizations(document),
        last_scraped_at: Time.current
      }
    end

    private

    def extract_username(doc)
      doc.at_css('span.p-nickname')&.text&.strip
    end

    def extract_number(doc, selector)
      text = doc.at_css(selector)&.text
      normalize_number(text)
    end

    def extract_contributions(doc)
    text = doc.at_css('h2.f4.text-normal.mb-2')&.text
    text&.scan(/\d+/)&.join&.to_i
    end


    def extract_avatar(doc)
      doc.at_css('img.avatar-user')&.[]('src')
    end

    def extract_optional_text(doc, selector)
      doc.at_css(selector)&.text&.strip
    end

    def extract_organizations(doc)
    doc.css('li[itemprop="worksFor"] span')
        .map(&:text)
        .flat_map { |org| org.split(',') }
        .map(&:strip)
        .uniq
    end


    def normalize_number(text)
      return nil unless text

      text = text.strip.downcase

      if text.include?('k')
        (text.delete('k').to_f * 1000).to_i
      else
        text.to_i
      end
    end
  end
end
