
data{
  int<lower=0> P;
  int<lower=0> I;
  int<lower=0> nDim;
  array[P,I] int<lower=0, upper=1> Y;
  matrix[I,nDim] Qmat;
  real<lower=0> coefHyper;
  real<lower=0> sdHyper;
}
parameters{
  matrix[P, nDim] theta;
  vector[I] lambdaG;
  matrix[I, nDim-1] lambdag;
  row_vector[I] tau;
  real mu_lambdaG;
  vector[nDim-1] mu_lambdag;
  real<lower=0> sigma_lambdag;
  real<lower=0> sigma_lambdaG;
  real<lower=min(lambdaG)> alphaG;
  real<lower=min(lambdag)> alphag;
}
model{
  to_vector(theta) ~ std_normal();
  alphag ~ normal(0, coefHyper)T[min(lambdag),];
  alphaG ~ normal(0, coefHyper)T[min(lambdaG),];
  mu_lambdag ~ normal(1, coefHyper)T[0,];
  mu_lambdaG ~ normal(1, coefHyper)T[0,];
  sigma_lambdag ~ gamma(1, sdHyper);
  sigma_lambdaG ~ gamma(1, sdHyper);
  lambdaG ~ normal(mu_lambdaG, sigma_lambdaG);
  to_vector(lambdag) ~ normal(mu_lambdag, sigma_lambdag);
  tau ~ normal(0, coefHyper);
  matrix[I, nDim] lambdaQ = append_col(lambdaG, lambdag).*Qmat;
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambdaQ[i,]' + tau[i]);
  }
}
