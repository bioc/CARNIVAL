## Cleanup auxilliary files
##
## Enio Gjerga, 2020

cleanupCarnival <- function(carnivalOptions){
  
  if (is.null(carnivalOptions$cleanTmpFiles) | carnivalOptions$cleanTmpFiles) {
    message("Cleaning intermediate files")
    lpFile <- carnivalOptions$filenames$lpFilename 
    resultFile <- carnivalOptions$filenames$resultFile
    keepLpFiles <- carnivalOptions$keepLPFiles
    parsedData <- carnivalOptions$filenames$parsedData
    
    if(!keepLpFiles){
      if(file.exists(lpFile)){
        file.remove(lpFile)
      }
    }
    if(file.exists(parsedData)){
      file.remove(parsedData)
    }
    if(file.exists(resultFile)){
      file.remove(resultFile)
    }  
    
    
    if (carnivalOptions$solver == getSupportedSolvers()$cplex) {
      workdir <- carnivalOptions$workdir
      cplexCommandFile <- carnivalOptions$filenames$cplexCommandFile
      
      if(file.exists("cplex.log")){
        file.remove("cplex.log")
      }
      
      if(file.exists(carnivalOptions$filenames$cplexLog)){
          file.remove(carnivalOptions$filenames$cplexLog)
      }
      
      if(file.exists(cplexCommandFile)){
        file.remove(cplexCommandFile)
      }
      
      cloneFiles <- list.files(path = workdir, pattern = "$clone")
      file.remove(cloneFiles)
    }
    
    message("Done: cleaning")
  }
}