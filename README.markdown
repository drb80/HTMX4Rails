# Rails htmx ERB Scaffold Templates

This is a starter set of Rails generator template overrides for creating htmx-friendly ERB scaffolds.

## Quick Start

Choose one of three approaches below based on your needs:

### Approach 1: No CSS (Minimal, focus on HTMX)

Best for: Learning HTMX/Rails, minimal setup, adding your own CSS later.

```bash
rails new Todo --minimal
cd Todo
git pull https://github.com/drb80/HTMX4Rails.git
rails generate htmx_scaffold Item what when:date
rails db:migrate
rails server
```

Visit `http://localhost:3000/items` → plain HTML, no styling. You add CSS as you learn.

### Approach 2: Tailwind CSS (Styled, manual compiler)

Best for: Want Tailwind styling out of the box, but managing separate processes.

```bash
rails new Todo --css tailwind --skip-action-mailbox --skip-action-mailer
git clone --depth 1 https://github.com/drb80/HTMX4Rails.git HTMX4Rails
rails generate htmx_scaffold Item what when:date
rails db:migrate
rails server
```

In another terminal, watch Tailwind:
```bash
./bin/rails tailwindcss:watch
```

Or compile once:
```bash
./bin/rails tailwindcss:build
```

Generator auto-detects Tailwind and applies utility classes to buttons, inputs, etc.

### Approach 3: Tailwind CSS with Foreman (Recommended)

Best for: Rails 8 projects, complete setup, one command to run everything.

```bash
rails new Todo --css tailwind --skip-action-mailbox --skip-action-mailer
cd Todo
git clone --depth 1 https://github.com/drb80/HTMX4Rails.git HTMX4Rails
rails generate htmx_scaffold Item what when:date
rails db:migrate
./bin/dev
```

This runs Rails + Tailwind compiler together via Foreman. One command, everything works.

---

## What You Get

All three approaches give you:
- ✅ Fully functional HTMX SPA (all CRUD on one page, no navigation)
- ✅ Form validation with error messages inline
- ✅ Edit forms load inside items (inline editing)
- ✅ Delete with confirmation dialog
- ✅ CSRF token handling automatic
- ✅ Works with traditional form submission as fallback
- ✅ JSON endpoints for API access

**How it works**: The `htmx_scaffold` generator creates a complete scaffold with proper views, controller, and tests. HTMX is added automatically via initializer.

## Manual Install

If you prefer to copy files manually, place these directories into your Rails app root:

```text
lib/templates/erb/scaffold/
app/helpers/htmx_helper.rb
app/views/shared/_htmx_flash.html.erb
```

Then generate scaffolds as usual:

```bash
bin/rails generate scaffold Post title:string body:text
bin/rails db:migrate
```

Rails will use the templates in `lib/templates/erb/scaffold/` instead of the default ERB templates.

## CSS Framework Support

The generator auto-detects your CSS framework from the Gemfile:

- **Tailwind** — `tailwindcss-rails` gem → applies Tailwind utility classes
- **Bootstrap** — `bootstrap` gem → applies Bootstrap classes
- **Bulma** — `bulma-rails` gem → applies Bulma classes
- **None** — No CSS framework → bare HTML, you add styling

You can also override manually:
```bash
rails generate htmx_scaffold Item --css bootstrap
```

Styled elements (same across all frameworks):
- Form inputs (borders, padding, focus states)
- Buttons (primary and danger variants)
- Sections (basic spacing)

Unstyled by design (students add styling):
- Headings (H1, H2, etc.)
- Links and navigation

This keeps the scaffold minimal and pedagogical.

## Assumptions

These templates assume:

- Rails 7 or Rails 8
- ERB views
- RESTful scaffold routes
- HTMX loaded in your application layout (added automatically)
- Turbo may be present, but HTMX interactions disable Turbo with `data-turbo="false"`

## Add htmx to your layout

The scaffold templates use htmx attributes, but you need to load the htmx library. Add it to `app/views/layouts/application.html.erb`:

```erb
<script src="https://unpkg.com/htmx.org@2.0.4"></script>
```

For importmap-based apps, pin it instead:

```bash
bin/importmap pin htmx.org
```

Then add it to the layout:

```erb
<%= javascript_importmap_tags %>
```

For production apps, manage htmx however you normally handle JavaScript dependencies.

## What the generated scaffold does

The generated scaffold uses these htmx patterns:

- Index page contains a collection target.
- New form can be loaded into an inline target.
- Edit form can be loaded into an inline target.
- Show links can load details into a target.
- Destroy buttons remove the item from the page.
- Forms target the collection area on create/update by default.
- Validation errors replace the form area.

## Generated IDs

Each rendered record wrapper gets an id like:

```erb
<%= dom_id(post) %>
```

The collection area gets an id like:

```text
posts
```

The form area gets an id like:

```text
post_form
```

## Controller behavior

The generated scaffold controller automatically includes htmx-aware create, update, and destroy actions:

- **Create**: On `HX-Request`, renders a partial with status 201. Otherwise redirects.
- **Update**: On `HX-Request`, renders the updated partial. Otherwise redirects.
- **Destroy**: On `HX-Request`, returns a `204 No Content`. Otherwise redirects.

This means the scaffold is fully functional with htmx out of the box—no manual tweaks needed.

## Tests for TDD

The `htmx_scaffold` generator creates tests for the generated resource:

- Model test: `test/models/<resource>_test.rb`
- Controller test: `test/controllers/<resources>_controller_test.rb`
- System test: `test/system/<resources>_test.rb`

Run the model and controller tests with:

```bash
bin/rails test
```

Run the browser-based system tests with:

```bash
bin/rails test:system
```

The generated tests demonstrate Test-Driven Development:

**Controller tests** (`test/controllers/`):
- Test regular (non-HTMX) requests expect redirects
- Test HTMX requests expect partial renders
- Each action (create, update, destroy) has both test cases
- Students see the pattern: `headers: { "HX-Request" => "true" }`

**System tests** (`test/system/`):
- Test the full user interaction flow
- Include comments about waiting for HTMX form loads
- Great starting point for integration testing

This gives students a TDD foundation showing how to test different response paths.

## Teaching note

These templates intentionally leave htmx attributes visible in the ERB rather than hiding everything behind helpers. That makes them better for teaching because students can see the HTTP method, target, trigger, and swap strategy directly.
