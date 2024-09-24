
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
  real alpha;
  vector[P] true_theta;
  row_vector[I] true_lambda;
  row_vector[I] true_tau;
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
generated quantities{
  real rmsd_theta=rmsd(theta, true_theta);
  real rmsd_lambda=rmsd(lambda', true_lambda');
  real rmsd_tau=rmsd(tau', true_tau');
}
