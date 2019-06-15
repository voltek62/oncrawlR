# oncrawlR

### Description

This R package implements methods for querying SEO data from OnCrawl and uses a basic authentication with an API key. 

NB : To get this API key, you need to have a Oncrawl [Business plan](https://www.oncrawl.com/pricing-crawler/).

The script is explained step by step on my blog post "[Complete API guide with R (package)]( https://data-seo.com/2019/06/06/oncrawl-complete-api-guide-with-r/"


## Install
```
#CRAN R (official version) : Ongoing !
install.packages("oncrawlR")

#Github (dev version)
library(devtools)
devtools::install_github("voltek62/oncrawlR")
```

## Getting started
Get your oncrawlR API key and load the oncrawlR package.

This key must be copied to the root of your project in a txt file : oncrawl_configuration.txt

```r
token = YOURAPIKEY
debug = FALSE
api = https://app.oncrawl.com/api/v2/
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
