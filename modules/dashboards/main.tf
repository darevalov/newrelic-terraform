###########################################################
# Modyo Monitoring Dashboard
###########################################################

###########################################################
# Variable declarations

variable "dashboard_name" {
  type = string
}

variable "newrelic_api_key" {
  type = string
}

variable "client_name" {
  type = string
}

variable "newrelic_account_id" {
  type = string
}

variable "modyo_app_guid" {
  type = string
}

variable "dynamic_pages" {
  type = map
}

###########################################################
# NewRelic One Dashboard Resource
resource "newrelic_one_dashboard" "this" {
  account_id = var.newrelic_account_id
  name = var.dashboard_name

  # Single App DashBoard Page
  page {
    name = "${var.client_name}(${var.environment})"
    widget_area {
      title = "Transaction Time"
      row = 1
      column = 1
      width = 12
      height = 4
      nrql_query {
        account_id = var.newrelic_account_id
        query = "SELECT average(((totalTime OR duration OR 0) + (queueDuration OR 0) OR 0) * 1000) AS 'Response time', average((queueDuration OR 0) * 1000) AS 'Request queuing', average((externalDuration OR 0) * 1000) AS 'Externals', average((gcCumulative OR 0) * 1000) AS 'GC', average((((totalTime OR duration OR 0) - (externalDuration OR 0) - (databaseDuration OR 0) - (gcCumulative OR 0)) OR 0) * 1000) AS 'Application time' FROM Transaction WHERE entityGuid = '${var.modyo_app_guid}' TIMESERIES SINCE 1800 seconds ago EXTRAPOLATE"        
      }
    }
    widget_line {
      title = "Throughput"
      row = 2
      column = 1
      width = 4
      height = 3
      nrql_query {
        account_id = var.newrelic_account_id        
        query = "SELECT rate(count(apm.service.transaction.duration), 1 minute) as 'Web throughput' FROM Metric WHERE (entity.guid = '${var.modyo_app_guid}') AND (transactionType = 'Web') SINCE 1800 seconds AGO TIMESERIES"        
      }
    }  
    widget_line {
      title = "Error Rate"
      row = 2
      column = 5
      width = 4
      height = 3
      nrql_query {
        account_id = var.newrelic_account_id
        query = "SELECT count(apm.service.error.count) / count(apm.service.transaction.duration) as 'Web errors' FROM Metric WHERE (entity.guid = '${var.modyo_app_guid}') AND (transactionType = 'Web') SINCE 1800 seconds AGO TIMESERIES"
      }
    }
    widget_line {
      title = "Appdex Score"
      row = 2
      column = 9
      width = 4
      height = 3
      nrql_query {
        account_id = var.newrelic_account_id
        query = "SELECT apdex(apm.service.apdex) as 'App server', apdex(apm.service.apdex.user) as 'End user' FROM Metric WHERE (entity.guid = '${var.modyo_app_guid}') SINCE 1800 seconds AGO TIMESERIES"
      }
    }  
  }

  # Dynamic DashBoard Page (Dynamic Block)
  dynamic "page" {
    for_each = var.microservices
    content {
      name = page.value.page_name
      widget_area {
        title = "Transaction Time"
        row = 1
        column = 1
        width = 6
        height = 3
        nrql_query {
          account_id = var.newrelic_account_id
          query = "SELECT average(((totalTime OR duration OR 0) + (queueDuration OR 0) OR 0) * 1000) AS 'Response time', average((queueDuration OR 0) * 1000) AS 'Request queuing', average((externalDuration OR 0) * 1000) AS 'Externals', average((gcCumulative OR 0) * 1000) AS 'GC', average((((totalTime OR duration OR 0) - (externalDuration OR 0) - (databaseDuration OR 0) - (gcCumulative OR 0)) OR 0) * 1000) AS 'Application time' FROM Transaction WHERE entityGuid = '${page.value.service_guid}' TIMESERIES SINCE 1800 seconds ago EXTRAPOLATE"
        }
      }
      widget_area {
      title = "External services (Slowest Average Time Responses) ms"
        row = 1
        column = 7
        width = 6
        height = 3
        nrql_query {
          account_id = var.newrelic_account_id
          query = "SELECT average(apm.service.external.host.duration) * 1000 FROM Metric WHERE (entity.guid = '${page.value.service_guid}') FACET `external.host` LIMIT 5 SINCE 1800 seconds AGO TIMESERIES"
        }
      }
      widget_line {
      title = "Throughput"
        row = 2
        column = 1
        width = 2
        height = 3
        nrql_query {
          account_id = var.newrelic_account_id
          query = "SELECT rate(count(apm.service.transaction.duration), 1 minute) as 'Web throughput' FROM Metric WHERE (entity.guid = '${page.value.service_guid}') AND (transactionType = 'Web') SINCE 1800 seconds AGO TIMESERIES"
        }
      }     
      widget_line {
        title = "Error rate percentage"
        row = 2
        column = 3
        width = 2
        height = 3
        nrql_query {
          account_id = var.newrelic_account_id
          query = "SELECT count(apm.service.error.count) / count(apm.service.transaction.duration) as 'Web errors' FROM Metric WHERE (entity.guid = '${page.value.service_guid}') AND (transactionType = 'Web') SINCE 1800 seconds AGO TIMESERIES"
        }                
      }
      widget_line {
        title = "Apdex"
        row = 2
        column = 5
        width = 2
        height = 3
        nrql_query {
          account_id = var.newrelic_account_id
          query = "SELECT apdex(apm.service.apdex) as 'App server', apdex(apm.service.apdex.user) as 'End user' FROM Metric WHERE (entity.guid = '${page.value.service_guid}') SINCE 1800 seconds AGO TIMESERIES"
        }
      } 
      widget_area {
        title = "Error count by Transaction"
        row = 2
        column = 7
        width = 6
        height = 3
        nrql_query {
          account_id = var.newrelic_account_id
          query = "SELECT count(*) FROM TransactionError WHERE (entityGuid='${page.value.service_guid}') AND (`error.expected` IS FALSE OR `error.expected` IS NULL) FACET `error.class`, `transactionUiName` LIMIT 5 SINCE 1800 seconds AGO TIMESERIES EXTRAPOLATE"
        }
      }                  
    }
  }
}
