# Auto-add htmx script, CSRF meta tag, and CSRF token configuration to layout
Rails.application.config.after_initialize do
  layout_path = Rails.root.join("app/views/layouts/application.html.erb")

  if layout_path.exist?
    content = layout_path.read
    modified = false

    # Add CSRF meta tag if missing
    if !content.include?('name="csrf-token"')
      csrf_meta = '    <meta name="csrf-token" content="<%= form_authenticity_token %>">'
      if content.include?("</head>")
        content.gsub!("</head>", "#{csrf_meta}\n  </head>")
        modified = true
      end
    end

    # Add HTMX script if missing
    if !content.include?("htmx.org")
      htmx_script = '    <script src="https://unpkg.com/htmx.org@2.0.4"></script>'
      if content.include?("</head>")
        content.gsub!("</head>", "#{htmx_script}\n  </head>")
        modified = true
      end
    end

    # Add HTMX CSRF token configuration if missing
    if !content.include?("htmx:configRequest")
      csrf_config = <<~JAVASCRIPT
        <script>
          document.addEventListener('htmx:configRequest', function(evt) {
            evt.detail.headers['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').content;
          });
        </script>
      JAVASCRIPT
      if content.include?("</head>")
        content.gsub!("</head>", "#{csrf_config}  </head>")
        modified = true
      end
    end

    # htmx 2 doesn't swap 4xx/5xx responses, so a 422 with validation errors
    # would never appear. Swap 422s; keep ignoring other errors.
    if !content.include?("htmx-config")
      response_config = <<~HTML
        <meta name="htmx-config" content='{"responseHandling":[{"code":"204","swap":false},{"code":"[23]..","swap":true},{"code":"422","swap":true},{"code":"[45]..","swap":false,"error":true}]}'>
      HTML
      if content.include?("</head>")
        content.gsub!("</head>", "#{response_config}  </head>")
        modified = true
      end
    end

    layout_path.write(content) if modified
  end
end
