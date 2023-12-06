defmodule Jobber.Job do
  @moduledoc false

  use GenServer, restart: :transient

  require Logger

  defstruct [:work, :id, :max_retries, retries: 0, status: "new"]

  @five_seconds_in_ms :timer.seconds(5)

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  @impl true
  def init(args) do
    work = Keyword.fetch!(args, :work)
    id = Keyword.get(args, :id, random_job_id())
    max_retries = Keyword.get(args, :max_retries, 3)

    state = %Jobber.Job{id: id, work: work, max_retries: max_retries}

    {:ok, state, {:continue, :run}}
  end

  @impl true
  def handle_continue(:run, state) do
    new_state = handle_job_result(state.work.(), state)

    if new_state.status == "errored" do
      Process.send_after(self(), :retry, @five_seconds_in_ms)
      {:noreply, new_state}
    else
      Logger.info("Job exiting #{state.id}")
      {:stop, :normal, new_state}
    end
  end

  @impl true
  def handle_info(:retry, state) do
    # Delegate work to the `handle_info/2` callback
    {:noreply, state, {:continue, :run}}
  end

  defp random_job_id,
    do: 5 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)

  defp handle_job_result({:ok, _data}, state) do
    Logger.info("Job completed #{state.id}")

    %Jobber.Job{state | status: "done"}
  end

  defp handle_job_result(:error, %{status: "new"} = state) do
    Logger.warn("Job errored #{state.id}")

    %Jobber.Job{state | status: "errored"}
  end

  defp handle_job_result(:error, %{status: "errored"} = state) do
    Logger.warn("Job retry failed #{state.id}")

    new_state = %Jobber.Job{state | retries: state.retries + 1}

    if new_state.retries == state.max_retries do
      %Jobber.Job{new_state | status: "failed"}
    else
      new_state
    end
  end
end
