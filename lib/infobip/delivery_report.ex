defmodule Infobip.DeliveryReport do

  @moduledoc """
  Fetches a text message delivery report.
  """

  import Infobip.Helper, only: [http_config: 0, handle_http_error: 1]
  alias HTTPoison.{Response, Error}

  @type fetch_response :: {atom, {atom, String.t}}

  @doc """
  Fetches a text message delivery report.
  """
  @spec fetch(String.t) :: fetch_response
  def fetch(message_id) when is_binary(message_id) do
    %{
      delivery_report_url: url,
      system_id: id,
      password: pass
    } = http_config
    "#{url}?user=#{id}&password=#{pass}&messageId=#{message_id}"
    |> HTTPoison.get
    |> handle_delivery_report_response
  end

  @spec handle_delivery_report_response({atom, map}) :: fetch_response
  defp handle_delivery_report_response({:ok, %Response{
    body: "NO_DATA",
    status_code: 200
  }}) do
    {:ok, {:unknown, "NO_DATA"}}
  end

  defp handle_delivery_report_response({:ok, %Response{
    body: body,
    status_code: 200
  }}) do
    case :erlsom.simple_form(body) do
      {:ok, xml, _} ->
        parse_valid_delivery_response(xml)
      {:error, reason} ->
        {:error, {:erlsom, reason}}
    end
  end

  defp handle_delivery_report_response({:ok, %Response{
    status_code: status_code
  }}) do
    {:error, {:http, status_code}}
  end

  defp handle_delivery_report_response({:error, %Error{
    id: _id,
    reason: reason
  }}) do
    handle_http_error(reason)
  end

  @spec parse_valid_delivery_response(tuple) :: fetch_response
  defp parse_valid_delivery_response(xml) do
    case xml do
      {'DeliveryReport', [],
       [{'message',
         [{'pducount', _}, {'price', _}, {'gsmerror', _},
          {'status', status}, {'donedate', delivery_date},
      {'sentdate', _}, {'id', _}], []}]} ->
        status =
          status
          |> to_string
          |> String.downcase
          |> String.to_atom
        {:ok, {status, to_string(delivery_date)}}
      _else ->
        {:error, {:parse, "Unrecognised response"}}
    end
  end

end
