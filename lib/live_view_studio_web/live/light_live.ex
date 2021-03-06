defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10, temp: 3000)
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Front porch light</h1>
    <div id="light">
      <div class="meter">
        <span style="width: <%= @brightness %>%; background: <%= temp_colour(@temp)%>">
          <%= @brightness %>%
        </span>
      </div>
      <button phx-click="off">
        <img src="images/light-off.svg">
      </button>
      <button phx-click="down">
        <img src="images/down.svg">
      </button>
      <button phx-click="up">
        <img src="images/up.svg">
      </button>
      <button phx-click="on">
        <img src="images/light-on.svg">
      </button>
      <button phx-click="light-me-up">
        Light me up (randomly)!
      </button>
      <form phx-change="change-brightness">
        <input type="range" min="0" max= "100" name="brightness"
          value="<%= @brightness %>"/>
      </form>
      <h2>Change colour</h2>
      <form phx-change="change-colour">
        <%= for temp <- [3000, 4000, 5000 ] do %>
          <input type="radio" id="<%= temp %>" name="temp" value="<%= temp %>"
            <%= if temp == @temp, do: "checked" %>
          />
          <label for="<%= temp %>"><%= temp %></label>
        <% end %>
      </form>
    </div>
    """
  end

  def handle_event("on", _, socket) do
    {:noreply, assign(socket, :brightness, 100)}
  end

  def handle_event("off", _, socket) do
    {:noreply, assign(socket, :brightness, 0)}
  end

  def handle_event("down", _, socket) do
    {:noreply, update(socket, :brightness, &turn_down/1)}
  end

  def handle_event("up", _, socket) do
    {:noreply, update(socket, :brightness, &turn_up/1)}
  end

  def handle_event("light-me-up", _, socket) do
    brightness = :rand.uniform(101) - 1
    {:noreply, assign(socket, :brightness, brightness)}
  end

  def handle_event("change-brightness", %{"brightness" => brightness}, socket) do
    {:noreply, assign(socket, brightness: String.to_integer(brightness))}
  end

  def handle_event("change-colour", %{"temp" => temp}, socket) do
    temp = String.to_integer(temp)
    {:noreply, assign(socket, temp: temp)}
  end

  defp turn_down(current) do
    max(current - 10, 0)
  end

  defp turn_up(current) do
    min(current + 10, 100)
  end


  defp temp_colour(3000), do: "#F1C40D"
  defp temp_colour(4000), do: "#FEFF66"
  defp temp_colour(5000), do: "#99CCFF"
end
