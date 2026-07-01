# HTMX4Rails Hybrid SPA Architecture

## Design Philosophy

**Progressive Enhancement.** HTMX is the default, primary interaction path. Traditional Rails views provide a fallback for users without JavaScript or if something breaks. JSON endpoints support frameworks transitioning from traditional JS.

## Three Response Paths

For every request, the controller checks in this order:

```ruby
# 1. HTMX Request (HX-Request header present)
if request.headers["HX-Request"]
  render partial: "...", layout: false  # Returns just the HTML fragment
  return
end

# 2. JSON Request (format=json parameter)
respond_to do |format|
  format.json { render json: @item }  # Returns JSON
end

# 3. HTML Request (default)
# render show.html.erb or redirect as appropriate
```

## URL Routes (RESTful)

```ruby
GET    /items           # Index: list all items
GET    /items/new       # New item form page
GET    /items/:id       # Show item page
GET    /items/:id/edit  # Edit item form page
POST   /items           # Create
PATCH  /items/:id       # Update
DELETE /items/:id       # Destroy
```

## Request Paths Comparison

### 1. HTMX Primary Path (SPA Experience)

```
User clicks "New Item" button
  → button has hx-get="/items/new"
  → HTMX sends GET with HX-Request: true header
  → Controller detects header, renders partial: "items/form"
  → Returns just the form HTML (no layout)
  → HTMX injects into #item_form div
  → User sees form appear on page without navigation
```

### 2. Traditional HTML Fallback

```
User directly navigates to GET /items/new
  → No HX-Request header (direct browser navigation)
  → Controller falls through to respond_to
  → format.html renders new.html.erb WITH layout
  → User sees full page at /items/new
  → Form has action="/items" and method="post"
  → Submit takes user to /items/1 (redirect after create)
```

### 3. JSON API Path (For JS Frameworks)

```
JavaScript app makes request: GET /items/1.json
  → No HX-Request header, format=json parameter present
  → Controller returns respond_to |format| format.json { render json: @item }
  → JavaScript app receives JSON and renders its own HTML
  → Useful for transitioning from Vue, React, etc.
```

## Controller Example

```ruby
class ItemsController < ApplicationController
  before_action :set_item, only: %i[ show edit update destroy ]

  def show
    # 1. HTMX: return partial without layout
    return render partial: "items/item", layout: false if request.headers["HX-Request"]

    # 2. HTML/JSON: respond based on format
    respond_to do |format|
      format.html  # renders show.html.erb with layout
      format.json { render json: @item }
    end
  end

  def create
    @item = Item.new(item_params)

    if @item.save
      # 1. HTMX: return item partial (no redirect)
      return render partial: "items/item", status: :created if request.headers["HX-Request"]

      # 2. HTML: redirect; JSON: return JSON
      respond_to do |format|
        format.html { redirect_to @item, notice: "Created." }
        format.json { render json: @item, status: :created }
      end
    else
      # Error: return form for resubmission
      if request.headers["HX-Request"]
        return render partial: "items/form", status: :unprocessable_entity, layout: false
      end

      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end
end
```

## Forms: Supporting Both HTMX and Traditional Submission

Forms use `form_with` (which adds `action` and `method` attributes) combined with HTMX buttons:

```erb
<%= form_with(model: item, local: true) do |form| %>
  <input type="text" name="item[what]" />
  
  <!-- HTMX: button has hx-post; traditional fallback: form action handles it -->
  <button hx-post="<%= items_path %>"
          hx-include="closest form"
          hx-target="#items"
          hx-swap="afterbegin">
    Create
  </button>
<% end %>
```

**How it works:**
- **With HTMX**: Button click → HTMX reads `hx-post` → sends XHR with form data → server returns partial → HTMX injects
- **Without HTMX**: Button click → browser submits form to `action="/items"` with `method="post"` → server redirects → page navigates

Both work. HTMX just makes the HTML/HTMX path happen without page reload.

## Complete User Flow

### HTMX Path (Default if JavaScript works)
1. Index loads → shows items list
2. Click "New Item" → form loads inline without navigation
3. Submit form → item appears in list, form clears
4. Click "Edit" → form loads inline replacing item display
5. Submit edit → item updates in place
6. Click "Delete" → item removed with animation
7. User stays on `/items` the entire time

### Fallback Path (If JavaScript unavailable)
1. Index loads → shows items list with traditional links
2. Click "New Item" link → navigate to `/items/new` → see full new.html.erb page
3. Submit form → POST `/items` → redirect to `/items/1`
4. See show.html.erb page
5. Click "Edit" → navigate to `/items/1/edit` → see edit.html.erb page
6. Submit form → PATCH `/items/1` → redirect to `/items/1`
7. Traditional Rails navigation experience

### JSON API Path (For JavaScript Framework)
```javascript
// Vue/React app
fetch('/items/1.json')
  .then(r => r.json())
  .then(item => {
    // Render item HTML in your framework
    this.item = item;
  })
```

## Testing HTMX vs. Traditional

```bash
# HTMX response (partial only):
curl -H "HX-Request: true" http://localhost:3000/items/new

# Traditional response (full page):
curl http://localhost:3000/items/new

# JSON response:
curl http://localhost:3000/items/1.json
```

## For Students

This scaffold teaches:

1. **Progressive Enhancement** — App works without JavaScript, better with it
2. **HTMX Patterns** — `hx-get`, `hx-post`, `hx-target`, `hx-swap`, `hx-include`
3. **RESTful Rails** — Full CRUD routes, proper HTTP methods, redirects
4. **Content Negotiation** — Same endpoint, different responses based on request
5. **Resilience** — Graceful degradation when JavaScript fails
6. **API Design** — JSON endpoints for integration with other clients

They see:
- How HTMX intercepts without breaking Rails conventions
- How the same code serves multiple clients (browser with JS, browser without JS, JSON API client)
- How to build apps that are fast *and* resilient
