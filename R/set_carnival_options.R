#' Returns the list of supported solvers.
#'
#' @return list of currently supported solvers.
#' @export
getSupportedSolvers <- function() {
  supportedSolvers <- list(cplex = "cplex", cbc = "cbc",
                           lpSolve = "lpSolve", gurobi = "gurobi")

  return(supportedSolvers)
}

#' Returns the list of options needed/supported for each solver.
#'
#' @param solver one of the solvers available from getSupportedSolvers()
#' @param onlyRequired logic, set to TRUE if you want to obtain only
#' required options for the run
#'
#' @return list of options, solver-dependent
#' @export
#'
getOptionsList <- function(solver = "", onlyRequired = FALSE) {
  requiredGeneralCarnivalOptions <- c("solver", "betaWeight")
  optionalCarnivalOptions <- c("lpFilename", "outputFolder", "cleanTmpFiles",
                               "keepLPFiles")

  requiredCplexOptions <- c("solverPath",
                            "timelimit", "mipGap", "poolrelGap",
                            "limitPop", "poolCap", "poolIntensity",
                            "poolReplace", "threads")
  optionalCplexOptions <- c("clonelog", "workdir", "cplexMemoryLimit")

  requiredLpSolveOptions <- c()
  requiredCbcOptions <- c("solverPath", "timelimit", "poolrelGap")

  if (onlyRequired) {
    validOptions <- list("cplex" = c(requiredGeneralCarnivalOptions, requiredCplexOptions),
                         "cbc" = c(requiredGeneralCarnivalOptions, requiredCbcOptions),
                         "lpSolve" = c(requiredGeneralCarnivalOptions, requiredLpSolveOptions))
  } else {
    validOptions <- list("cplex" = c(requiredGeneralCarnivalOptions, requiredCplexOptions,
                                     optionalCplexOptions, optionalCarnivalOptions),
                         "cbc" = c(requiredGeneralCarnivalOptions, requiredCbcOptions,
                                   optionalCarnivalOptions),
                         "lpSolve" = c(requiredGeneralCarnivalOptions, requiredLpSolveOptions,
                                       optionalCarnivalOptions))
  }

  if (solver != "") {
    if (solver %in% getSupportedSolvers()) {
      validOptions <- validOptions[[solver]]
    } else {
      stop("Provided solver is not supported. List of supported solvers: ",
           paste(getSupportedSolvers(), collapse=", "))
    }
  }

  return(validOptions)
}

#' Sets CARNIVAL options for the solver.
#'
#' @param solver  one of the solvers available from getSupportedSolvers().
#' @param ... any possible options from the solver's list
#'
#' @return carnival options as list. 
#' @export
#' @examples
#' setCarnivalOptions(solver="lpSolve")
setCarnivalOptions <- function(solver = getSupportedSolvers()$lpSolve, ...) {
  if(length(list(...)) > 0) {
    if (checkOptionsValidity(solver = solver, ...)) {
      options <- list(..., solver = solver)
    } else {
      stop("Please correct options names. Use getOptionsList() to see all available options.")
    }
  } else {
    options <- list(solver = solver)
  }

  return(options)
}


#' Checks if provided option names are valid.
#'
#' @param solver  one of the solvers available from getSupportedSolvers().
#' @param ... any possible options from the solver's list
#'
#' @return TRUE/FALSE depending on the status of the checks 
#' @export
#' @examples
#' checkOptionsValidity(solver="lpSolve")
checkOptionsValidity <- function(solver = getSupportedSolvers()$lpSolve, ...) {
  options <- list(..., solver = solver)
  allOptionsValid <- TRUE

  invalidOptions <- which(!(names(options) %in% getOptionsList(solver)))

  if(is.null(names(options))) {
    warning("Empty options names provided. Use getOptionsList() to see all available options.")
    allOptionsValid <- FALSE
  }

  prepareWarningMessage <- paste0("#", invalidOptions, ":",
                                  names(options[invalidOptions]),
                                  "=", options[invalidOptions], collapse=", ")
  if(length(invalidOptions) > 0) {
    warning("Invalid options names provided (#:name=value): ", prepareWarningMessage,
            ". \nUse getOptionsList() to see all available options.")
    allOptionsValid <- FALSE
  }

  return(allOptionsValid)
}

#' Sets default CARNIVAL options for cplex.
#'
#' @param ... any possible options from the solver's list
#' @return default CPLEX solver options as a list.
#' @export
#' @examples
#' defaultCplexCarnivalOptions()
defaultCplexCarnivalOptions <- function(...){

    if ( "solver" %in% names(list(...)) ) {
      stop("Don't try to redefine solver in this function.",
            " Use other default functions for other solvers.")
    }

    options <- list(
         solverPath = searchForCPLEXSolver(),
         solver = getSupportedSolvers()$cplex,
         lpFilename = "",
         cplexCommandFilename = "",
         outputFolder = getwd(),
         betaWeight = 0.2,
         cleanTmpFiles = TRUE,
         keepLPFiles = TRUE,
         workdir = getwd())

    options <- c(options, suggestedCplexSpecificOptions())
    manuallySetOptions <- setCarnivalOptions(solver = options$solver, ...)
    options <- options[!names(options) %in% names(manuallySetOptions)]
    options <- c(options, manuallySetOptions)

    return(options)
}


