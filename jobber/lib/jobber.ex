defmodule Jobber do
  @moduledoc """
  Documentation for `Jobber`.
  """

  alias Jobber.JobRunner
  alias Jobber.JobSupervisor

  @spec start_job(keyword()) ::
          DynamicSupervisor.on_start_child() | {:error, :import_quota_reached}
  def start_job(args) do
    if Enum.count(running_imports()) >= 5 do
      {:error, :import_quota_reached}
    else
      DynamicSupervisor.start_child(JobRunner, {JobSupervisor, args})
    end
  end

  @spec running_imports() :: [term()]
  def running_imports do
    match_all = {:"$1", :"$2", :"$3"}
    guards = [{:==, :"$3", "import"}]
    map_result = [%{id: :"$1", pid: :"$2", type: :"$3"}]

    Registry.select(Jobber.JobRegistry, [{match_all, guards, map_result}])
  end
end
