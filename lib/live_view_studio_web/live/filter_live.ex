defmodule LiveViewStudioWeb.FilterLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Boats

  def mount(_params, _session, socket) do
    {:ok, assign_defaults(socket), temporary_assigns: [boats: []]}
  end

  def render(assigns) do
    ~L"""
    <h1>Daily Boat Rentals</h1>
    <div id="filter">
      <form phx-change="filter">
        <div class="filters">
          <select name="type">
            <%= options_for_select(type_options(), @type) %>
          </select>
          <div class="prices">
            <input type="hidden" name="prices[]" value=""/>
            <%= for price <- ["$", "$$", "$$$"] do %>
              <%= price_checkbox(price, price in @prices) %>

            <% end %>
          </div>
          <a href="#" phx-click="clear-filters">Clear all</a>
        </div>
      </form>
      <div class="boats">
      <%= for boat <- @boats do %>
        <div class="card">
          <img src="<%= boat.image %>">
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
      <% end %>
      </div>
    </div>
    """
  end

  def handle_event("filter", %{"type" => type, "prices" => prices}, socket) do
    criteria = [type: type, prices: prices]
    boats = Boats.list_boats(criteria)

    {:noreply, assign(socket, [{:boats, boats} | criteria])}
  end

  def handle_event("clear-filters", _, socket) do
    {:noreply, assign_defaults(socket)}
  end

  @type_options [
    "All types": "",
    Fishing: "fishing",
    Sporting: "sporting",
    Sailing: "sailing"
  ]

  defp type_options do
    @type_options
  end

  defp assign_defaults(socket) do
      assign(socket,
        boats: Boats.list_boats(),
        type: "",
        prices: [""]
      )
  end

  defp price_checkbox(price, checked) do
    assigns = {}

    ~L"""
    <input type="checkbox"
    id="<%= price %>"
    value = "<%= price %>"
    name= "prices[]"
    <%= if checked, do: "checked" %>
    />
    <label for="<%=price %>"><%= price %></label>
    """
  end
end
