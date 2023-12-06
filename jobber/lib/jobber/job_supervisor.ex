defmodule Jobber.JobSupervisor do
  @moduledoc """
  Intermediary supervisor to take care of supervisor running jobs.
  """
  use Supervisor, restart: :temporary

  @spec start_link(keyword()) :: Supervisor.on_start()
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  @impl true
  def init(args) do
    children = [
      {Jobber.Job, args}
    ]

    options = [
      strategy: :one_for_one,
      max_seconds: 30
    ]

    Supervisor.init(children, options)
  end
end
