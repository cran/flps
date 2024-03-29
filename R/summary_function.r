#' Print results
#'
#' @param x an object of class \code{\link[flps]{flps}}
#' @param ... additional options for future development
#'
#' @return Results of FLPS model are printed via the \pkg{rstan} package.
#'
#' @method print flps
#' @rdname print
#' @export
print.flps <- function(x, ...) {
  rstan::show(x$flps_fit, ...)
}



#' Summarize the results
#'
#' @param object an object of class \code{\link[flps]{flps}}
#' @param type a string for the part of FLPS model
#' @param ... additional options for future development
#'
#' @return Summary of FLPS model are printed via the \pkg{rstan} package.
#'
#' @method summary flps
#' @rdname summary.flps
#' @export
summary.flps <- function(object, type = "all", ...) {
  type <- match.arg(type, c("all","measurement","structure","causal", "classprop"))

  out <- rstan::summary(object$flps_fit, ...)

  if(type == "all") {
    out1 <- out$summary

  } else if(type == "measurement") {
    out1 <- out$summary[grepl("^(loading|intcpt|fsc|nu|p)\\[",rownames(out$summary)), ]


  } else if(type == "structure") {
    out1 <- out$summary[grepl("^(tau0)|(tau1|omega)|betaY|betaU",rownames(out$summary)), ]

    rname <- rownames(out1)



  } else if(type == "causal") {
    out1 <- out$summary[grepl("^(tau0|tau1)",rownames(out$summary)), ]

  } else if(type == "classprop") {
    out1 <- out$summary[grepl("^(nu)\\[",rownames(out$summary)), ]

    classp <- out1[, "mean"]
    classp[classp >= 0.5] <- "C1"
    classp[classp < 0.5] <- "C2"

    out1 <- table(classp)

  }

  return(out1)
}
