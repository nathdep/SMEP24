library(SMEP24)

### CONDITIONS TESTED ###

# EMPIRICAL METHODS
# "empiricalPos" (μ_λ > 0)
# "empiricalAlpha" (λ_i > α)

# STARTING VALUES
# "advi" (item inits from EAP conditioned on StdSumScore -> NUTS)
# "allRand" (all parameters initialized on U(-6,6))
# "stdSumScore" (latent traits initialized on standardized sum scores, all other parameters initialized on U(-6,6))

# MODELS
# "twopl" (2-parameter logistic item response model)
# "bifactor (item response model with 1 General factor and 2 sub-factors)

# SAMPLE SIZE
# Number of examinees = 500 or 2000

### CONTROL MATRIX ###

# --------------------------------------------
#   models    startingMethods   examineeSizes
# ---------- ----------------- ---------------
#   twopl         ALLPOS             500
#
#  bifactor       ALLPOS             500
#
#   twopl         CONTROL            500
#
#  bifactor       CONTROL            500
#
#   twopl         ALLPOS            2000
#
#  bifactor       ALLPOS            2000
#
#   twopl         CONTROL           2000
#
#  bifactor       CONTROL           2000
# --------------------------------------------

### METHODS MATRIX ###

# ----------------------------------------------------------------
#  starting_methods   empiricalMethods    models    examineeSizes
# ------------------ ------------------ ---------- ---------------
#        advi           empiricalPos      twopl          500
#
#      allRand          empiricalPos      twopl          500
#
#    StdSumScore        empiricalPos      twopl          500
#
#        advi          empiricalAlpha     twopl          500
#
#      allRand         empiricalAlpha     twopl          500
#
#    StdSumScore       empiricalAlpha     twopl          500
#
#        advi           empiricalPos     bifactor        500
#
#      allRand          empiricalPos     bifactor        500
#
#    StdSumScore        empiricalPos     bifactor        500
#
#        advi          empiricalAlpha    bifactor        500
#
#      allRand         empiricalAlpha    bifactor        500
#
#    StdSumScore       empiricalAlpha    bifactor        500
#
#        advi           empiricalPos      twopl         2000
#
#      allRand          empiricalPos      twopl         2000
#
#    StdSumScore        empiricalPos      twopl         2000
#
#        advi          empiricalAlpha     twopl         2000
#
#      allRand         empiricalAlpha     twopl         2000
#
#    StdSumScore       empiricalAlpha     twopl         2000
#
#        advi           empiricalPos     bifactor       2000
#
#      allRand          empiricalPos     bifactor       2000
#
#    StdSumScore        empiricalPos     bifactor       2000
#
#        advi          empiricalAlpha    bifactor       2000
#
#      allRand         empiricalAlpha    bifactor       2000
#
#    StdSumScore       empiricalAlpha    bifactor       2000
# ----------------------------------------------------------------

#####################################################################

CONTROL=TRUE # Run control model?
saveEnv <- TRUE # Save simulated environment (twopl()/bifactor() output) as list?
models <- c("twopl", "bifactor") # tested models
examineeSizes <- c(500, 2000) # tested examinee sample sizes
findings <- "/Users/depy/SMEP24/Findings/" # Location to save model results

args <- as.numeric(commandArgs(trailingOnly=TRUE)) # Grab JOB_ID and SGE_TASK_ID from .job file in Argon
taskNumber <- args[2] - 1 # offsetting to be compatible with methodSelect() function

if(!CONTROL){
  starting_methods <- c("advi", "allRand", "StdSumScore") # initial value methods
  empirical_methods <- c("empiricalPos", "empiricalAlpha") # empirical methods
  lambdaStatus = "TEST"

  # forming methods matrix from all combos
  methods_matrix <- expand.grid(starting_methods=starting_methods, empiricalMethods=empirical_methods, models=models,examineeSizes=examineeSizes)

  selRow <- as.vector(as.matrix(methodSelect(base10=taskNumber, methodsMatrix=methods_matrix))) # Select row of methods matrix given SGE_TASK_ID number in Argon

  startingMethod <- selRow[1]
  empiricalMethod <- selRow[2]
  model <- selRow[3]
  selectedSampleSize <- as.numeric(selRow[4])

  cat("\n", startingMethod, " ", empiricalMethod, " ", model," ", selectedSampleSize, "\n\n")
}

if(CONTROL){
  startingMethod=c("ALLPOS", "CONTROL")
  empiricalMethod="NA"

  control_matrix <- expand.grid(models=models,startingMethods=startingMethod, examineeSizes=examineeSizes) # control conditions (model + examinee sample size)

  selRow <- as.vector(as.matrix(methodSelect(base10=taskNumber, methodsMatrix=control_matrix)))

  model <- selRow[1]
  lambdaStatus <- selRow[2]
  selectedSampleSize <- as.numeric(selRow[3])

  cat(paste0("\nCONTROL MODEL IS SELECTED\n\n", model," ",lambdaStatus, " ", selectedSampleSize, "\n\n"))
}

