defmodule Sender do
  @moduledoc """
  Documentation for `Sender`.
  """

  @spec send_email(String.t()) :: {:ok, String.t()} | :error
  def send_email("konnichiwa@world.com" = _email), do: :error

  def send_email(email) do
    3 |> :timer.seconds() |> Process.sleep()

    IO.puts("Email to #{email} sent")

    {:ok, "email_sent"}
  end

  @spec notify_all([String.t()]) :: :ok
  def notify_all(emails) do
    emails
    |> Task.async_stream(&send_email/1, ordered: false)
    |> Enum.to_list()
  end
end
