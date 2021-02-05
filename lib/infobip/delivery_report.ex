alias Infobip.{DeliveryReport, Common}

defmodule DeliveryReport do

  @moduledoc """
  Fetches a text message delivery report.
  """

  @type fetch_response :: {:ok, {atom, binary}} | {:error, any}

  @doc """
  Fetches a text message delivery report.
  """
  @spec fetch(binary) :: fetch_response
  def fetch(message_id) when is_binary(message_id) do
    %{
      delivery_report_url: url,
      system_id: id,
      password: pass
    } = Common.http_config()
    query = %{
      "user" => id,
      "password" => pass,
      "messageId" => message_id
    }
    url
    |> URI.parse
    |> (&%URI{&1 | query: URI.encode_query(query)}).()
    |> to_string
    |> HTTPoison.get
    |> handle_delivery_report_response
  end

  @spec handle_delivery_report_response({atom, map}) :: fetch_response
  defp handle_delivery_report_response({:ok, %HTTPoison.Response{
    body: "NO_DATA",
    status_code: 200
  }}) do
    {:ok, {:unknown, "NO_DATA"}}
  end

  defp handle_delivery_report_response({:ok, %HTTPoison.Response{
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

  defp handle_delivery_report_response({:ok, %HTTPoison.Response{
    status_code: status_code
  }}) do
    {:error, {:http, status_code}}
  end

  defp handle_delivery_report_response({:error, %HTTPoison.Error{
    id: _id,
    reason: reason
  }}) do
    Common.handle_http_error(reason)
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
