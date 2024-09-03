
data{
  int<lower=0> P;
  int<lower=0> I;
  int<lower=0> nDim;
  array[P,I] int<lower=0, upper=1> Y;
  matrix[I,nDim] Qmat;
  array[I] int<lower=1, upper=2> QmatInd;
  real<lower=0> coefHyper;
  real<lower=0> sdHyper;
  real alpha;
}
parameters{
  matrix[P, nDim] theta;
  row_vector[I] tau;

  real<lower=0> sigma_lambdaG;
  vector<lower=0>[2] sigma_lambdag_12;

  real<lower=0> mu_lambdaG;
  vector<lower=0>[2] mu_lambdag_12;

  vector<lower=0>[I] lambdaG;
  vector[I] lambdag_12;

}
model{
  to_vector(theta) ~ std_normal();
  tau ~ normal(0, coefHyper);

  sigma_lambdaG ~ gamma(1, sdHyper);
  sigma_lambdag_12 ~ gamma(1, sdHyper);

  mu_lambdaG ~ lognormal(1, coefHyper);
  mu_lambdag_12 ~ normal(0, coefHyper)T[alpha,];

  lambdaG ~ lognormal(mu_lambdaG, sigma_lambdaG);
  lambdag_12 ~ normal(mu_lambdag_12[QmatInd], sigma_lambdag_12[QmatInd]);

  matrix[I,nDim] lambdaQ = append_col(lambdaG, rep_matrix(lambdag_12, 2)).*Qmat;

  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambdaQ[i,]' + tau[i]);
  }
}
