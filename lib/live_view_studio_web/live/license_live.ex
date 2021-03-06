defmodule LiveViewStudioWeb.LicenseLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Licenses
  import Number.Currency
  import Inflex, only: [inflect: 2]

  def mount(_params, _session, socket) do
    if connected?(socket), do: tock()
    expiration_time = Timex.shift(Timex.now(), hours: 1)

    socket =
      assign(socket,
        seats: 2,
        amount: Licenses.calculate(2),
        expiration_time: expiration_time,
        time_remaining: time_remaining(expiration_time)
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Hello matey</h1>
    <div id="license">
      <div class="card">
        <div class="content">
          <div class="seats">
            <img src="images/license.svg">
            <span>
              Your license is currently for
              <strong><%=@seats %></strong> <%= inflect("seat", @seats) %>.
             </span>
          </div>
          <div>You have <%= @time_remaining %> left.</div>
          <form phx-change="update">
            <input type="range" min="1" max="10" name="seats"
              value="<%=@seats %>"/>
          </form>
          <div class="amount">
            <%= number_to_currency(@amount) %>
          </div
        </div>
      </div>
    </div>
    """
  end

  def handle_event("update", %{"seats" => seats}, socket) do
    seats = String.to_integer(seats)

    socket = assign(socket, seats: seats, amount: Licenses.calculate(seats))
    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    tock()
    %{expiration_time: expiration_time} = socket.assigns
    time_remaining = time_remaining(expiration_time)
    {:noreply, assign(socket, time_remaining: time_remaining)}
  end

  defp time_remaining(expiration_time) do
    Timex.Interval.new(from: Timex.now(), until: expiration_time)
    |> Timex.Interval.duration(:seconds)
    |> Timex.Duration.from_seconds()
    |> Timex.format_duration(:humanized)
  end

  defp tock do
    Process.send_after(self(), :tick, 1000)
  end
end
