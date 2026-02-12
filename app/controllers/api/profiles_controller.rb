module Api
  class ProfilesController < BaseController
    def index
      profiles = Profile.order(created_at: :desc)
      profiles = apply_filters(profiles)

      pagy, records = pagy(profiles, items: per_page_param)

      render json: {
        data: records.map { |profile| profile_payload(profile) },
        pagination: pagination_meta(pagy)
      }
    end

    def show
      profile = Profile.find(params[:id])
      render json: { data: profile_payload(profile) }
    end

    def create
      profile = Profile.new(profile_params)

      if profile.save
        render json: { data: profile_payload(profile) }, status: :created
      else
        render json: { error: "validation_error", details: profile.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def reprocess
      profile = Profile.find(params[:id])

      if profile.enqueue_scrape!(force: true)
        render json: { data: profile_payload(profile), message: "Reprocessamento iniciado" }, status: :accepted
      else
        render json: { error: "unprocessable", message: "Perfil já está em processamento" }, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      params.require(:profile).permit(:name, :github_url)
    end

    def per_page_param
      per_page = params.fetch(:per_page, Pagy::DEFAULT[:items]).to_i
      per_page = Pagy::DEFAULT[:items] if per_page <= 0
      max_items = Pagy::DEFAULT[:max_items] || Pagy::DEFAULT[:items]
      [per_page, max_items].min
    end

    def apply_filters(scope)
      filtered = scope

      if params[:q].present?
        term = "%#{params[:q]}%"
        filtered = filtered.where("github_username ILIKE :term OR name ILIKE :term", term: term)
      end

      if params[:status].present? && Profile.scrape_statuses.key?(params[:status])
        filtered = filtered.where(scrape_status: Profile.scrape_statuses[params[:status]])
      end

      filtered
    end

    def pagination_meta(pagy_object)
      {
        page: pagy_object.page,
        per_page: pagy_object.items,
        total_pages: pagy_object.pages,
        total_count: pagy_object.count
      }
    end

    def profile_payload(profile)
      {
        id: profile.id,
        name: profile.name,
        github_url: profile.github_url,
        short_github_url: profile.short_github_url,
        github_username: profile.github_username,
        followers: profile.followers,
        following: profile.following,
        stars: profile.stars,
        contributions_last_year: profile.contributions_last_year,
        avatar_url: profile.avatar_url,
        location: profile.location,
        organizations: profile.organizations || [],
        status: profile.scrape_status,
        last_scraped_at: profile.last_scraped_at,
        created_at: profile.created_at,
        updated_at: profile.updated_at
      }
    end
  end
end
