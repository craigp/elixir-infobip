ExUnit.start

defmodule Infobip.HelperTest do
  use ExUnit.Case

  setup do
    message_id = 1234
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
      delivered: delivered,
      bypass: bypass,
      valid_delivery_report_response: valid_delivery_report_response,
      message_id: message_id,
      no_data_response: no_data_response
    }}
  end

end
