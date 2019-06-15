#' Prepare Token for API calls
#'
#' @examples
#' \donttest{
#' initAPI()
#' }
#'
#' @return character if no error with API authentification
#' @author Vincent Terrasi
#' @export
#' @importFrom utils read.csv read.delim
#'
initAPI <- function() {

  API <- "https://app.oncrawl.com/api/v2/"

  path <- getwd()
  # if test
  path <- gsub("/tests/testthat","",path, fixed=TRUE)
  path <- paste0(path,"/oncrawl_configuration.txt")

  if(!file.exists(path)){

    warning("Please, set your API Key in the file oncrawl_configuration.txt")

    fileConn<-file(path)
    writeLines(c("key = ","debug = FALSE", paste0("api = ",API)), fileConn)
    close(fileConn)

    return("error")
  }

  tab <- read.delim(path, header=FALSE, sep="=", stringsAsFactors = FALSE, strip.white=FALSE)

  if (!exists("tab")) {

    warning("Please, set your API Key in the file oncrawl_configuration.txt")

    fileConn<-file(path)
    writeLines(c("key = ","debug = FALSE", paste0("api = ",API)), fileConn)
    close(fileConn)

    return("error")
  }

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

  if(nchar(token)<=10) {
    warning("Please, set your API Key in the file oncrawl_configuration.txt")
    return("error")
  }

  return("ok")
}
