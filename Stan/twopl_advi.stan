
data{
  int P;
  int I;
  array[P,I] int Y;
  real<lower=0> coefHyper;
  vector[P] StdSumScore;
}
parameters{
  row_vector[I] tau;
  row_vector[I] lambda;
}
model{
  theta ~ std_normal();
  tau ~ normal(0, coefHyper);
  lambda ~ normal(0, coefHyper);
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambda[i] + tau[i]);
  }
}
