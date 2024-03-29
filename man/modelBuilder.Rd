% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/load_rstan.r
\name{modelBuilder}
\alias{modelBuilder}
\title{Generate compiled Stan object to facilitate the analysis}
\usage{
modelBuilder(lv_type, multilevel = FALSE, lv_randomeffect = FALSE)
}
\arguments{
\item{lv_type}{A character string specifying the type of FLPS model}

\item{multilevel}{a logical indicating multilevel Stan model.}

\item{lv_randomeffect}{A logical indicating whether to estimate random effects for latent variables.}
}
\value{
There's no return, but the compiled objects are saved in the package
root directory.
}
\description{
Generate compiled Stan object to facilitate the analysis
}
