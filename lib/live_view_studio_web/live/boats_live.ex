defmodule LiveViewStudioWeb.BoatsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Boats
  import LiveViewStudioWeb.CustomComponents, only: [promo: 1]

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        filter: %{type: "", prices: []},
        boats: Boats.list_boats()
      )

    # frees up memory from static data, after render
    {:ok, socket, temporary_assigns: [boats: []]}
  end

  def render(assigns) do
    ~H"""
    <h1>Daily Boat Rentals</h1>
    <.promo expiration={2}>
      Save 25% on rentals
    </.promo>
    <div id="boats">
      <form phx-change="filter">
        <div class="filters">
          <select name="type">
            <%= Phoenix.HTML.Form.options_for_select(
              type_options(),
              @filter.type
            ) %>
          </select>
          <div class="prices">
            <%= for price <- ["$", "$$", "$$$"] do %>
              <input
                type="checkbox"
                name="prices[]"
                value={price}
                id={price}
                checked={price in @filter.prices}
              />
              <label for={price}><%= price %></label>
            <% end %>
            <input type="hidden" name="prices[]" value="" />
          </div>
        </div>
      </form>
      <div class="boats">
        <div :for={boat <- @boats} class="boat">
          <img src={boat.image} />
          <div class="content">
            <div class="model">
              <%= boat.model %>
            </div>
            <div class="details">
              <span class="price">
                <%= boat.price %>
              </span>
              <span class="type">
                <%= boat.type %>
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    <.promo expiration={1}>
      Hurry, act now
      <:legal>
        <Heroicons.exclamation_circle /> Excluding weekends
      </:legal>
    </.promo>
    """
  end

  defp type_options do
    [
      "All Types": "",
      Fishing: "fishing",
      Sporting: "sporting",
      Sailing: "sailing"
    ]
  end

  def handle_event("filter", %{"type" => type, "prices" => prices}, socket) do
    filter = %{type: type, prices: prices}
    boats = Boats.list_boats(filter)
    {:noreply, assign(socket, boats: boats, filter: filter)}
  end
end
