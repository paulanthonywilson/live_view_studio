defmodule LiveViewStudioWeb.SalesDashboardLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Sales

  @default_refresh_millis 1000

  def mount(_params, _session, socket) do
    socket = assign(socket, refresh_millis: @default_refresh_millis)

    if connected?(socket) do
      send(self(), :tick)
    end

    {:ok, assign_sales_values(socket)}
  end

  def render(assigns) do
    ~L"""
    <h1>Sales Dashboard</h1>
    <div id="dashboard">
      <p>Last updated: <%= @last_updated %></p>
      <div class="stats">
        <div class="stat">
          <span class="value">
            <%= @new_orders %>
          </span>
          <span class="name">
            New Orders
          </span>
        </div>
        <div class="stat">
          <span class="value">
            $<%= @sales_amount %>
          </span>
          <span class="name">
            Sales Amount
          </span>
        </div>
        <div class="stat">
          <span class="value">
            <%= @satisfaction %>%
          </span>
          <span class="name">
            Satisfaction
          </span>
        </div>
      </div>
      <button phx-click="refresh">
        <img src="images/refresh.svg">
        Refresh
      </button>
      <div>
      <form phx-change="refresh-rate-change">
        <label for="refresh-rate">Refresh rate:</label>
        <select name="refresh-rate">
          <%= options_for_select(refresh_options(), 1) %>
        </select>
      </form>
      </div>
    </div>
    """
  end

  def handle_event("refresh-rate-change", %{"refresh-rate" => refresh_rate}, socket) do
    refresh_millis = String.to_integer(refresh_rate) * 1000
    socket = assign(socket, refresh_millis: refresh_millis)

    case socket.assigns do
      %{timer_ref: timer_ref} ->
        timer_ref |> Process.read_timer() |> IO.inspect(label: :timer_ref)
        Process.cancel_timer(timer_ref)

      _ ->
        nil
    end

    send(self(), :tick)

    {:noreply, socket}
  end

  def handle_event("refresh", _, socket) do
    {:noreply, assign_sales_values(socket)}
  end

  defp refresh_options do
    [{"1s", 1}, {"5s", 5}, {"15s", 15}, {"30s", 30}, {"60s", 60}]
  end

  def handle_info(:tick, socket) do
    socket = tock(socket)
    {:noreply, assign_sales_values(socket)}
  end

  defp tock(socket) do
    %{refresh_millis: refresh_millis} = socket.assigns
    timer_ref = Process.send_after(self(), :tick, refresh_millis)
    assign(socket, timer_ref: timer_ref)
  end

  defp assign_sales_values(socket) do
    {:ok, updated} = Timex.format(Timex.now(), "%H:%M:%S", :strftime)
    assign(socket,
      new_orders: Sales.new_orders(),
      sales_amount: Sales.sales_amount(),
      satisfaction: Sales.satisfaction(),
      last_updated: updated,
    )
  end
end
