defmodule LiveViewStudioWeb.ShopLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Products
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       products: Products.list_products(),
       cart: %{},
       show_cart: false
     )}
  end

  def handle_event("add-product", %{"product" => product}, socket) do
    cart = Map.update(socket.assigns.cart, product, 1, &(&1 + 1))
    {:noreply, assign(socket, :cart, cart)}
  end

  def toggle_cart do
    JS.toggle(to: "#cart") |> JS.toggle(to: "#backdrop")
  end
end
