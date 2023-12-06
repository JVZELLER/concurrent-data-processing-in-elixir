defmodule Jobber do
  @moduledoc """
  Documentation for `Jobber`.
  """

  alias Jobber.JobRunner
  alias Jobber.JobSupervisor

  @spec start_job(keyword()) :: DynamicSupervisor.on_start_child()
  def start_job(args) do
    DynamicSupervisor.start_child(JobRunner, {JobSupervisor, args})
  end
end
