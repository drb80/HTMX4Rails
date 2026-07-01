# frozen_string_literal: true

module HtmxHelper
  # Returns true when the current request came from htmx.
  def htmx_request?
    request.headers["HX-Request"].present?
  end

  # Common attributes for an htmx GET link.
  #
  # Example:
  #   link_to "Edit", edit_post_path(post), htmx_get_attrs("#post_form")
  def htmx_get_attrs(target, swap: "innerHTML")
    {
      data: { turbo: false },
      "hx-target": target,
      "hx-swap": swap
    }
  end

  # Common attributes for an htmx form.
  #
  # Example:
  #   form_with model: post, html: htmx_form_attrs("#posts", swap: "beforeend")
  def htmx_form_attrs(target, swap: "innerHTML")
    {
      data: { turbo: false },
      "hx-target": target,
      "hx-swap": swap
    }
  end

  # Common attributes for an htmx delete action that removes the current element.
  #
  # Example:
  #   button_to "Destroy", post, method: :delete, form: htmx_delete_attrs("closest article")
  def htmx_delete_attrs(target = "closest article")
    {
      data: { turbo: false },
      "hx-target": target,
      "hx-swap": "delete",
      "hx-confirm": "Are you sure?"
    }
  end
end
