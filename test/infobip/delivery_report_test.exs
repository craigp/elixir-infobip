ExUnit.start

defmodule Infobip.DeliveryReportTest do

  use ExUnit.Case
  alias Infobip.DeliveryReport

  setup do
    message_id = "1234"
    delivered = {'DeliveryReport', [],
     [{'message', [{'pducount', '1'}, {'price', '17.0000'}, {'gsmerror', '0'},
        {'status', 'DELIVERED'}, {'donedate', '2016/09/04 15:40:22'},
        {'sentdate', '2016/09/04 15:40:21'}, {'id', '1234'}], []}]}
    valid_delivery_report_response = """
<DeliveryReport>
  <message id=\"10002\" sentdate=\"2016/09/04 15:51:44\" donedate=\"2016/09/04 15:51:45\"
    status=\"DELIVERED\" gsmerror=\"0\" price=\"17.0000\" pducount=\"1\" />
</DeliveryReport>
    """
    no_data_response = "NO_DATA"
    bypass = Bypass.open
    Application.put_env :infobip, :http, [
      send_url: "http://localhost:#{bypass.port}/api/sendsms/xml",
      delivery_report_url: "http://localhost:#{bypass.port}/api/dlrpull",
      source_msisdn: "",
      sender: "infobip",
      host: "smpp3.infobip.com",
      port: 8888,
      system_id: "Infobip",
      password: "password",
      system_type: "",
      interface_version: 52,
      source_ton: 0,
      source_npi: 1,
      destination_ton: 1,
      destination_npi: 1,
      source_address_range: "",
      destination_address_range: "",
      enquire_link_delay_secs: 10
    ]
    {:ok, %{
      message_id: message_id,
      bypass: bypass,
      delivered: delivered,
      valid_delivery_report_response: valid_delivery_report_response,
      no_data_response: no_data_response
    }}
  end

  test "handles a delivery report for a delivered messge that has already been fetched", %{
    no_data_response: no_data_response,
    bypass: bypass,
    message_id: message_id
  } do
    Bypass.expect bypass, fn conn ->
      assert "/api/dlrpull" == conn.request_path
      assert "user=Infobip&password=password&messageId=1234" == conn.query_string
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, no_data_response)
    end
    response = DeliveryReport.fetch(message_id)
    assert response == {:ok, :unknown}
  end

  test "handles a delivery report for a delivered message", %{
    valid_delivery_report_response: valid_delivery_report_response,
    bypass: bypass,
    message_id: message_id
  } do
    Bypass.expect bypass, fn conn ->
      assert "/api/dlrpull" == conn.request_path
      assert "user=Infobip&password=password&messageId=1234" == conn.query_string
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, valid_delivery_report_response)
    end
    response = Infobip.delivery_report(message_id)
    assert response == {:ok, {:delivered, "2016/09/04 15:51:45"}}
  end

end
