
data{
  int P;
  int I;
  array[P,I] int Y;
  real<lower=0> coefHyper;
  real<lower=0> sdHyper;
  real alpha;
}
parameters{
  vector[P] theta;
  row_vector[I] tau;
  row_vector<lower=alpha>[I] lambda;
}
model{
  theta ~ std_normal();
  tau ~ normal(0, coefHyper);
  lambda ~ normal(0, coefHyper)T[alpha,];
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambda[i] + tau[i]);
  }
}
