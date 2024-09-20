
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

  vector<lower=0>[I] lambdaG;
  vector<lower=alpha>[I] lambdag12;
}
model{
  to_vector(theta) ~ std_normal();
  tau ~ normal(0, coefHyper);

  lambdaG ~ normal(0, coefHyper)T[0,];
  lambdag12 ~ normal(0, coefHyper)T[alpha,];

  matrix[I, nDim] lambdaQ = append_col(lambdaG, rep_matrix(lambdag12,2)).*Qmat;

  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambdaQ[i,]' + tau[i]);
  }
}
