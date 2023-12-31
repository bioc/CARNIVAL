testEnvironement <- new.env()
waitingForFix = TRUE
if(! waitingForFix){
    
    #Loading data
    load(file = system.file("toy_perturbations_ex1.RData", package = "CARNIVAL"),
         testEnvironement)
    load(file = system.file("toy_network_ex1.RData", package = "CARNIVAL"),
         testEnvironement)
    load(file = system.file("toy_measurements_ex1.RData", package = "CARNIVAL"),
         testEnvironement)
    
    #Loading expected results
    load(file = system.file("toy_result_expected_ex1.RData", package = "CARNIVAL"),
         testEnvironement)
    
    perturbations <- testEnvironement$toy_perturbations_ex1
    priorKnowledgeNetwork <- testEnvironement$toy_network_ex1
    measurements <- testEnvironement$toy_measurements_ex1
    
    # Setting options 
    carnivalLpOptions <- defaultLpSolveCarnivalOptions()
    cplexSolverPath <- "/Applications/CPLEX_Studio1210/cplex/bin/x86-64_osx/cplex"
    cplexSolverPath <- "/Applications/CPLEX_Studio128/cplex/bin/x86-64_osx/cplex"
    
    carnivalCplexOptions <- defaultCplexCarnivalOptions(solverPath = cplexSolverPath)
    carnivalCbcOptions <- defaultCbcSolveCarnivalOptions()
    
    carnivalCplexOptions$outputFolder <- "./"
    
    #Testing API with lpSolve
    generateLpFileCarnival(perturbations, measurements, 
                           priorKnowledgeNetwork,
                           carnivalOptions = carnivalCplexOptions)
    #runFromLpCarnival()
    inverseCarnival <- runInverseCarnival(measurements, priorKnowledgeNetwork,
                                          carnivalOptions = carnivalCplexOptions)
    
    isInputValidCarnival(perturbations, measurements, 
                         priorKnowledgeNetwork, 
                         carnivalOptions = carnivalLpOptions)
    
    vanillaCarnivalOutput <- runVanillaCarnival(perturbations, measurements, 
                                                priorKnowledgeNetwork,
                                                carnivalOptions = carnivalLpOptions) 
    
    # vanillaCarnivalWeightedOutput <- runVanillaCarnival(perturbations, measurements, 
    #                                                     priorKnowledgeNetwork, 
    #                                                     weights, 
    #                                                     carnivalOptions = carnivalLpOptions)
    
    
    
    #cplex
    vanillaCarnivalCplexOutput <- runVanillaCarnival(perturbations, measurements, 
                                                     priorKnowledgeNetwork,
                                                     carnivalOptions = carnivalCplexOptions) 
    
    #cbc 
    vanillaCarnivalCplexOutput <- runVanillaCarnival(perturbations, measurements, 
                                                     priorKnowledgeNetwork,
                                                     carnivalOptions = carnivalCbcOptions) 
    
}
