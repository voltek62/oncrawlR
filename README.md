# oncrawlR

### Description

This R package implements methods for querying SEO data from oncrawlR using its API.

This API uses a basic authentication with an API key. 

NB : To get this API key, you need to have a Oncrawl [Business plan](https://www.oncrawl.com/pricing-crawler/).

The script is explained step by step on my blog post "[Guide complet de l’API OncrawlR (package)](https://data-seo.com)"


## Install
```
#CRAN R (official version)
install.packages("oncrawlR")

#Github (dev version)
library(devtools)
devtools::install_github("voltek62/oncrawlR")
```

## Getting started
Get your oncrawlR API key and load the oncrawlR package.

This key must be copied to the root of your project in a txt file : ytg_configuration.txt

```r
token=YOURAPIKEY
debug=FALSE
api=
```

```
library(oncrawlR)
```

## Main oncrawlR functions

### 1. initAPI 
This function can check your token.

```
initAPI()
```

### 2. listProjects 
This function provides a list of your projects.

```
listProjects <- listProjects()
```

### 3. listPages 
This function provides a list of crawled pages of your website.

```
pages <- listPages(crawlId)
pages_fetched <- filter(pages,fetched=="True")
```

### 4. listLogs 
This function lists of all urls in your logs.

```
logs <- listLogs(projectId)
```

## Feedbacks
Questions and feedbacks welcome!

You want to contribute ? Open a pull request ;-) If you encounter a bug or want to suggest an enhancement, please open an issue.
