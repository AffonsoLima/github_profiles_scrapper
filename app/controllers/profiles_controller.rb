class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy, :reprocess]

  def index
    scoped = Profile.order(created_at: :desc)
    scoped = apply_filters(scoped)
    @pagy, @profiles = pagy(scoped, items: per_page_param)
  end

  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)

    if @profile.save
      redirect_to @profile, notice: "Perfil criado com sucesso. Estamos coletando os dados no GitHub."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit; end

  def update
    if @profile.update(profile_params)
      redirect_to @profile, notice: "Perfil atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @profile.destroy
    redirect_to profiles_path, notice: "Perfil removido com sucesso."
  end

  def reprocess
    if @profile.enqueue_scrape!(force: true)
      redirect_to @profile, notice: "Reprocessamento iniciado."
    else
      redirect_to @profile, alert: "Não foi possível reprocessar agora."
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:name, :github_url)
  end

  def filter_params
    params.permit(:q, :status, :per_page)
  end

  def apply_filters(scope)
    filtered = scope

    if filter_params[:q].present?
      term = "%#{filter_params[:q]}%"
      filtered = filtered.where("github_username ILIKE :term OR name ILIKE :term", term: term)
    end

    if filter_params[:status].present? && Profile.scrape_statuses.key?(filter_params[:status])
      filtered = filtered.where(scrape_status: Profile.scrape_statuses[filter_params[:status]])
    end

    filtered
  end

  def per_page_param
    value = filter_params[:per_page].presence&.to_i
    value = Pagy::DEFAULT[:items] if value.nil? || value <= 0
    [value, Pagy::DEFAULT[:max_items] || value].min
  end
end
