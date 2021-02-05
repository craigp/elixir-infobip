defmodule Infobip.Common do

  @moduledoc """
  Helper module for making Infobip requests.
  """

  @doc """
  Loads the Infobip config.
  """
  @spec http_config() :: map
  def http_config do
    case Application.get_env(:infobip, :api) do
      nil ->
        raise "No Infobip config available"
      config ->
        Enum.into(config, %{})
    end
  end

  @doc """
  Generates a meaningful error message for an HTTP error.

  ### Examples

      iex> handle_http_error(:nxdomain)
      {:error, {:http, "Could not reach Infobip API"}}
  """
  @spec handle_http_error(any) :: {atom, {atom, any}}
  def handle_http_error(reason) do
    case reason do
      :nxdomain ->
        {:error, {:http, "Could not reach Infobip API"}}
      :econnrefused ->
        {:error, {:http, "Could not reach Infobip API"}}
      reason ->
        {:error, {:http, reason}}
    end
  end

end
