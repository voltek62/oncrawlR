# oncrawlR

### Description

This R package implements methods for querying SEO data from OnCrawl and uses a basic authentication with an API key. 

NB : To get this API key, you need to have a Oncrawl [Business plan](https://www.oncrawl.com/pricing-crawler/).

The script is explained step by step on my blog post [Complete API guide with R (package)](https://data-seo.com/2019/06/15/oncrawl-complete-api-guide-with-r/).


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
initAPI("oncrawl_configuration.txt")
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

### 5. DALEX: oncrawlTrainModel & oncrawlExplainModel

I’m a fan of DALEX: Descriptive mAchine Learning EXplanations to understand ML models. 
The name is inspired by a recurring villain of Doctor Who who spends his time saying:  Explain! 

Models are becoming more and more sophisticated due to the increasing computing power of computers and the complexity of data sources.

When you take XgBoost or neural networks, for example, they are configured with thousands or even millions of possibilities.
It is difficult to understand the relationship between the input variables and the model results, it is called a black box. 
These ML models are used because of their high performance, but their lack of interpretability remains one of their biggest weaknesses.

Unfortunately for SEO, we need to know the impact of each variable on the final model predictions. 
This is where the DALEX package comes in: <a href="https://pbiecek.github.io/DALEX_docs/" target="_blank">https://pbiecek.github.io/DALEX_docs/</a>
This package allows us to develop an understanding of a very large number of ML models.

#### For users of the R oncrawlR package: Everything can be done in 2 lines of code!

```
list <- oncrawlTrainModel(datasetMatAll,500)
oncrawlExplainModel(list$model, list$x, list$y, 8)
```

## Feedbacks
Questions and feedbacks welcome!

You want to contribute ? Open a pull request ;-) If you encounter a bug or want to suggest an enhancement, please open an issue.
