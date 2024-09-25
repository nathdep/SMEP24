
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
  real<lower=0> sdHyper;
  vector[P] true_theta;
  row_vector[I] true_lambda;
  row_vector[I] true_tau;
}
parameters{
  vector[P] theta;
  row_vector[I] tau;
  row_vector[I] lambda;
  real<lower=0> mu_lambda;
  real<lower=0> sigma_lambda;
}
model{
  mu_lambda ~ normal(0, coefHyper)T[0,];
  sigma_lambda ~ gamma(1, sdHyper);
  theta ~ std_normal();
  tau ~ normal(0, coefHyper);
  lambda ~ normal(mu_lambda, sigma_lambda);
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambda[i] + tau[i]);
  }
}
generated quantities{
  real rmsd_theta=rmsd(theta, true_theta);
  real rmsd_labmda=rmsd(lambda', true_lambda');
  real rmsd_tau=rmsd(tau', true_tau');
}