seed <- as.numeric(paste(args, collapse="")) # Generate integer for seed
fileInfo <- paste0(model, "_", empiricalMethod, "_", startingMethod,"_",selectedSampleSize,"_",args[1], "_", args[2]) # file name info for future saving

set.seed(seed) # set seed (for reproducibility)

P=selectedSampleSize # Number of examinees
I=75 # Number of items
numNeg=3 # Number of lambda values to negate in total
rHatThreshold=1.05 # Threshold for deteriming chain convergence

coefHyper=5 # Hyperparameter for unbounded/continuous/normal parameters
sdHyper=.1 # Hyperparameter for positive bounded/gamma parameters

if(model == "twopl"){
  env <- twopl() # create 2PL simulation environment/list
}

if(model == "bifactor"){
  env <- bifactor() # create bifactor simulation environment/list
}

if(saveEnv){ # save simulated environment?
  envList <- as.list(env) # convert environment to list object
  save(envList, file=paste0(getwd(), "/simData/simData_", fileInfo, ".RDS"))
}

list2env(env, envir=.GlobalEnv) # load objects in bifactor simulation into global environment

# SAMPLE STAN MODEL
modrun <- modstan$sample(
  iter_warmup=2000,
  iter_sampling=2000,
  seed=seed,
  data=ModelData,
  chains=4,
  parallel_chains=4,
  init=function()inits
)

modsum_full <- modrun$summary() # generate full posterior descriptives

# Retrieve sampled RMSD (Est. - True) Samples
modsum_rmsd <- modsum_full[grepl("^rmsd", modsum_full$variable),]

# Split posterior descriptives by parameter (theta/lambda/tau)
modsum_save_lambda <- modsum_full[grepl("^lambda", modsum_full$variable),]
modsum_save_tau <- modsum_full[grepl("^tau", modsum_full$variable),]
modsum_save_theta <- modsum_full[grepl("^theta", modsum_full$variable),]

# Add true value columns for post-processing/comparisons
if(model == "twopl"){
  modsum_save_lambda$true <- lambda
}

if(model == "bifactor"){
  modsum_save_lambda$true <- c(lambda_G, lambda_g12)
}

modsum_save_tau$true <- tau
modsum_save_theta$true <- as.vector(theta)

modsum_save_lambda <- modsum_save_lambda[,c(1, ncol(modsum_save_lambda), 2:(ncol(modsum_save_lambda)-1))]
modsum_save_tau <- modsum_save_tau[,c(1, ncol(modsum_save_tau), 2:(ncol(modsum_save_tau)-1))]
modsum_save_theta <- modsum_save_theta[,c(1, ncol(modsum_save_theta), 2:(ncol(modsum_save_theta)-1))]

# SAVING RESULTS
write.csv(modsum_save_lambda, paste0(findings, "Reduc_Modsum_lambda_", fileInfo, ".csv"))
write.csv(modsum_save_tau, paste0(findings, "Reduc_Modsum_tau_", fileInfo, ".csv"))
write.csv(modsum_save_theta, paste0(findings, "Reduc_Modsum_theta_", fileInfo, ".csv"))
write.csv(modsum_rmsd, paste0(findings, "RMSD_Modsum_", fileInfo, ".csv"))
write.csv(modsum_full, paste0(findings, "Full_Modsum_", fileInfo, ".csv"))

nBadRhats <- countRhat(modsum_full, rHatThreshold = rHatThreshold) # Indicator for Rhats > 1.05

file.rename(from=paste0(getwd(), "/simData/simData_", fileInfo, ".RDS"), to=paste0(getwd(),"/DONE/simData_", fileInfo, ".RDS"))

if(nBadRhats != 0){

  badRhatModsum <- modsum_full[which(modsum_full$rhat > rHatThreshold),] # filter for posterior descriptives that exceed Rhat threshold (non-converging)
  write.csv(badRhatModsum, paste0(findings, "BadRhat_Modsum_", fileInfo, ".csv")) # write non-convergent parameter posterior descriptives to .csv file

  sink(paste0(findings, "Names_BadRhat_", model, "_", selectedSampleSize, "_", empiricalMethod, "_", startingMethod, ".csv"), append=TRUE) # begin appending <model>_<method>_badCount.csv file
  cat(paste0(nBadRhats,",", model, ",", selectedSampleSize, ",", empiricalMethod, ",", startingMethod, ",", args[1], ",", args[2], "\n")) # write result
  sink() # close connection

}
