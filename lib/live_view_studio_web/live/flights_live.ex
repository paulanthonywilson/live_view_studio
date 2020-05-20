defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Flights

  def mount(_params, _session, socket) do
    socket = assign(socket, loading: false, flights: [], flight_code: "")
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Find a Flight</h1>
    <div id="search">

      <form phx-submit="search-flights">
        <input type="text" name = "flight-code" placeholder = "flight-code"
          autofocus <%= if @loading, do: "readonly" %>  value="<%= @flight_code %>"/>
        <button type="submit"><img src="images/search.svg"/></button>
      </form>

      <%= if @loading do %>
        <div class="loader">...</div>
      <% end %>

      <div class="flights">
        <ul>
          <%= for flight <- @flights do %>
            <li>
              <div class="first-line">
                <div class="number">
                  Flight #<%= flight.number %>
                </div>
                <div class="origin-destination">
                  <img src="images/location.svg">
                  <%= flight.origin %> to
                  <%= flight.destination %>
                </div>
              </div>
              <div class="second-line">
                <div class="departs">
                  Departs: <%= format_time(flight.departure_time) %>
                </div>
                <div class="arrives">
                  Arrives: <%= format_time(flight.arrival_time) %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("search-flights", %{"flight-code" => flight_code} , socket) do
    send(self(), :do_search)
    {:noreply, assign(socket, flight_code: flight_code, loading: true)}
  end

  defp format_time(time) do
    Timex.format!(time, "%d %b %Y at %H:%M", :strftime)
  end

  def handle_info(:do_search, socket) do
    %{flight_code: flight_code} = socket.assigns
    flights = Flights.search_by_number(flight_code)
    socket = if flights == [] do
      put_flash(socket, :info, "No flights for #{flight_code}")
    else
      clear_flash(socket)
    end
    {:noreply, assign(socket, loading: false, flights: flights)}
  end


end
