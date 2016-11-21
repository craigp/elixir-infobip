defmodule Infobip.Helper do

  @moduledoc """
  Helper module for making Infobip requests.
  """

  @doc """
  Loads the Infobip config.
  """
  @spec http_config() :: map
  def http_config do
    case Application.get_env(:infobip, :http) do
      nil ->
        raise "No :infobip config for env #{Mix.env}"
      config ->
        config
        |> Enum.into(%{})
    end
  end

  @doc """
  Generates a meaningful error message for an HTTP error.
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
