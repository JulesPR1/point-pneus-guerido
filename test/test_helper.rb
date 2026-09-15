ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    setup { Rails.cache.clear }

    # Content is built per test rather than through fixtures: the CMS shape
    # (page → sections → items) reads far better as explicit factory calls.
    def create_page(**attrs)
      Page.create!({ title: "Page de test", status: :published }.merge(attrs))
    end

    def create_section(page, kind: "rich_text", **attrs)
      page.sections.create!({ kind: kind, heading: "Titre", body: "Texte" }.merge(attrs))
    end

    def create_admin(**attrs)
      AdminUser.create!({ email_address: "admin-#{SecureRandom.hex(4)}@example.com",
                          password: "motdepasse-long-1", name: "Admin" }.merge(attrs))
    end

    def site_setting
      SiteSetting.instance.tap { |s| s.update!(phone: "04 68 50 50 68") }
    end

    def image_fixture
      Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures/files/photo.png"), "image/png")
    end
  end
end

class ActionDispatch::IntegrationTest
  # Signs in through the real form so the session cookie behaves as in production.
  def sign_in(admin_user, password: "motdepasse-long-1")
    post admin_session_path, params: { email_address: admin_user.email_address, password: password }
  end
end
