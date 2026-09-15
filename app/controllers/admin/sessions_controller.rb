module Admin
  class SessionsController < BaseController
    allow_unauthenticated_access only: %i[ new create ]

    layout "admin_auth"

    rate_limit to: 10, within: 3.minutes, only: :create,
               with: -> { redirect_to new_admin_session_path, alert: "Trop de tentatives. Réessayez dans quelques minutes." }

    def new
      redirect_to admin_root_path if authenticated?
    end

    def create
      if admin_user = AdminUser.authenticate_by(params.permit(:email_address, :password))
        start_new_session_for admin_user
        redirect_to after_authentication_url
      else
        redirect_to new_admin_session_path, alert: "Adresse e-mail ou mot de passe incorrect."
      end
    end

    def destroy
      terminate_session
      redirect_to new_admin_session_path, status: :see_other, notice: "Vous êtes déconnecté."
    end
  end
end
