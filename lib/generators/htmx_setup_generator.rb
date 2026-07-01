class HtmxSetupGenerator < Rails::Generators::Base
  desc "Manually add htmx to your Rails app (usually not needed—initializer does it automatically)"

  def add_htmx_to_layout
    layout_file = "app/views/layouts/application.html.erb"

    if !File.exist?(layout_file)
      say "Layout file not found at #{layout_file}", :red
      return
    end

    if File.read(layout_file).include?("htmx.org")
      say "✓ htmx is already in your layout", :green
      return
    end

    inject_into_file layout_file,
      '    <script src="https://unpkg.com/htmx.org@2.0.4"></script>' + "\n",
      before: "  </head>"

    say "✓ Added htmx script to #{layout_file}", :green
  end
end
