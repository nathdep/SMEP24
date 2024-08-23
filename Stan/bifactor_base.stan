
data{
  int<lower=0> P;
  int<lower=0> I;
  int<lower=0> nDim;
  array[P,I] int<lower=0, upper=1> Y;
  matrix[I,nDim] Qmat;
  real<lower=0> coefHyper;
}
parameters{
  matrix[P, nDim] theta;
  vector[I] lambdaG;
  matrix[I, nDim-1] lambdag;
  row_vector[I] tau;
}
model{
  to_vector(theta) ~ std_normal();
  lambdaG ~ normal(1, coefHyper);
  to_vector(lambdag) ~ normal(1, coefHyper);
  tau ~ normal(0, coefHyper);
  matrix[I, nDim] lambdaQ = append_col(lambdaG, lambdag).*Qmat;
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambdaQ[i,]' + tau[i]);
  }
}
