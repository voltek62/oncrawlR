context("api")

require(RCurl)
require(rjson)
require(XML)
require(stringr)

test_that("The token is created", {
  # must return ok
  expect_equal(initAPI(), "ok")
})

