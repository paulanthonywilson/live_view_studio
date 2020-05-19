defmodule LiveViewStudioWeb.SearchLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Stores

  def mount(_params, _session, socket) do
    socket = assign(socket,
     zip: "",
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
    send(self(), :do_search)
    {:noreply, assign(socket, zip: zip, stores: [], loading: true)}
  end

  def handle_info(:do_search, socket) do
    %{zip: zip} = socket.assigns
    stores = Stores.search_by_zip(zip)
    socket = if [] == stores do
      put_flash(socket, :info, "No stores matching #{zip}.")
    else
      clear_flash(socket)
    end
    {:noreply, assign(socket, stores: stores, loading: false)}
  end
end
