
data{
  int P;
  int I;
  array[P,I] int Y;
  real<lower=0> coefHyper;
}
parameters{
  vector[P] theta;
  row_vector[I] tau;
  row_vector<lower=0>[I] lambda;
}
model{
  theta ~ std_normal();
  tau ~ normal(0, coefHyper);
  lambda ~ normal(0, coefHyper)T[0,];
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambda[i] + tau[i]);
  }
}
