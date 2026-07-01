class HtmxAutoSetupGenerator < Rails::Generators::Base
  desc "Auto-setup htmx (runs automatically when needed)"

  def create_initializer
    create_file "config/initializers/htmx_setup.rb", <<~RUBY
      # Auto-add htmx script to layout if it's missing
      Rails.application.config.after_initialize do
        layout_path = Rails.root.join("app/views/layouts/application.html.erb")

        if layout_path.exist? && !layout_path.read.include?("htmx.org")
          content = layout_path.read
          htmx_script = '    <script src="https://unpkg.com/htmx.org@2.0.4"><\/script>'

          if content.include?("</head>")
            content.gsub!("</head>", "#{htmx_script}\n  </head>")
            layout_path.write(content)
          end
        end
      end
    RUBY

    say "✓ htmx auto-setup initializer created", :green
  end
end
