use Mix.Config

config :infobip, :http,
  send_url: "http://api2.infobip.com/api/sendsms/xml",
  delivery_report_url: "http://api2.infobip.com/api/dlrpull",
  source_msisdn: "",
  sender: System.get_env("INFOBIP_SENDER"),
  host: "smpp3.infobip.com",
  port: 8888,
  system_id: System.get_env("INFOBIP_SYSTEM_ID"),
  password: System.get_env("INFOBIP_PASSWORD"),
  system_type: "",
  interface_version: 52,
  source_ton: 0,
  source_npi: 1,
  destination_ton: 1,
  destination_npi: 1,
  source_address_range: "",
  destination_address_range: "",
  enquire_link_delay_secs: 10

