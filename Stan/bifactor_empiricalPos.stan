
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
  row_vector[I] tau;

  real<lower=0> sigma_lambdaG;
  real<lower=0> sigma_lambdag12;

  real<lower=0> mu_lambdaG;
  real<lower=0> mu_lambdag12;

  vector<lower=0>[I] lambdaG;
  vector[I] lambdag12;
}
model{
  to_vector(theta) ~ std_normal();
  tau ~ normal(0, coefHyper);

  sigma_lambdaG ~ gamma(1, sdHyper);
  sigma_lambdag12 ~ gamma(1, sdHyper);

  mu_lambdaG ~ normal(0, coefHyper)T[0,];
  mu_lambdag12 ~ normal(0, coefHyper)T[0,];

  lambdaG ~ lognormal(mu_lambdaG, sigma_lambdaG);
  lambdag12 ~ normal(mu_lambdag12, sigma_lambdag12);

  matrix[I, nDim] lambdaQ = append_col(lambdaG, lambdag12).*Qmat;

  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambdaQ[i,]' + tau[i]);
  }
}
