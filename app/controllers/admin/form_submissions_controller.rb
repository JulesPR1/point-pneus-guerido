module Admin
  class FormSubmissionsController < BaseController
    before_action :set_submission, only: %i[show update destroy]

    def index
      @form_type = params[:form_type].presence
      @status    = params[:status].presence
      @query     = params[:q].to_s.strip

      @submissions = FormSubmission.recent.of_type(@form_type).with_status(@status)
      @submissions = search(@submissions) if @query.present?
      @counts = FormSubmission.group(:status).count
      @pagination = Pagination.new(@submissions, page: params[:page])
      @submissions = @pagination.records
    end

    def show
    end

    def update
      if @submission.update(submission_params)
        redirect_to admin_form_submission_path(@submission), notice: "Demande mise à jour."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def destroy
      @submission.destroy
      redirect_to admin_form_submissions_path, notice: "Demande supprimée.", status: :see_other
    end

    private
      def set_submission = @submission = FormSubmission.find(params[:id])

      def submission_params = params.expect(form_submission: [ :status, :admin_notes ])

      def search(scope)
        term = "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"
        scope.where("contact_name LIKE :t OR contact_email LIKE :t OR contact_phone LIKE :t", t: term)
      end
  end
end
