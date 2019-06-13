#' List all pages from a crawl
#'
#' @param crawlId ID of your crawl
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
#' pages <- listPages(crawlId)
#' }
#' @return Json
#' @author Vincent Terrasi
#' @export
listPages <- function(crawlId) {

  KEY <- getOption('oncrawl_token')
  DEBUG <- getOption('oncrawl_debug')
  API <- getOption('oncrawl_api')

  if(nchar(KEY)<=10) {
    testConf <- initAPI()
    if(testConf=="error")
      return()
  }

  curl <- RCurl::getCurlHandle()

  pageAPI <- paste0(API,"data/crawl/", crawlId,"/pages", sep = "")

  hdr  <- c('Content-Type'="application/json"
            ,Authorization=paste("Bearer",KEY)
  )

  jsonbody <- jsonlite::toJSON(list("fields"=c(
                "url","urlpath",
                "status_code","status_code_range",
                #"url_ext","url_first_path","url_has_params","url_host",
                "alt_evaluation",
                "canonical_evaluation",
                "cluster_canonical_status",
                "clusters",
                "depth",
                "description_evaluation",
                #"description_hash",
                "description_length","description_length_range",
                "duplicate_evaluation",
                "external_follow_outlinks","external_nofollow_outlinks","external_outlinks","external_outlinks_range",
                "fetch_date","fetch_status",
                "fetched",
                "final_redirect_location",
                "final_redirect_status",
                "follow_inlinks",
                "h1","h1_evaluation",
                #"h1_hash","h2","h3","h4","h5","h6",
                "hreflang_cluster_id",
                #"hreflang_error_details","hreflang_errors","hreflang_hrefs","hreflang_langs","hreflang_sources",
                "inrank","inrank_decimal",
                "internal_follow_outlinks","internal_nofollow_outlinks","internal_outlinks","internal_outlinks_range",
                "is_redirect_loop","is_too_many_redirects",
                "language",
                "load_time","load_time_range",
                "meta_description","meta_robots","meta_robots_follow","meta_robots_index",
                "nb_inlinks","nb_inlinks_range","nb_outlinks_range",
                "nearduplicate_content","nearduplicate_content_similarity",
                #"ngrams",
                "nofollow_inlinks",
                "num_h1","num_h2","num_h3","num_h4","num_h5","num_h6","num_img","num_img_alt","num_img_range","num_missing_alt","num_missing_alt_range",
                "ogp_canonical_evaluation",
                #"ogp_card","ogp_evaluation","ogp_main_fields","ogp_missing_fields","ogp_optional_fields","ogp_present_fields","ogp_type",
                #"parsed_html",
                "querystring_key","querystring_keyvalue",
                "redirect_cluster_id","redirect_count","redirect_location",
                "rel_canonical","rel_next","rel_prev",
                "robots_txt_denied",
                "semantic_item_count","semantic_types",
                "similar_pages",
                "sitemaps_file_origin","sitemaps_num_alternate","sitemaps_num_images","sitemaps_num_news","sitemaps_num_videos",
                #"sources",
                #"text_to_code",
                "title","title_evaluation",
                #"title_hash",
                "title_length","title_length_range",
                #"twc_card",
                "twc_evaluation","twc_type",
                #"twc_main_fields","twc_missing_fields","twc_other_fields","twc_present_fields",
                #"twc_unexpected_fields",
                #"watched_resources",
                "weight","weight_range",
                "word_count","word_count_range"
                ),
                export=TRUE))

  reply <- RCurl::postForm(pageAPI,
                    .opts=list(httpheader=hdr, postfields=jsonbody),
                    curl = curl,
                    style = "POST"
  )

  info <- RCurl::getCurlInfo(curl)

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
