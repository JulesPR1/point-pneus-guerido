module Admin
  class BaseController < ApplicationController
    include Authentication

    layout "admin"

    private
      def breadcrumb(label, path = nil)
        (@breadcrumbs ||= []) << [ label, path ]
      end
  end
end
