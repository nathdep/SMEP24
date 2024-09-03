
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
  row_vector[I] tau;

  real<lower=0> sigma_lambdaG;
  real<lower=0> sigma_lambdag12;

  real<lower=0> mu_lambdaG;
  vector<lower=0>[nDim-1] mu_lambdag12;

  vector<lower=0>[I] lambdaG;
  vector<lower=alpha>[I] lambdag12;
}
model{
  to_vector(theta) ~ std_normal();
  tau ~ normal(0, coefHyper);

  sigma_lambdaG ~ gamma(1, sdHyper);
  sigma_lambdag12 ~ gamma(1, sdHyper);

  mu_lambdaG ~ lognormal(1, coefHyper);
  mu_lambdag12 ~ normal(0, coefHyper)T[alpha,];

  lambdaG ~ lognormal(mu_lambdaG, sigma_lambdaG);
  lambdag12 ~ normal(mu_lambdag12, sigma_lambdag12);

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
