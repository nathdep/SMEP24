
data{
  int<lower=0> P;
  int<lower=0> I;
  int<lower=0> nDim;
  array[P,I] int<lower=0, upper=1> Y;
  matrix[I,nDim] Qmat;
  real<lower=0> coefHyper;
  real<lower=0> sdHyper;
  real alpha;
}
parameters{
  matrix[P, nDim] theta;
  vector<lower=alpha>[I] lambdaG;
  array[I, nDim-1] real<lower=alpha> lambdag;
  row_vector[I] tau;
  real<lower=alpha> mu_lambdaG;
  vector<lower=alpha>[nDim-1] mu_lambdag;
  real<lower=0> sigma_lambdag;
  real<lower=0> sigma_lambdaG;
}
model{
  to_vector(theta) ~ std_normal();
  mu_lambdag ~ normal(1, coefHyper)T[alpha,];
  mu_lambdaG ~ normal(1, coefHyper)T[alpha,];
  sigma_lambdag ~ gamma(1, sdHyper);
  sigma_lambdaG ~ gamma(1, sdHyper);
  lambdaG ~ normal(mu_lambdaG, sigma_lambdaG)T[alpha,];
  to_vector(lambdag) ~ normal(mu_lambdag, sigma_lambdag)T[alpha,];
  tau ~ normal(0, coefHyper);
  matrix[I, nDim] lambdaQ = append_col(lambdaG, lambdag).*Qmat;
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambdaQ[i,]' + tau[i]);
  }
}
