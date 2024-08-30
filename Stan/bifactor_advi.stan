
data{
  int<lower=0> P;
  int<lower=0> I;
  int<lower=0> nDim;
  array[P,I] int<lower=0, upper=1> Y;
  matrix[I,nDim] Qmat;
  real<lower=0> coefHyper;
  matrix[P, nDim] StdSumScore;
}
parameters{
  vector<lower=0>[I] lambdaG;
  matrix[I, nDim-1] lambdag;
  row_vector[I] tau;
}
model{
  lambdaG ~ lognormal(1, coefHyper);
  to_vector(lambdag) ~ normal(1, coefHyper);
  tau ~ normal(0, coefHyper);
  matrix[I, nDim] lambdaQ = append_col(lambdaG, lambdag).*Qmat;
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(StdSumScore*lambdaQ[i,]' + tau[i]);
  }
}
