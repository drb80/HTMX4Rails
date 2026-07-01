# Option 2: Always-Visible Form (Breadcrumb)

## Current Behavior (Option 1)
- Form container is empty on page load
- Click "New Item" → form loads
- Create item → item appears in list, form clears
- User clicks "New Item" again to add another

## Alternative Behavior (Option 2)
If you want the form to **always be visible** on the index page:

### Changes Needed

1. **Remove "New Item" button** from index view
   - Delete the button that loads the form

2. **Pre-load form on index** 
   - In `index` action, set `@item = Item.new`
   - In index view, render the form partial directly: `<%= render "form", item: @item %>`

3. **Keep form visible after create**
   - Remove the `hx-on::afterSwap="..."` from the create button
   - Or modify it to reset the form instead of clearing it

### Implementation Steps

1. Update controller index action:
```ruby
def index
  @items = Item.all
  @item = Item.new  # Add this line
end
```

2. Update index view:
```erb
<!-- Remove this entire button -->
<button hx-get="<%= new_item_path %>" ...>New Item</button>

<!-- Replace with direct form rendering -->
<div id="item_form" class="form-container">
  <%= render "form", item: @item %>
</div>
```

3. Update form create button (remove the afterSwap clear):
```erb
<button hx-post="<%= items_path %>"
        hx-include="closest form"
        hx-target="#items"
        hx-swap="afterbegin">
  Create
</button>
```

4. Optional: Reset form fields after create with JavaScript
```javascript
document.addEventListener('htmx:afterSwap', function(evt) {
  if (evt.detail.xhr.status === 201 && evt.detail.target.id === 'items') {
    // Clear form fields
    document.querySelector('.new-form').reset();
  }
});
```

## UX Comparison

| Aspect | Option 1 | Option 2 |
|--------|----------|----------|
| Form visibility | Hidden until "New Item" clicked | Always visible |
| After create | Form clears, user clicks "New Item" | Form stays, ready for next item |
| New Item button | Visible | Removed |
| Minimal clicks | 3 clicks to add item | 2 clicks to add item |
| Visual clarity | Clean start state | Form always ready |

Option 2 is better for high-volume data entry; Option 1 is cleaner for casual use.
