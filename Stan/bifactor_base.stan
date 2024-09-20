
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
  row_vector<lower=0>[I] lambdaG;
  row_vector<lower=0>[I] lambdag12;
  row_vector[I] tau;
}
model{
  to_vector(theta) ~ std_normal();
  lambdaG ~ normal(0, coefHyper)T[0,];
  lambdag12 ~ normal(0, coefHyper)T[0,];
  tau ~ normal(0, coefHyper);
  matrix[I, nDim] lambdaQ = append_row(lambdaG, rep_matrix(lambdag12,2))'.*Qmat;
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambdaQ[i,]' + tau[i]);
  }
}
