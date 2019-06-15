#' Prepare Token for API calls
#'
#' @details
#' Example file for oncrawl_configuration.txt
#'
#' key = 5516LP29W5Q9XXXXXXXXXXXXOEUGWHM9
#' debug = FALSE
#' api = https://app.oncrawl.com/api/v2/
#'
#' @examples
#' \dontrun{
#' initAPI()
#' }
#'
#' @return ok if no error with API authentification
#' @author Vincent Terrasi
#' @export
#' @importFrom utils read.csv read.delim
#'
initAPI <- function() {

  API <- "https://app.oncrawl.com/api/v2/"
  path <- getwd()
  path <- file.path(path, "oncrawl_configuration.txt")

  if(!file.exists(path)) stop("Please, set your API Key in the file oncrawl_configuration.txt")

  tab <- read.delim(path, header=FALSE, sep="=", stringsAsFactors = FALSE, strip.white=FALSE)

  if (!exists("tab")) stop("Please, set your API Key in the file oncrawl_configuration.txt")

  token <- gsub("(^[[:space:]]+|[[:space:]]+$)", "", tab[1,2])
  options(oncrawl_token = token)

  debug <- gsub("(^[[:space:]]+|[[:space:]]+$)", "", tab[2,2])
  if ( debug=="TRUE" )
    options(oncrawl_debug = TRUE)
  else
    options(oncrawl_debug = FALSE)

  api <- gsub("(^[[:space:]]+|[[:space:]]+$)", "", tab[3,2])
  options(oncrawl_api = api)

  token <- getOption('oncrawl_token')

  if(nchar(token)<=10) stop("Please, set your API Key in the file oncrawl_configuration.txt")

  return("ok")
}
