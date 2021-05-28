#Specific Newrelic Provider Settings
provider "newrelic" {
  alias      = "client_demo"
  account_id = "123456789" # NewRelic Tag
  api_key    = "NRAK-XXXXXXXXXXXXXXXXXXXX" # NewRelic User Api Key
}

#Client variables
module "clien_demo_dashboard" { 
  source    = "../modules/dashboards"
  providers = { newrelic = newrelic.client_demo }
  newrelic_api_key = "NRAK-XXXXXXXXXXXXXXXXXXXXX"
  newrelic_account_id = "123456789"
  client_name = "My Client"
  dashboard_name = "My Client <Environment>"
  modyo_app_guid = "MnuGuidghjqwbejqjkehyuggqwuyeudwZXXXXX" #NewRelic App Tag
  dynamic_pages = {
    page_1 = {
      page_name = "Page 1"
      service_guid = "MughgbshdbXXXXXXXXXXXXXXXXXX" #NewRelic App Tag
    }
    page_2 = {
      page_name = "Page 2"
      service_guid = "MughgbshdbXXXXXXXXXXXXXXXXXX" #NewRelic App Tag
    }
  }
}
