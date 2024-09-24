
functions{
  real rmsd(vector x, vector y){
    return mean(sqrt((x-y).^2));
  }
}
data{
  int P;
  int I;
  array[P,I] int Y;
  real<lower=0> coefHyper;
  vector[P] StdSumScore;
  row_vector[I] true_lambda;
  row_vector[I] true_tau;
}
parameters{
  row_vector[I] tau;
  row_vector[I] lambda;
}
model{
  StdSumScore ~ std_normal();
  tau ~ normal(0, coefHyper);
  lambda ~ normal(0, coefHyper);
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(StdSumScore*lambda[i] + tau[i]);
  }
}
generated quantities{
  real rmsd_lambda=rmsd(lambda', true_lambda');
  real rmsd_tau=rmsd(tau', true_tau');
}
