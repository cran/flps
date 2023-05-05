## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  eval = F,
  collapse = TRUE,
  comment = "#>",
  # fig.width = 4,
  out.width = '55%'
)

## ----setup, eval = T----------------------------------------------------------
library(flps)

## ----eval = F-----------------------------------------------------------------
#  devtools::install_github("sooyongl/flps")

## ----eval = T-----------------------------------------------------------------
set.seed(10000)
inp_data <- flps::makeInpData(
  N       = 200,  # sample size
  R2Y     = 0.2,  # r^2 of outcome
  R2eta   = 0.5,  # r^2 of eta by one covariates
  omega   = 0.2,  # the effect of eta
  tau0    = 0.23, # direct effect
  tau1    = -0.16,# interaction effect between Z and eta
  betaL   = 0.2,
  betaY   = 0.4,
  lambda  = 0.8,  # the proportion of administered items
  nitem    = 10,   # the total number of items
  nfac    = 1,    # the number of latent factors
  lvmodel = 'rasch' # tag for latent variable model; case-sensitive (use lower-case letters)
)



## ----eval = T-----------------------------------------------------------------
# Input data matrix
data.table::data.table(inp_data)

## ----eval = F-----------------------------------------------------------------
#  modelBuilder(type = "rasch")

## ----eval = F-----------------------------------------------------------------
#  remove.packages(c("rstan", "StanHeaders"))
#  install.packages("rstan", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))

## ----eval = F-----------------------------------------------------------------
#  res <- runFLPS(
#    inp_data = inp_data,
#    outcome = "Y",
#    group = "Z",
#    covariate = c("X1"),
#    lv_type = "rasch",
#    lv_model = "F =~ v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10",
#    stan_options = list(iter = 1000, warmup = 500, cores = 1, chains = 2)
#  )

## ----eval = F-----------------------------------------------------------------
#  
#  flps_plot(res, type = "causal")
#  

## ----eval = T, echo=FALSE, fig.align='center', fig.cap='', out.width='60%'----
# a1 <- flps_plot(res, type = "causal")
# ggplot2::ggsave("man/figures/causal_1.png", a1)
knitr::include_graphics('../man/figures/causal_1.png')

## ----eval = F-----------------------------------------------------------------
#  
#  flps_plot(res, type = "latent")
#  

## ----eval = T, echo=FALSE, fig.align='center', fig.cap='', out.width='60%'----
# a1 <- flps_plot(res, type = "latent")
# ggplot2::ggsave("man/figures/latent_1.png", a1)
knitr::include_graphics('../man/figures/latent_1.png')

