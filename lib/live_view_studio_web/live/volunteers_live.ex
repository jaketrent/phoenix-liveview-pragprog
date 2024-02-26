defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudioWeb.VolunteerFormComponent

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Volunteers.subscribe()
    end

    volunteers = Volunteers.list_volunteers()

    socket =
      socket
      |> stream(:volunteers, volunteers)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.live_component module={VolunteerFormComponent} id={:new} />
      <pre>
        <%#= inspect @form, pretty: true %>
      </pre>
      <div id="uniq_id_for_stream" phx-update="stream">
        <.volunteer
          :for={{id_for_item_in_stream, volunteer} <- @streams.volunteers}
          volunteer={volunteer}
          id={"vol-#{volunteer.id}"}
        />
      </div>
    </div>
    """
  end

  def volunteer(assigns) do
    ~H"""
    <div
      class={"volunteer #{if @volunteer.checked_out, do: "out"}"}
      id={@id}
    >
      <div class="name">
        <%= @volunteer.name %>
      </div>
      <div class="phone">
        <%= @volunteer.phone %>
      </div>
      <div class="status">
        <button phx-click="toggle-status" phx-value-my-id={@volunteer.id}>
          <%= if @volunteer.checked_out,
            do: "Check In",
            else: "Check Out" %>
        </button>
      </div>
    </div>
    """
  end

  def handle_event("toggle-status", %{"my-id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, _volunteer} =
      Volunteers.update_volunteer(
        volunteer,
        %{checked_out: !volunteer.checked_out}
      )

    {:noreply, socket}
  end

  # from child live component
  # TODO: this is not prepending. Why?
  def handle_info({:volunteer_created, volunteer}, socket) do
    {:noreply, stream_insert(socket, :volunteers, volunteer, at: 0)}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    # will update in-place in dom based on the id
    {:noreply, stream_insert(socket, :volunteers, volunteer)}
  end
end
