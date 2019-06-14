#' Transform a character array of URLs into JSON file for OnCrawl platform
#'
#' @param list_urls your urls
#' @param namefile the filename for the JSON export
#'
#' @examples
#' mylist <- c("/cat/domain","/cat/")
#' oncrawlCreateSegmentation(mylist,"test.json")
#'
#' @return JSON file
#' @author Vincent Terrasi
#' @export
oncrawlCreateSegmentation <- function(list_urls, namefile) {

  #TODO:check dataset
  if(!is.character(list_urls)) {
    warning('the first argument must be a character array')
    return()
  }

  # limit to 15 segments
  if (length(list_urls)>15)
    list_urls <- list_urls[1:15]

  newlist <- list()
  max <- length(list_urls)

  colors <- c('#e6194b', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#46f0f0', '#f032e6', '#bcf60c', '#fabebe', '#008080', '#e6beff', '#9a6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#808080', '#ffffff', '#000000')

  i <- 1

  for ( cat in list_urls ) {

    candidates <- grep(cat,list_urls)
    nbcandidates <- length(candidates)

    if (nbcandidates==1) {
      temp <- list(
        color=colors[i],
        name=cat,
        oql=list(field= c("urlpath","startswith",cat))
      )
    }
    else {

      listCandidates <- list(list(field= c("urlpath","startswith",cat)))

      # iterate with each candidates
      for (j in candidates) {

        if (cat!=list_urls[j]) {
          listCandidates <- rlist::list.append(listCandidates, list(field= c("urlpath","not_startswith",list_urls[j])))
        }

      }

      temp <- list(
        color=colors[i],
        name=cat,
        # use with AND
        oql=list(and=listCandidates)
      )

    }

    newlist <- rlist::list.append(newlist,temp)
    i <- i+1
  }

  json <- jsonlite::toJSON(newlist)
  readr::write_lines(json,namefile)

  warning("your json file is generated")

}


splitURL <- function(url) {

  list <- unlist(strsplit(url, "/"))
  str <- list()

  while (length(list) > 1) {
    # get size
    max <- length(list)
    # disassemble URL
    str <- append(str, paste(list[1:max],collapse='/'))
    # prepare next
    max <- max - 1
    list <- list[1:max]
  }

  str
}


#' Split URLs
#'
#' @param list_urls your urls
#' @param limit the maximum of URLS you want
#'
#' @examples
#' mylist <- c("/cat/domain/web/","/cat/","/cat/domain/")
#' oncrawlSplitURL(mylist, 2)
#'
#' @return data.frame
#' @author Vincent Terrasi
#' @export
oncrawlSplitURL <- function(list_urls, limit=15) {

  uniqueUrlPath <- unique(as.character(list_urls))

  # split URLs
  allUrlPath <- lapply(uniqueUrlPath, splitURL)
  allUrlPath <- unlist(allUrlPath)

  # Method by frequency
  allUrlPath <- sort(table(allUrlPath), decreasing = TRUE)
  allUrlPath <- as.data.frame(allUrlPath, stringsAsFactors=F)
  colnames(allUrlPath) <- c("url","freq")

  # respect your limit
  top <- dplyr::top_n(allUrlPath, limit)

  return(top)

}

#' Train XGBoost Model
#'
#' @param dataset your data frame
#' @param nround number of iterations
#' @param verbose display errors ?
#'
#' @examples
#' \donttest{
#' list <- oncrawlTrainModel(dataset)
#' plot(list$roc)
#' print(list$matrix)
#' }
#'
#' @return a list with your ML model, your training data
#' @author Vincent Terrasi
#' @export
#' @importFrom stats predict
#' @importFrom rlang .data
#'
oncrawlTrainModel <- function(dataset, nround=300, verbose=1) {

  #TODO: test if var crawl_hits_google
  if (which("crawl_hits_google"==names(dataset))==0) {
    warning("You need logs data with a column named crawl_hit_data")
    return()
  }

  #create training dataset : predit hit_crawls
  dataset <- dplyr::select(dataset,
                             -.data$url
                             ,-.data$title
                             ,-.data$h1
                             ,-.data$fetch_date
                             ,-dplyr::contains("urlpath")
                             ,-dplyr::contains("hreflang_")
                             ,-dplyr::contains("meta_")
                             ,-dplyr::contains("is_")
                             ,-dplyr::contains("redirect_")
                             ,-dplyr::contains("twc_")
  )


  # logistic regression 0 or 1 : choose a thresold
  dataset$crawl_hits_google[which(is.na(dataset$crawl_hits_google))] <- 0
  #thresold <- median(datasetMatAll$crawl_hits_google)
  thresold <- mean(dataset$crawl_hits_google)
  dataset$crawl_hits_google[which(dataset$crawl_hits_google <= thresold )] <- 0
  dataset$crawl_hits_google[which(dataset$crawl_hits_google != 0)] <- 1

  # remove all NA
  datasetMat <- dataset[,colSums(is.na(dataset))<nrow(dataset)]

  ## 75% of the sample size
  smp_size <- floor(0.75 * nrow(datasetMat))
  train_ind <- sample(seq_len(nrow(datasetMat)), size = smp_size)

  X <- datasetMat[train_ind, ]
  X_test <- datasetMat[-train_ind, ]
  y<- datasetMat[train_ind, "crawl_hits_google"]
  y_test<-datasetMat[-train_ind, "crawl_hits_google"]

  # wt = without target
  X_wt <- dplyr::select(X,
                        -.data$crawl_hits,
                        -.data$crawl_hits_google,
                        -.data$crawl_hits_google_smartphone,
                        -.data$crawl_hits_google_web_search
  )

  # wt = without target
  X_test_wt <- dplyr::select(X_test,
                             -.data$crawl_hits,
                             -.data$crawl_hits_google,
                             -.data$crawl_hits_google_smartphone,
                             -.data$crawl_hits_google_web_search
  )

  # create the model
  model <- xgboost::xgboost(data = data.matrix(X_wt),
                   label = data.matrix(y),
                   eta = 0.1,
                   max_depth = 10,
                   verbose= verbose,
                   nround = nround,
                   objective = "binary:logistic",
                   nthread = 8
  )

  y_pred <- predict(model, data.matrix(X_test_wt))

  # display confusion matrix
  matrix <- caret::confusionMatrix(as.factor(round(y_pred)), as.factor(y_test))

  # display roc curb
  roc <- pROC::roc(y_test, y_pred)

  return(list(model=model,
              x=data.matrix(X_wt),
              y=data.matrix(y),
              matrix=matrix,
              roc=roc))

}

#' Explain XGBoost Model by displaying each importance variables
#'
#' @param model your XgBoost model
#' @param x your training data
#' @param y your predicted data
#' @param max the number of importance variable you want to explain
#'
#' @examples
#' \donttest{
#' list <- oncrawlTrainModel(dataset,200)
#' oncrawlExplainModel(list$model, list$x, list$y, 3)
#' }
#' @return graphs
#' @author Vincent Terrasi
#' @export
#' @importFrom graphics plot title
#' @importFrom rlang .data
#'
oncrawlExplainModel <- function(model, x, y, max=10) {

  explainer_xgb <- DALEX::explain(model,
                           data = data.matrix(x),
                           y = data.matrix(y),
                           label = "xgboost")

  #print importance variables
  vd_xgb <- DALEX::variable_importance(explainer_xgb, type = "raw")
  vd_plot <- plot(vd_xgb)
  ggplot2::ggsave("variable_importance.jpg",vd_plot)

  variables <- dplyr::arrange(vd_xgb, -vd_xgb$dropout_loss)
  variables <- as.character(variables$variable)

  # plot each importance variables
  # avoid the first row
  for(i in 2:(max+1)) {

    sv_xgb_satisfaction  <- DALEX::single_variable(explainer_xgb,
                                            variable = variables[i],
                                            type = "pdp")

    p <- plot(sv_xgb_satisfaction)
    ggplot2::ggsave(paste0("explain_",variables[i],".jpg"),p)

  }

  return(vd_plot)

}
