require "open-uri"
require "json"
require "tmpdir"

namespace :icons do
  desc "Copy the Lucide SVG sources listed in Icon::GROUPS into vendor/icons/lucide"
  task import: :environment do
    version = ENV["LUCIDE_VERSION"].presence
    registry = JSON.parse(URI.parse("https://registry.npmjs.org/lucide-static/#{version || 'latest'}").read)
    tarball  = registry.dig("dist", "tarball")
    version  = registry["version"]

    Dir.mktmpdir do |dir|
      archive = File.join(dir, "lucide.tgz")
      File.binwrite(archive, URI.parse(tarball).read)
      system("tar", "xzf", archive, "-C", dir, exception: true)
      source = File.join(dir, "package")

      Icon::DIRECTORY.mkpath
      missing = []

      Icon::NAMES.each do |name|
        svg = File.join(source, "icons", "#{name}.svg")
        next missing << name unless File.exist?(svg)

        FileUtils.cp(svg, Icon::DIRECTORY.join("#{name}.svg"))
      end

      FileUtils.cp(File.join(source, "LICENSE"), Icon::DIRECTORY.join("LICENSE"))
      Icon::DIRECTORY.join("VERSION").write("lucide-static #{version}\n")

      # Drawings that are no longer in the catalogue have no reason to stay.
      stale = Icon::DIRECTORY.glob("*.svg").map { |f| f.basename(".svg").to_s } - Icon::NAMES
      stale.each { |name| Icon::DIRECTORY.join("#{name}.svg").delete }

      puts "lucide-static #{version} → #{Icon::NAMES.size - missing.size} icônes dans #{Icon::DIRECTORY.relative_path_from(Rails.root)}"
      puts "  supprimées : #{stale.join(', ')}" if stale.any?
      abort "  introuvables dans le paquet : #{missing.join(', ')}" if missing.any?
    end
  end
end
