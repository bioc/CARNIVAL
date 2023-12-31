## Returning LP matrix for lpSolve.
##
## Enio Gjerga, 2020
prepareLPMatrixSingle <- function(lpMatrix, carnivalOptions){
  
  message("Parsing .lp file for lpSolve")
  
  if (file.exists(carnivalOptions$filenames$lpFilename)) {
    lpFile <- readr::read_csv(file = carnivalOptions$filenames$lpFilename, 
                              col_names = FALSE)
    lpFile <- lpFile[[1]]
  } else {
    stop("Cannot find .lp file for solver")
  }

  f.obj <- transformObjectiveFunction(lpMatrix, lpFile)
  
  ff1 <- transformConstraints(lpMatrix, lpFile)
  ff2 <- transformBounds(lpMatrix, lpFile)
  ff3 <- transformBinaries(lpMatrix, lpFile)
  
  f.con <- rbind(ff1$con, ff2$con, ff3$con)
  f.dir <- c(ff1$dir, ff2$dir, ff3$dir)
  f.rhs <- c(ff1$rhs, ff2$rhs, ff3$rhs)
   
  #[[1]] is needed in each index for running examples while packaging (devtools::check())
  idx1 <- match("Binaries", lpFile)
  idx2 <- match("Generals", lpFile)
  idx3 <- match("End", lpFile)
  
  binaryVar <- lpFile[seq(from = idx1 + 1, to = idx2 - 1, by = 1)]
 
  bins <- c()
  for (ii in seq_len(length(binaryVar))){
    bins <- c(bins, which(lpMatrix[, 1] == binaryVar[ii]))
  }
  
  integerVar <- lpFile[seq(from = idx2 + 1, to = idx3 - 1, by = 1)]
  ints <- c()
  
  for (ii in seq_len(length(integerVar))){
    ints <- c(ints, which(lpMatrix[, 1] == integerVar[ii]))
  }
  
  res <-  list("matrix" = lpMatrix, "obj" = f.obj, 
              "con" = f.con, "dir" = f.dir, 
              "rhs" = f.rhs, "bins" = bins, 
              "ints" = ints)
  
  message("Done: parsing .lp file for lpSolve")
  return(res)
  
}

