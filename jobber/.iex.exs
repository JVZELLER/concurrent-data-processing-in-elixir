sleep = fn n -> n |> :timer.seconds() |> Process.sleep() end

good_job = fn ->
  sleep.(60)

  {:ok, []}
end

bad_job = fn ->
  sleep.(5)

  :error
end

doomed_job = fn ->
  sleep.(5)

  raise "Boom!"
end
