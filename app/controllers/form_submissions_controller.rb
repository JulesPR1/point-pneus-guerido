class FormSubmissionsController < ApplicationController
  # Public endpoint: throttled, schema-validated, and never echoes raw input back
  # into the page without escaping.
  rate_limit to: 8, within: 10.minutes, only: :create,
             with: -> { redirect_back_or_to(root_path, alert: "Trop de demandes envoyées. Merci de réessayer plus tard.") }

  def create
    @definition = FormDefinition.find(params[:form_type])
    return redirect_to(root_path, alert: "Formulaire inconnu.") if @definition.nil?

    return redirect_to(return_path, notice: @definition.success_message) if honeypot_filled?

    @submission = FormSubmission.new(
      form_type: @definition.key,
      payload: @definition.filter(params[:submission]),
      ip_address: request.remote_ip
    )

    if @submission.save
      redirect_to return_path(anchor: "demande"), notice: @definition.success_message
    else
      flash.now[:alert] = "Votre demande n'a pas pu être envoyée."
      @page = Page.published.find_by(slug: params[:return_slug]) || Page.published.find_by(home: true)
      @sections = @page ? @page.sections.active.ordered.to_a : []
      @h1_section_id = Page.primary_heading_section(@sections)&.id
      @submitted_values = @submission.payload
      render "pages/show", status: :unprocessable_entity
    end
  end

  private
    # Bots fill every field they find; a real visitor never sees this one.
    def honeypot_filled? = params[:website].present?

    def return_path(anchor: nil)
      slug = params[:return_slug].to_s
      path = slug.present? && Page.published.exists?(slug: slug) ? page_path(slug) : root_path
      anchor ? "#{path}##{anchor}" : path
    end
end
