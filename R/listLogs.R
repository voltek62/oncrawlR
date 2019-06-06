#' List all pages from logs monitoring
#'
#' @param : projectID
#'
#' @details
#'
#' ResCode
#' 400 : Returned when the request has incompatible values or does not match the API specification.
#' 401 : Returned when the request is not authenticated.
#' 403 : Returned the current quota does not allow the action to be performed.
#' 404 : Returned when any of resource(s) referred in the request is not found.
#' 403 : Returned when the request is authenticated but the action is not allowed.
#' 409 : Returned when the requested operation is not allowed for current state of the resource.
#' 500 : Internal error
#'
#' @examples
#' \dontrun{
#' pages <- listLogs(projectID)
#' }
#' @return Json
#' @author Vincent Terrasi
#' @export
listLogs <- function(projectId) {

  KEY <- getOption('oncrawl_token')
  DEBUG <- getOption('oncrawl_debug')
  API <- getOption('oncrawl_api')

  if(nchar(KEY)<=10) {
    testConf <- initAPI()
    if(testConf=="error")
      return()
  }

  curl <- getCurlHandle()

  pageAPI <- paste0(API,"data/project/", projectId,"/log_monitoring/pages", sep = "")

  curl <- getCurlHandle()

  hdr  <- c('Content-Type'="application/json"
            ,Authorization=paste("Bearer",KEY)
  )

  jsonbody <- toJSON(list("fields"=c(
                                      "url",#"url_ext","url_first_path","url_has_params","url_host","url_is_resource",
                                      "urlpath",
                                      "crawl_hits",
                                      #"crawl_hits_frequency","crawl_hits_frequency_google","crawl_hits_frequency_google_smartphone","crawl_hits_frequency_google_web_search",
                                      "crawl_hits_google","crawl_hits_google_smartphone","crawl_hits_google_web_search",
                                      "is_active","is_active_google","is_active_intraday","is_active_intraday_google",
                                      "is_crawled","is_crawled_google","is_crawled_google_smartphone","is_crawled_google_web_search",
                                      "is_crawled_intraday","is_crawled_intraday_google","is_crawled_intraday_google_smartphone","is_crawled_intraday_google_web_search",
                                      "is_newly_active","is_newly_active_google","is_newly_active_intraday","is_newly_active_intraday_google",
                                      "is_newly_crawled","is_newly_crawled_google","is_newly_crawled_google_smartphone","is_newly_crawled_google_web_search",
                                      "is_newly_crawled_intraday","is_newly_crawled_intraday_google","is_newly_crawled_intraday_google_smartphone","is_newly_crawled_intraday_google_web_search",
                                      "is_newly_inactive","is_newly_inactive_google",
                                      "is_newly_uncrawled","is_newly_uncrawled_google","is_newly_uncrawled_google_smartphone","is_newly_uncrawled_google_web_search",
                                      "new_visit_delay","new_visit_delay_google",
                                      #"querystring_key","querystring_keyvalue",
                                      #"size_in_bytes",
                                      #"status_codes","status_codes_google","status_codes_google_smartphone","status_codes_google_web_search"
                                      "seo_visits_device_desktop","seo_visits_device_mobile","seo_visits_google","seo_visits_google_device_desktop","seo_visits_google_device_mobile",
                                      "seo_visits"
                                     ),
                          export=TRUE))

  reply <- postForm(pageAPI,
                    .opts=list(httpheader=hdr, postfields=jsonbody),
                    curl = curl,
                    style = "POST"
  )

  info <- getCurlInfo(curl)

  if (info$response.code==200) {
    # return ok if response.code==200
    csv <- read.csv(text = readLines(textConnection(reply)), sep = ";", header = TRUE)
    print("ok")
  } else {
    # return error if response.code!=200
    print(reply)
    return("error")
  }

  return(csv)
}
