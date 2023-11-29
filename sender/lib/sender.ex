defmodule Sender do
  @moduledoc """
  Documentation for `Sender`.
  """

  @spec send_email(String.t()) :: {:ok, String.t()}
  def send_email(email) do
    3 |> :timer.seconds() |> Process.sleep()

    IO.puts("Email to #{email} sent")

    {:ok, "email_sent"}
  end

  @spec notify_all([String.t()]) :: :ok
  def notify_all(emails) do
    emails
    |> Enum.map(fn email ->
      Task.async(fn -> send_email(email) end)
    end)
    |> Enum.map(&Task.await/1)
  end
end
