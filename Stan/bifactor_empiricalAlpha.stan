
data{

  int<lower=0> P; // Number of examinees
  int<lower=0> I; // Number of items
  int<lower=0> nDim; // Number of total factor dimensions (3 = 1G + 2g)
  array[P,I] int<lower=0, upper=1> Y; // item response integer array/matrix
  matrix[I,nDim] Qmat; // Dummy-coded (0/1) design matrix for factor loadings/lambdas Cols:[G, g1, g2]
  array[I] int<lower=1, upper=2> QmatInd; // Integer index for identifying mu_1 and mu_2 for subfactor loadings/lambdas
  real<lower=0> coefHyper; // Hyperparameter for unbounded/continuous/normal parameters
  real<lower=0> sdHyper; // Hyperparameter for positive bounded/gamma parameters
  real alpha; // TruncNorm lower bound

}
parameters{

  matrix[P, nDim] theta; // latent factor scores
  row_vector[I] tau; // item intercepts (easiness)

  vector<lower=0>[I] lambdaG; // General (G) factor loadings
  vector[I] lambdag_12; // Sub-factor (g) loadings

  real<lower=0> sigma_lambdaG; // variance of General (G) factor loadings
  vector<lower=0>[2] sigma_lambdag_12; // variance of sub-factor (g) loadings

  real<lower=0> mu_lambdaG; // mean/intercept of General (G) factor loadings
  vector<lower=0>[2] mu_lambdag_12;  // mean/intercept of General (G) factor loadings

}
model{
  // PRIORS //

  to_vector(theta) ~ std_normal();
  tau ~ normal(0, coefHyper);

  sigma_lambdaG ~ gamma(1, sdHyper);
  sigma_lambdag_12 ~ gamma(1, sdHyper);

  mu_lambdaG ~ lognormal(1, coefHyper);
  mu_lambdag_12 ~ normal(0, coefHyper)T[alpha,];

  lambdaG ~ lognormal(mu_lambdaG, sigma_lambdaG);
  lambdag_12 ~ normal(mu_lambdag_12[QmatInd], sigma_lambdag_12[QmatInd]);

  matrix[I,nDim] lambdaQ = append_col(lambdaG, rep_matrix(lambdag_12, 2)).*Qmat; // concatenating matrix of loadings and multp

  // LIKELIHOOD //

  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambdaQ[i,]' + tau[i]);
  }

}
