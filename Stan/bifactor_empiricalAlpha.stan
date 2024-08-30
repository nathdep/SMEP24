
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
  vector<lower=0>[I] lambdaG;
  real<lower=0> mu_lambdaG;
  real<lower=0> sigma_lambdaG;
  array[nDim-1] vector<lower=alpha>[I] lambdag;
  vector<lower=alpha>[nDim-1] mu_lambdag;
  real<lower=0> sigma_lambdag;
  row_vector[I] tau;
}
model{
  to_vector(theta) ~ std_normal();
  mu_lambdaG ~ lognormal(1, coefHyper);
  mu_lambdag ~ normal(1, coefHyper)T[alpha,];
  sigma_lambdag ~ gamma(1, sdHyper);
  sigma_lambdaG ~ gamma(1, sdHyper);
  lambdaG ~ normal(mu_lambdaG, sigma_lambdaG)T[alpha,];
  tau ~ normal(0, coefHyper);

  matrix[I, nDim] lambdaQ = rep_matrix(1.0, I, nDim).*Qmat;
  lambdaQ[,1] += lambdaG;

  for(dim in 2:nDim){
    lambdag[dim-1] ~ normal(1, coefHyper);
    lambdaQ[,dim] += lambdaQ[,dim].*lambdag[dim-1];
  }

  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambdaQ[i,]' + tau[i]);
  }
}
