#' Import compiled Stan object
#'
#' @param lv_type a character indicating the type of FLPS model.
#' @param multilevel a logical indicating multilevel Stan model.
#' @param lv_randomeffect A logical indicating whether to estimate random effects for latent variables.
#'
#' @return a Stan compiled stanmodel object generated by \code{modelBuilder}
#'
#' @export
importModel <- function(lv_type, multilevel = FALSE, lv_randomeffect = FALSE) {

  lv_type <- match.arg(tolower(lv_type), c("rasch","irt","2pl","grm","sem","lca","lpa"))
  lv_type <- ifelse(toupper(lv_type) == "2PL", "irt", tolower(lv_type))

  stan_path <- system.file("stan", package = "flps")
  stan_list <- list.files(stan_path, pattern = "RDS$",full.names = TRUE,recursive = T)

  if(multilevel) {
    level = "multilevel"
    if(lv_randomeffect) {
      randomeff = "_Random"
    } else {
      randomeff = "_noRandom"
    }
  } else {
    level = "singlelevel"
    randomeff = ""
  }

  stanfiles <- stan_list[grepl("RDS$", stan_list)]

  stanfiles <- stanfiles[!grepl("threeclass", stanfiles)]
  stanfiles <- stanfiles[!grepl("deprecated", stanfiles)]

  stanfiles <- stanfiles[grepl(level, stanfiles)]
  stanfiles <- stanfiles[grepl(randomeff, stanfiles)]
  stanfiles <- stanfiles[grepl(lv_type, tolower(stanfiles))]

  if(length(stanfiles) == 0) {
    stop("No compiled Stan code ready.")
  }

  readRDS(stanfiles)
}

#' Generate compiled Stan object to facilitate the analysis
#'
#' @param lv_type A character string specifying the type of FLPS model
#' @param multilevel a logical indicating multilevel Stan model.
#' @param lv_randomeffect A logical indicating whether to estimate random effects for latent variables.
#'
#' @return There's no return, but the compiled objects are saved in the package
#' root directory.
#'
#' @export
modelBuilder <- function(lv_type, multilevel = FALSE, lv_randomeffect = FALSE) {

  stan_path <- system.file("stan", package = "flps")
  stan_list <- list.files(stan_path,pattern = ".stan$",full.names = T,recursive = T)

  lv_type <- match.arg(tolower(lv_type), c("rasch","irt","2pl","grm","sem","lca","lpa"))
  lv_type <- ifelse(toupper(lv_type) == "2PL", "irt", tolower(lv_type))

  message("It will take a while....")


  if(multilevel) {
    level = "multilevel"
    if(lv_randomeffect) {
      randomeff = "_Random"
    } else {
      randomeff = "_noRandom"
    }
  } else {
    level = "singlelevel"
    randomeff = ""
  }

  stanfiles <- stan_list[grepl("stan$", stan_list)]

  stanfiles <- stanfiles[!grepl("threeclass", stanfiles)]
  stanfiles <- stanfiles[!grepl("deprecated", stanfiles)]

  stanfiles <- stanfiles[grepl(level, stanfiles)]
  stanfiles <- stanfiles[grepl(randomeff, stanfiles)]
  stanfiles <- stanfiles[grepl(lv_type, tolower(stanfiles))]

  stanmodel_obj <- rstan::stan_model(
    file = stanfiles,
    # model_code = stan_model0,
    save_dso = TRUE,
    model_name = "FLPS"

  )
  saveRDS(stanmodel_obj, gsub("\\.stan", "\\.RDS", stanfiles ))

  message(paste0(toupper(lv_type), " model saved as ", gsub("\\.stan", "\\.RDS", stanfiles )))
}

#' Load rstan model
#'
#' @param lv_type a character specifying a latent model
#' @param multilevel a logical specifying multilevel structure
#' @param lv_randomeffect A logical indicating whether to estimate random effects for latent variables.
#'
#' @return A string for Stan syntax
#' @noRd
loadRstan <- function(lv_type = "2PL", multilevel = FALSE, lv_randomeffect = FALSE) {

  if(!dir.exists(system.file("stan", package = "flps")))
    stop("The stan code does not exist!")

  stan_path <- system.file("stan", package = "flps")
  # stan_path <- "C:/Users/lee/Documents/GitHub/flps/inst/stan"
  stan_list <- list.files(stan_path,pattern = ".stan$",full.names = T,recursive = T)


  lv_type <- match.arg(tolower(lv_type), c("rasch","irt","2pl","grm","sem","lca","lpa"))
  lv_type <- ifelse(toupper(lv_type) == "2PL", "irt", tolower(lv_type))

  message("It will take a while....")

  if(multilevel) {
    level = "multilevel"
    if(lv_randomeffect) {
      randomeff = "_Random"
    } else {
      randomeff = "_noRandom"
    }
  } else {
    level = "singlelevel"
    randomeff = ""
  }

  stanfiles <- stan_list[grepl("stan$", stan_list)]

  stanfiles <- stanfiles[!grepl("threeclass", stanfiles)]
  stanfiles <- stanfiles[!grepl("deprecated", stanfiles)]

  stanfiles <- stanfiles[grepl(level, stanfiles)]
  stanfiles <- stanfiles[grepl(randomeff, stanfiles)]
  stanfiles <- stanfiles[grepl(lv_type, tolower(stanfiles))]

  given_stan_model <-
    suppressWarnings(paste(readLines(stanfiles), collapse = "\n"))
  # cat(given_stan_model)
  return(given_stan_model)
}

#' Create Stanmodel class
#'
#' @param lv_type a character specifying a latent model
#' @return A \code{\link[rstan]{stanmodel}} class
#' @noRd
mkStanModel <- function(lv_type = '2pl') {

  if(!dir.exists(system.file("stan", package = "flps")))
    stop("The stan code does not exist!")

  if(tolower(lv_type) %in% c("2pl", "3pl")) {
    lv_type <- "IRT"
  }

  if(tolower(lv_type) %in% c("rasch")) {
    lv_type <- "RASCH"
  }

  stan_path <- system.file("stan", package = "flps")
  # stan_path <- "inst/stan"
  stan_list <- list.files(stan_path)

  if(tolower(lv_type) != "lca") {
    stan_list <- stan_list[grepl(toupper("flps"), toupper(stan_list))]
  }

  stan_picked <- grepl("\\.stan", stan_list)
  stan_picked1 <- stan_list[stan_picked]

  stan_picked <- grepl(toupper(lv_type), toupper(stan_picked1))
  given_stan_model <- stan_picked1[stan_picked]

  stan_file <- file.path(stan_path, given_stan_model)

  stanfit <- rstan::stanc_builder(stan_file,
                                  allow_undefined = TRUE,
                                  obfuscate_model_name = FALSE)
  stanfit$model_cpp <- list(model_cppname = stanfit$model_name,
                            model_cppcode = stanfit$cppcode)
  # create stanmodel object
  methods::new(Class = "stanmodel",
               model_name = stanfit$model_name,
               model_code = stanfit$model_code,
               model_cpp = stanfit$model_cpp,
               mk_cppmodule = function(x) get(paste0(stanfit$model_name))
               # mk_cppmodule = function(x) get(paste0("anon_model"))
  )
}
