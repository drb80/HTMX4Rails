require 'rails/generators/rails/scaffold/scaffold_generator'

module Rails
  module Generators
    # Override Rails' scaffold generator to auto-add htmx
    original_initialize = ScaffoldGenerator.instance_method(:initialize)

    define_method(:initialize) do |args, *options|
      original_initialize.bind(self).call(args, *options)
      ensure_htmx_in_layout_later
    end

    def self.included(base)
      base.class_eval do
        # Store reference to ensure_htmx runs after generation
        prepend(Module.new do
          def invoke(*args)
            result = super(*args)
            ensure_htmx_in_layout
            result
          end
        end)
      end
    end

    private

    def ensure_htmx_in_layout
      layout_file = "app/views/layouts/application.html.erb"

      return unless File.exist?(layout_file)
      return if File.read(layout_file).include?("htmx.org")

      say "\nAdding htmx to layout...", :yellow
      inject_into_file layout_file,
        '    <script src="https://unpkg.com/htmx.org@2.0.4"></script>' + "\n",
        before: "  </head>"

      say "✓ htmx is ready!", :green
    end

    def ensure_htmx_in_layout_later
      # Placeholder for later
    end
  end
end
