
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
  real<lower=0> lambdaMeanHyper;
  real tauMeanHyper;
  vector[P] StdSumScore;
  row_vector[I] true_lambda;
  row_vector[I] true_tau;
}
parameters{
  row_vector[I] tau;
  row_vector[I] lambda;
}
model{
  tau ~ normal(tauMeanHyper, coefHyper);
  lambda ~ normal(lambdaMeanHyper, coefHyper);
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(StdSumScore*lambda[i] + tau[i]);
  }
}
generated quantities{
  real rmsd_lambda=rmsd(lambda', true_lambda');
  real rmsd_tau=rmsd(tau', true_tau');
}
