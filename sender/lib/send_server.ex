defmodule SendServer do
  @moduledoc false

  use GenServer

  @impl true
  def init(args) do
    IO.puts("Received arguments: #{inspect(args)}")

    max_retries = Keyword.get(args, :max_retries, 5)

    state = %{emails: [], max_retries: max_retries}

    schedule_retry()

    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:send, email}, state) do
    email
    |> Sender.send_email()
    |> get_send_email_status()
    |> then(&[%{email: email, status: &1, retries: 0} | state.emails])
    |> then(&{:noreply, %{state | emails: &1}})
  end

  @impl true
  def handle_info(:retry, state) do
    {failed, done} =
      Enum.split_with(state.emails, fn item ->
        item.status == "failed" && item.retries < state.max_retries
      end)

    retried =
      Enum.map(failed, fn item ->
        IO.puts("Retrying email #{item.email}...")

        new_status =
          item.email
          |> Sender.send_email()
          |> get_send_email_status()

        %{email: item.email, status: new_status, retries: item.retries + 1}
      end)

    schedule_retry()

    {:noreply, %{state | emails: retried ++ done}}
  end

  @impl true
  def terminate(reason, _state) do
    IO.puts("Terminating with reason #{reason}")
  end

  defp get_send_email_status({:ok, "email_sent"}), do: "sent"
  defp get_send_email_status(:error), do: "failed"

  defp schedule_retry, do: Process.send_after(self(), :retry, :timer.seconds(5))
end
