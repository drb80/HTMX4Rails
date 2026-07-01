class HtmxScaffoldGenerator < Rails::Generators::Base
  argument :name, type: :string
  argument :attributes, type: :array, default: [], banner: "field:type field:type"
  class_option :css, type: :string, desc: "CSS framework (tailwind, bootstrap, bulma, etc.)", default: nil

  desc "Generate a complete HTMX-powered scaffold with optional CSS framework support"

  def detect_css_framework
    @css_framework = options[:css]

    # Auto-detect from Gemfile if not specified
    if @css_framework.nil?
      gemfile_path = Rails.root.join("Gemfile")
      if gemfile_path.exist?
        gemfile_content = gemfile_path.read

        if gemfile_content.include?("tailwindcss-rails")
          @css_framework = "tailwind"
        elsif gemfile_content.include?("bootstrap")
          @css_framework = "bootstrap"
        elsif gemfile_content.include?("bulma-rails")
          @css_framework = "bulma"
        end
      end
    end

    say "Using CSS framework: #{@css_framework || 'none'}" if @css_framework
  end

  def invoke_all
    detect_css_framework
    super
  end

  def create_model
    generate "model", "#{name} #{attributes.join(' ')}"
  end

  def create_controller
    create_file "app/controllers/#{plural_name}_controller.rb", render_controller_template
  end

  def create_views
    empty_directory "app/views/#{plural_name}"
    create_file "app/views/#{plural_name}/index.html.erb", render_index_view
    create_file "app/views/#{plural_name}/show.html.erb", render_show_view
    create_file "app/views/#{plural_name}/new.html.erb", render_new_view
    create_file "app/views/#{plural_name}/edit.html.erb", render_edit_view
    create_file "app/views/#{plural_name}/_#{singular_name}.html.erb", render_item_partial
    create_file "app/views/#{plural_name}/_form.html.erb", render_form_partial
  end

  def create_routes
    route "resources :#{plural_name}"
  end

  def done_message
    say "\n✓ HTMX scaffold '#{name}' generated!"
    say "  • Model: #{class_name}"
    say "  • Controller: #{class_name.pluralize}Controller"
    say "  • HTMX views with inline editing"
    say "\nNext steps:"
    say "  rails db:migrate"
    say "  rails server"
  end

  private

  def singular_name
    name.underscore
  end

  def plural_name
    name.underscore.pluralize
  end

  def class_name
    name.camelize
  end

  # CSS framework class helpers
  def button_classes
    case @css_framework
    when "tailwind"
      "px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
    when "bootstrap"
      "btn btn-primary"
    when "bulma"
      "button is-primary"
    else
      ""
    end
  end

  def input_classes
    case @css_framework
    when "tailwind"
      "px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-blue-500"
    when "bootstrap"
      "form-control"
    when "bulma"
      "input"
    else
      ""
    end
  end

  def button_danger_classes
    case @css_framework
    when "tailwind"
      "px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
    when "bootstrap"
      "btn btn-danger"
    when "bulma"
      "button is-danger"
    else
      ""
    end
  end

  def container_classes
    case @css_framework
    when "tailwind"
      "max-w-4xl mx-auto px-4"
    when "bootstrap"
      "container"
    when "bulma"
      "container"
    else
      ""
    end
  end

  def section_classes
    case @css_framework
    when "tailwind"
      "py-8"
    when "bootstrap"
      "py-4"
    when "bulma"
      "section"
    else
      ""
    end
  end

  def render_controller_template
    # Parse attribute names from strings like "title:string"
    attr_names = attributes.map { |attr| attr.split(':').first }
    attrs_string = attr_names.map { |name| ":#{name}" }.join(", ")

    <<~RUBY
      class #{class_name.pluralize}Controller < ApplicationController
        before_action :set_#{singular_name}, only: %i[ show edit update destroy ]

        # GET /#{plural_name}
        def index
          @#{plural_name} = #{class_name}.all
          @#{singular_name} = #{class_name}.new
        end

        # GET /#{plural_name}/:id
        def show
          return render partial: "#{plural_name}/#{singular_name}", locals: { #{singular_name}: @#{singular_name} }, layout: false if request.headers["HX-Request"]

          respond_to do |format|
            format.html
            format.json { render json: @#{singular_name} }
          end
        end

        # GET /#{plural_name}/new
        def new
          @#{singular_name} = #{class_name}.new
          return render partial: "#{plural_name}/form", locals: { #{singular_name}: @#{singular_name} }, layout: false if request.headers["HX-Request"]

          respond_to do |format|
            format.html
            format.json { render json: @#{singular_name} }
          end
        end

        # GET /#{plural_name}/:id/edit
        def edit
          return render partial: "#{plural_name}/form", locals: { #{singular_name}: @#{singular_name} }, layout: false if request.headers["HX-Request"]

          respond_to do |format|
            format.html
          end
        end

        # POST /#{plural_name}
        def create
          @#{singular_name} = #{class_name}.new(#{singular_name}_params)

          if @#{singular_name}.save
            return render partial: "#{plural_name}/#{singular_name}", locals: { #{singular_name}: @#{singular_name} }, status: :created if request.headers["HX-Request"]

            respond_to do |format|
              format.html { redirect_to @#{singular_name}, notice: "#{class_name} was successfully created." }
              format.json { render json: @#{singular_name}, status: :created }
            end
          else
            return render partial: "#{plural_name}/form", locals: { #{singular_name}: @#{singular_name} }, status: :unprocessable_entity, layout: false if request.headers["HX-Request"]

            respond_to do |format|
              format.html { render :new, status: :unprocessable_entity }
              format.json { render json: @#{singular_name}.errors, status: :unprocessable_entity }
            end
          end
        end

        # PATCH/PUT /#{plural_name}/:id
        def update
          if @#{singular_name}.update(#{singular_name}_params)
            return render partial: "#{plural_name}/#{singular_name}", locals: { #{singular_name}: @#{singular_name} } if request.headers["HX-Request"]

            respond_to do |format|
              format.html { redirect_to @#{singular_name}, notice: "#{class_name} was successfully updated." }
              format.json { render json: @#{singular_name} }
            end
          else
            return render partial: "#{plural_name}/form", locals: { #{singular_name}: @#{singular_name} }, status: :unprocessable_entity, layout: false if request.headers["HX-Request"]

            respond_to do |format|
              format.html { render :edit, status: :unprocessable_entity }
              format.json { render json: @#{singular_name}.errors, status: :unprocessable_entity }
            end
          end
        end

        # DELETE /#{plural_name}/:id
        def destroy
          @#{singular_name}.destroy!

          return head :ok if request.headers["HX-Request"]

          respond_to do |format|
            format.html { redirect_to #{plural_name}_url, notice: "#{class_name} was successfully destroyed." }
            format.json { head :no_content }
          end
        end

        private

        def set_#{singular_name}
          @#{singular_name} = #{class_name}.find(params[:id])
        end

        def #{singular_name}_params
          params.require(:#{singular_name}).permit(#{attrs_string})
        end
      end
    RUBY
  end

  def render_index_view
    <<~ERB
      <% content_for :title, "#{class_name.pluralize}" %>

      <section class="#{plural_name.dasherize}-index #{section_classes}">
        <header class="page-header">
          <h1>#{class_name.pluralize}</h1>
        </header>

        <div id="#{singular_name}_form" class="form-container">
          <%= render "form", #{singular_name}: @#{singular_name} %>
        </div>

        <div id="#{plural_name}" class="#{plural_name.dasherize}-collection">
          <% @#{plural_name}.each do |#{singular_name}| %>
            <%= render #{singular_name} %>
          <% end %>
        </div>
      </section>
    ERB
  end

  def render_show_view
    <<~ERB
      <% content_for :title, "#{class_name}" %>

      <section id="<%= dom_id @#{singular_name}, :details %>" class="#{singular_name.dasherize}-details #{section_classes}">
        <%= render @#{singular_name} %>

        <nav class="record-navigation">
          <%= link_to "Edit", edit_#{singular_name}_path(@#{singular_name}) %>
          <%= link_to "Back", #{plural_name}_path %>
        </nav>
      </section>
    ERB
  end

  def render_new_view
    <<~ERB
      <% content_for :title, "New #{class_name}" %>

      <section class="#{singular_name.dasherize}-new #{section_classes}">
        <h1>New #{class_name}</h1>
        <%= render "form", #{singular_name}: @#{singular_name} %>

        <div>
          <%= link_to "Back", #{plural_name}_path %>
        </div>
      </section>
    ERB
  end

  def render_edit_view
    <<~ERB
      <% content_for :title, "Edit #{class_name}" %>

      <section class="#{singular_name.dasherize}-edit #{section_classes}">
        <h1>Edit #{class_name}</h1>
        <%= render "form", #{singular_name}: @#{singular_name} %>

        <div>
          <%= link_to "Show", @#{singular_name} %>
          <%= link_to "Back", #{plural_name}_path %>
        </div>
      </section>
    ERB
  end

def render_item_partial
    # Parse attributes: ["title:string", "done:boolean"]
    attr_names = attributes.map { |attr| attr.split(':').first }
      .reject { |name| name == "created_at" || name == "updated_at" }

    fields = attr_names.map { |name| "    <span class=\"#{singular_name}-#{name}\"><%= #{singular_name}.#{name} %></span>" }
      .join("\n")

    <<~ERB
      <article id="<%= dom_id #{singular_name} %>" class="#{singular_name.dasherize}-item">
        <div class="#{singular_name.dasherize}-display">
      #{fields}

          <div class="#{singular_name.dasherize}-actions">
            <button hx-get="<%= edit_#{singular_name}_path(#{singular_name}) %>"
                    hx-target="closest article"
                    hx-swap="innerHTML"
                    class="#{button_classes}">
              Edit
            </button>

            <button hx-delete="<%= #{singular_name}_path(#{singular_name}) %>"
                    hx-target="closest article"
                    hx-swap="outerHTML swap:1s"
                    hx-confirm="Are you sure?"
                    class="#{button_danger_classes}">
              Delete
            </button>
          </div>
        </div>
      </article>
    ERB
  end

  def render_form_partial
    # Parse attributes and map to form field types
    fields = attributes.map { |attr| attr.split(':') }
      .reject { |name, _| name == "created_at" || name == "updated_at" }
      .map do |name, type|
        input_type = case type
                     when "boolean" then "checkbox"
                     when "text" then "textarea"
                     when "date" then "date"
                     when "datetime", "timestamp" then "datetime-local"
                     when "time" then "time"
                     when "integer" then "number"
                     when "float", "decimal" then "number"
                     else "text"
                     end

        input_class = input_type == "checkbox" ? "" : " class=\"#{input_classes}\""

        if input_type == "checkbox"
          "        <div class=\"field\">\n          <label><input type=\"checkbox\" name=\"#{singular_name}[#{name}]\" value=\"1\" /> #{name.titleize}</label>\n        </div>"
        elsif input_type == "textarea"
          "        <div class=\"field\">\n          <label for=\"#{singular_name}_#{name}\">#{name.titleize}</label>\n          <textarea name=\"#{singular_name}[#{name}]\" id=\"#{singular_name}_#{name}\"#{input_class}></textarea>\n        </div>"
        else
          "        <div class=\"field\">\n          <label for=\"#{singular_name}_#{name}\">#{name.titleize}</label>\n          <input type=\"#{input_type}\" name=\"#{singular_name}[#{name}]\" id=\"#{singular_name}_#{name}\"#{input_class} />\n        </div>"
        end
      end.join("\n")

    <<~ERB
      <% if #{singular_name}.persisted? %>
        <!-- Edit form -->
        <%= form_with(model: #{singular_name}, local: true, html: { class: "edit-form" }) do |form| %>
          <% if #{singular_name}.errors.any? %>
            <div class="form-errors">
              <h2><%= pluralize(#{singular_name}.errors.count, "error") %> prohibited this from being saved:</h2>
              <ul>
                <% #{singular_name}.errors.each do |error| %>
                  <li><%= error.full_message %></li>
                <% end %>
              </ul>
            </div>
          <% end %>

          #{fields}

          <div class="actions">
            <!-- HTMX: button with hx-patch + hx-include; fallback: normal submit to form action -->
            <button hx-patch="<%= #{singular_name}_path(#{singular_name}) %>"
                    hx-include="closest form"
                    hx-target="closest article"
                    hx-swap="outerHTML swap:1s"
                    class="#{button_classes}">
              Update
            </button>
            <button type="button"
                    onclick="this.closest('article').outerHTML = ''">
              Cancel
            </button>
          </div>
        <% end %>
      <% else %>
        <!-- New form -->
        <%= form_with(model: #{singular_name}, local: true, html: { class: "new-form" }) do |form| %>
          <% if #{singular_name}.errors.any? %>
            <div class="form-errors">
              <h2><%= pluralize(#{singular_name}.errors.count, "error") %> prohibited this from being saved:</h2>
              <ul>
                <% #{singular_name}.errors.each do |error| %>
                  <li><%= error.full_message %></li>
                <% end %>
              </ul>
            </div>
          <% end %>

          #{fields}

          <div class="actions">
            <!-- HTMX: button with hx-post + hx-include; fallback: normal submit to form action -->
            <!-- Only reset form on successful response (2xx), not on validation errors (4xx) -->
            <button hx-post="<%= #{plural_name}_path %>"
                    hx-include="closest form"
                    hx-target="##{plural_name}"
                    hx-swap="afterbegin"
                    hx-on::after-request="if(event.detail.successful) this.closest('form').reset()"
                    class="#{button_classes}">
              Create
            </button>
          </div>
        <% end %>
      <% end %>
    ERB
  end
end