#' Sets default CARNIVAL options for lpSolve.
#'
#' @param ... any possible options from the solver's list
#'
#' @return default lpSolve solver options as a list.
#' @export
#' @examples
#' defaultLpSolveCarnivalOptions()
defaultLpSolveCarnivalOptions <- function(...){

  if ( "solver" %in% names(list(...)) ) {
    stop("Don't try to redefine solver in this function.",
         " Use other default functions for other solvers.")
  }

  options <- list(
    solver = getSupportedSolvers()$lpSolve,
    lpFilename = "",
    outputFolder = getwd(),
    workdir = getwd(),
    betaWeight = 0.2,
    cleanTmpFiles = TRUE,
    keepLPFiles = TRUE
  )

  manuallySetOptions <- setCarnivalOptions(solver = options$solver, ...)
  options <- options[!names(options) %in% names(manuallySetOptions)]
  options <- c(options, manuallySetOptions)

  return(options)
}


#'  Sets default CARNIVAL options for cbc.
#'
#' @param ... any possible options from the solver's list
#'
#' @return default CbB solver options as a list.
#' @export
#' @examples
#' #defaultCbcSolveCarnivalOptions()
defaultCbcSolveCarnivalOptions <- function(...){

  if ( "solver" %in% names(list(...)) ) {
    stop("Don't try to redefine solver in this function.",
         " Use other default functions for other solvers.")
  }

  options <- list(
    solver = getSupportedSolvers()$cbc,
    solverPath = NULL,
    lpFilename = "",
    threads = 1,
    outputFolder = getwd(),
    workdir = getwd(),
    timelimit = 600,
    betaWeight = 0.2,
    poolrelGap = 0.0001,
    cleanTmpFiles = TRUE,
    keepLPFiles = TRUE
  )

  manuallySetOptions <- setCarnivalOptions(solver = options$solver, ...)
  options <- options[!names(options) %in% names(manuallySetOptions)]
  options <- c(options, manuallySetOptions)

  return(options)
}

#' Suggests cplex specific options.s
#'
#' @param ... any possible options from the solver's list
#'
#' @return  additional CPLEX solver options as a list.
#' @export
#' @examples
#' suggestedCplexSpecificOptions()
suggestedCplexSpecificOptions <- function(...) {

  if ( "solver" %in% names(list(...)) ) {
    stop("Don't try to redefine solver in this function.",
         " Use other default functions for other solvers.")
  }

  options <- list(
    threads = 0,
    clonelog = -1,
    mipGap = 0.05,
    timelimit = 3600,
    poolrelGap = 0.0001,
    limitPop = 500,
    poolCap = 100,
    poolIntensity = 4,
    poolReplace = 2,
    cplexMemoryLimit = 8192
  )

  manuallySetOptions <- setCarnivalOptions(solver = getSupportedSolvers()$cplex, ...)
  options <- options[!names(options) %in% names(manuallySetOptions)]
  options <- c(options, manuallySetOptions)

  return(options)
}

#' Suggests cbc specific options.
#'
#' @param ... any possible options from the solver's list
#'
#' @return additional CbC solver options as a list.
#' @export
#' @examples
#' suggestedCbcSpecificOptions()
suggestedCbcSpecificOptions <- function(...) {

  if ( "solver" %in% names(list(...)) ) {
    stop("Don't try to redefine solver in this function.",
         " Use other default functions for other solvers.")
  }

  options <- list(
    timelimit = 3600,
    poolrelGap = 0.0001
  )

  manuallySetOptions <- setCarnivalOptions(solver = getSupportedSolvers()$cbc, ...)
  options <- options[!names(options) %in% names(manuallySetOptions)]
  options <- c(options, manuallySetOptions)

  return(options)
}


#' Sets default options from cplex documentation.
#'
#' @param ... any possible options from the solver's list
#'
#' @return default CPLEX solver options as a list.
#' @export
#' @examples
#' defaultCplexSpecificOptions()
defaultCplexSpecificOptions <- function(...) {
  #TODO N.B. careful with scientific notation, it is switched off at another place in the code
  # (look up for scipen) - options(scipen = 0) to switch it on

  if ( "solver" %in% names(list(...)) ) {
    stop("Don't try to redefine solver in this function.",
         " Use other default functions for other solvers.")
  }

  options <- list(
        threads = 0,
        mipGap = 1e-04,
        poolrelGap = 1e75,
        limitPop = 20,
        poolCap = 2.1e9,
        poolIntensity = 0,
        poolReplace = 0,
        timelimit = 1e+75)

  manuallySetOptions <- setCarnivalOptions(solver = getSupportedSolvers()$cplex, ...)
  options <- options[!names(options) %in% names(manuallySetOptions)]
  options <- c(options, manuallySetOptions)

  return(options)
}


#' Reads options from json file.
#'
#' @param jsonFileName path to json files with setups for the solver
#'
#' @return full list of options
#' @keywords internal
#' #TODO
#'
#' #examples
#' #readOptions(jsonFileName = "inst/carnival_cplex_parameters.json")
readOptions <- function(jsonFileName = "inst/carnival_cplex_parameters.json") {
  if ("rjson" %in% (.packages())) {
    message("Loading options file for CARNIVAL:", jsonFileName)
    options  <- rjson::fromJSON(file = jsonFileName)
    return(options)
  } else {
    stop("Cannot read options from json: rjson package should be installed and loaded.")
  }
}
