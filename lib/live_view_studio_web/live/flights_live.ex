defmodule LiveViewStudioWeb.FlightsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.{Flights, Airports}

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        loading: false,
        flights: [],
        flight_code: "",
        airport_code: "",
        airport_code_matches: []
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Find a Flight</h1>
    <div id="search">

      <form phx-submit="search-flight-code">
        <input type="text" name = "flight-code" placeholder = "flight-code"
          autofocus <%= if @loading, do: "readonly" %>  value="<%= @flight_code %>"/>
        <button type="submit"><img src="images/search.svg"/></button>
      </form>
      <form phx-submit="search-airport" phx-change="change-airport">
        <input type="text" maxlength="3" name="airport-code" placeholder="airport code"
        value="<%=@airport_code %>" phx-debounce="1000" list="airport-matches" autocomplete="off"
        <%= if @loading, do: "readonly" %>
        />
        <button type="submit"><img src="images/search.svg"/></button>
      </form>
      <datalist id="airport-matches">
        <%= for airport <- @airport_code_matches  do %>
          <option value="<%= airport %>"><%= airport %></airport>
        <% end %>
      </datalist>

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

  def handle_event("search-flight-code", %{"flight-code" => flight_code}, socket) do
    send(self(), :search_flight_code)
    {:noreply, assign(socket, flight_code: flight_code, aiport_code: "", loading: true)}
  end

  def handle_event("search-airport", %{"airport-code" => airport_code}, socket) do
    send(self(), :search_airport_code)
    {:noreply, assign(socket, flight_code: "", airport_code: airport_code, loading: true)}
  end

  def handle_event("change-airport", %{"airport-code" => prefix}, socket) do
    codes = Airports.suggest(prefix)
    {:noreply, assign(socket, airport_code_matches: codes)}
  end

  defp format_time(time) do
    Timex.format!(time, "%d %b %Y at %H:%M", :strftime)
  end

  def handle_info(:search_flight_code, socket) do
    %{flight_code: flight_code} = socket.assigns
    flights = Flights.search_by_number(flight_code)
    display_search_results(flights, flight_code, socket)
  end

  def handle_info(:search_airport_code, socket) do
    %{airport_code: airport_code} = socket.assigns
    flights = Flights.search_by_airport(airport_code)
    display_search_results(flights, airport_code, socket)
  end

  defp display_search_results(flights, code, socket) do
    socket =
      if flights == [] do
        put_flash(socket, :info, "No flights for #{code}")
      else
        clear_flash(socket)
      end

    {:noreply, assign(socket, loading: false, flights: flights)}
  end
end
