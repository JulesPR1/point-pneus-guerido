module Admin
  class DashboardController < BaseController
    def show
      @pages_count     = Page.count
      @published_count = Page.published.count
      @sections_count  = Section.count
      @media_count     = MediaItem.count

      @submissions_count = FormSubmission.count
      @open_count        = FormSubmission.open_requests.count
      @week_count        = FormSubmission.where(created_at: 7.days.ago..).count
      @by_type           = FormSubmission.group(:form_type).count
      @latest            = FormSubmission.recent.limit(8)
      @recently_edited   = Page.order(updated_at: :desc).limit(5)
    end
  end
end
