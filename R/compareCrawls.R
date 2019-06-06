#' Compare crawl over a crawl - NOT IMPLEMENTED
#'
#' @param : crawlID
#'
#' @details
#'
#' ResCode
#' 401 : invalid key or ip
#' 429 : Too Many Requests
#' 500 : Internal error
#' 550 : Error while generating guide.
#' 250 : Guide generation on the way. Please wait a few minutes.
#'
#' @examples
#' \dontrun{
#' crawls <- compareCrawls(crawlID)
#' }
#' @return Json
#' @author Vincent Terrasi
#' @export
compareCrawls <- function(crawlId) {

  KEY <- getOption('oncrawl_token')
  DEBUG <- getOption('oncrawl_debug')
  API <- getOption('oncrawl_api')

  if(nchar(KEY)<=10) {
    testConf <- initAPI()
    if(testConf=="error")
      return()
  }

  curl <- getCurlHandle()

  #GET ??
  # https://app.oncrawl.com/api/v2/crawl_over_crawls?filters=(field:!(id,one_of,!('5cc81e82e6b8fb584675c07f','5cc6d40be6b8fb41b7487f11','5cc57b47e6b8fb21010cbb0d','5cc42a3ee6b8fb08e8a37046','5cc2d937e6b8fb543bca0d4a','5cc1886ae6b8fb2812e54f69','5cc036afe6b8fb064a0da7ec','5cbee5e3e6b8fb5430690571','5cbd9247e6b8fb3b2a16a8e6','5cbc408be6b8fb21fdfee818','5cbafac3e6b8fb0d1e45cac3','5cb9a582e6b8fb6e3c50be7f','5cb84c46e6b8fb49348fdb36','5cb70a7be6b8fb31cdef0629','5cb5ab26e6b8fb10ff21945d','5cb4637fe6b8fb2a6441493c','5cb30647e6b8fb5a75b8c622','5cb1b4c7e6b8fb1b24ceede3','5cb077ace6b8fb3ab86c3d43')))&limit=19

  pageAPI <- paste0(API,"data/crawl_over_crawl/", crawlId,"/pages", sep = "")

  curl <- getCurlHandle()

  hdr  <- c('Content-Type'="application/json"
            ,Authorization=paste("Bearer",KEY)
  )


  jsonbody <- toJSON(list("fields"=c("url"),
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
