defmodule LiveViewStudioWeb.AutocompleteLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.{Cities, Stores}

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        zip: "",
        city: "",
        matches: [],
        stores: [],
        loading: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Find a Store</h1>
    <div id="search">

      <form phx-submit="zip-search">
        <input type="text" name="zip" value="<%= @zip %>" placeholder="Zippydedodah"
        autofocus <%= if @loading, do: "readonly" %> />
        <button type="submit">
          <img src="images/search.svg">
        </button>
      </form>
      <form phx-submit="city-search" phx-change="suggest-city">
        <input type="text" name="city" value="<%= @city %>" placeholder="Citydedodahdah"
        list="matches" phx-debounce="1000" <%= if @loading, do: "readonly" %>/>
        <button type="submit">
          <img src="images/search.svg">
        </button>
      </form>
      <datalist id="matches">
      <%= for match <- @matches  do %>
        <option value="<%=match %>"><%= match %></option>
      <% end %>
      </datalist>

      <%= if @loading do %>
      <div class="loader">
        Loading ...
      </div>
      <% end %>
      <div class="stores">
        <ul>
          <%= for store <- @stores do %>
            <li>
              <div class="first-line">
                <div class="name">
                  <%= store.name %>
                </div>
                <div class="status">
                  <%= if store.open do %>
                    <span class="open">Open</span>
                  <% else %>
                    <span class="closed">Closed</span>
                  <% end %>
                </div>
              </div>
              <div class="second-line">
                <div class="street">
                  <img src="images/location.svg">
                  <%= store.street %>
                </div>
                <div class="phone_number">
                  <img src="images/phone.svg">
                  <%= store.phone_number %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("zip-search", %{"zip" => zip}, socket) do
    send(self(), :zip_search)
    {:noreply, assign(socket, zip: zip, stores: [], city: "", loading: true)}
  end

  def handle_event("city-search", %{"city" => city}, socket) do
    send(self(), :city_search)
    {:noreply, assign(socket, city: city, stores: [], zip: "", loading: true)}
  end

  def handle_event("suggest-city", %{"city" => prefix}, socket) do
    matches = Cities.suggest(prefix)
    {:noreply, assign(socket, matches: matches, city: prefix)}
  end

  def handle_info(:city_search, socket) do
    %{city: city} = socket.assigns

    city
    |> Stores.search_by_city()
    |> reply_with_stores(socket, fn -> "No stores found in  #{city}" end)
  end

  def handle_info(:zip_search, socket) do
    %{zip: zip} = socket.assigns

    zip
    |> Stores.search_by_zip()
    |> reply_with_stores(socket, fn -> "No stores matching #{zip}" end)
  end

  defp reply_with_stores(stores, socket, empty_flash) do
    socket =
      if [] == stores do
        put_flash(socket, :info, empty_flash.())
      else
        clear_flash(socket)
      end

    {:noreply, assign(socket, stores: stores, loading: false)}
  end
end
