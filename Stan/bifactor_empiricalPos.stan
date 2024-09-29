
functions{
  real rmsd(vector x, vector y){
    return mean(sqrt((x-y).^2));
  }
}
data{

  int<lower=0> P; // Number of examinees
  int<lower=0> I; // Number of items
  int<lower=0> nDim; // Number of total factor dimensions (3 = 1G + 2g)
  array[P,I] int<lower=0, upper=1> Y; // item response integer array/matrix
  matrix[I,nDim] Qmat; // Dummy-coded (0/1) design matrix for factor loadings/lambdas Cols:[G, g1, g2]
  real<lower=0> coefHyper; // Hyperparameter for unbounded/continuous/normal parameters
  real<lower=0> lambdaMeanHyper; // Hyperparameter for distribution of loadings
  real tauMeanHyper; // Hyperparameter for distribution of item intercepts/easiness measures
  real<lower=0> sdHyper; // Hyperparameter for positive bounded/gamma parameters
  matrix[I,nDim] true_lambda;
  row_vector[I] true_tau;
  matrix[P,nDim] true_theta;

}
parameters{

  matrix[P, nDim] theta; // latent factor scores
  row_vector[I] tau; // item intercepts (easiness)

  row_vector<lower=0>[I] lambdaG; // General (G) factor loadings
  row_vector[I] lambdag_12; // Sub-factor (g) loadings

  real<lower=0> sigma_lambdaG; // variance of General (G) factor loadings
  real<lower=0> sigma_lambdag_12; // variance of sub-factor (g) loadings

  real<lower=0> mu_lambdaG; // mean/intercept of General (G) factor loadings
  real<lower=0> mu_lambdag_12;  // mean/intercept of General (G) factor loadings

}
model{
  // PRIORS //

  to_vector(theta) ~ std_normal();
  tau ~ normal(0, coefHyper);

  sigma_lambdaG ~ gamma(1, sdHyper);
  sigma_lambdag_12 ~ gamma(1, sdHyper);

  mu_lambdaG ~ normal(lambdaMeanHyper, coefHyper)T[0,];
  mu_lambdag_12 ~ normal(lambdaMeanHyper, coefHyper);

  lambdaG ~ normal(mu_lambdaG, sigma_lambdaG)T[0,];
  lambdag_12 ~ normal(mu_lambdag_12, sigma_lambdag_12);

  matrix[I,nDim] lambdaQ = append_row(lambdaG, rep_matrix(lambdag_12, 2))'.*Qmat; // concatenating matrix of loadings and multp

  // LIKELIHOOD //

  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambdaQ[i,]' + tau[i]);
  }

}
generated quantities{
  real rmsd_tau = rmsd(tau', true_tau');
  real rmsd_theta = rmsd(to_vector(theta), to_vector(true_theta));
  real rmsd_lambda=0;
  {
    matrix[nDim,I] lambdaMat = rep_matrix(0.0, nDim, I);
    lambdaMat[1,] += lambdaG;
    lambdaMat[2,] += lambdag_12;
    lambdaMat[3,] += lambdag_12;
    rmsd_lambda+=rmsd(to_vector(lambdaMat), to_vector(true_lambda'));
  }
}
