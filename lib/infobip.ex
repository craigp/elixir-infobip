defmodule Infobip do

  @moduledoc """
  A simple Infobip REST API client for Elixir.

  You can find the hex package [here](https://hex.pm/packages/infobip), and the
  docs [here](http://hexdocs.pm/infobip).

  ## Usage

  ```elixir
  def deps do
    [{:infobip, "~> 0.1"}]
  end
  ```

  Then run `$ mix do deps.get, compile` to download and compile your
  dependencies.

  Finally, add the `:infobip` application as your list of applications in
  `mix.exs`:

  ```elixir
  def application do
    [applications: [:logger, :infobip]]
  end
  ```

  You'll need to set a few config parameters, take a look in the
  `dev.exs.sample` file for an example of what is required.

  Then sending a text message is as easy as:

  ```elixir
  {:ok, pid} = Infobip.send("27820001111", "Test message")
  ```

  You can optionally specify a message ID if you want to fetch delivery
  reports:

  ```elixir
  {:ok, pid} = Infobip.send("27820001111", "Test message", "123")
  ```

  You need to pass a valid international mobile number to the `send` method.

  To fetch a delivery report, just use the message ID you assigned in `send/3`:

  ```elixir
  Infobip.delivery_report("123")
  ```
  """

  alias Infobip.{TextMessage, DeliveryReport}

  @doc """
  Sends a text message.
  """
  @spec send(String.t, String.t) :: TextMessage.send_response
  @spec send(String.t, String.t, any) :: TextMessage.send_response
  def send(recipient, message)
  when is_binary(recipient)
  and is_binary(message) do
    TextMessage.send(recipient, message)
  end

  def send(recipient, message, message_id)
  when is_binary(recipient)
  and is_binary(message)
  and is_binary(message_id) do
    TextMessage.send(recipient, message, message_id)
  end

  def send(recipient, message, message_id)
  when is_binary(recipient)
  and is_binary(message) do
    send(recipient, message, to_string(message_id))
  end

  @doc """
  Fetches a text message delivery report.
  """
  @spec delivery_report(any) :: DeliveryReport.fetch_response
  def delivery_report(message_id) when is_binary(message_id) do
    DeliveryReport.fetch(message_id)
  end

  def delivery_report(message_id), do: delivery_report(to_string(message_id))

end
