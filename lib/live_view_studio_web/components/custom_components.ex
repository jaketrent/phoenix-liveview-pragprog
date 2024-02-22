defmodule LiveViewStudioWeb.CustomComponents do
  use Phoenix.Component

  # applies to component that immediately follows
  # , default: 24
  attr :expiration, :integer, required: true
  slot :inner_block, required: true
  slot :legal

  def promo(assigns) do
    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="expiration">
        Deal expires in <%= @expiration %> hours
      </div>
      <div :if={assigns[:legal]} class="legal">
        <%= render_slot(@legal) %>
      </div>
    </div>
    """
  end
end
