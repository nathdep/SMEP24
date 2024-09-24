
functions{
  real rmsd(vector x, vector y){
    return mean(sqrt((x-y).^2));
  }
}
data{
  int<lower=0> P;
  int<lower=0> I;
  int<lower=0> nDim;
  array[P,I] int<lower=0, upper=1> Y;
  matrix[I,nDim] Qmat;
  real<lower=0> coefHyper;
  matrix[P, nDim] StdSumScore;
  matrix[I,nDim-1] true_lambda;
  row_vector[I] true_tau;
}
parameters{
  row_vector<lower=0>[I] lambdaG;
  row_vector[I] lambdag_12;
  row_vector[I] tau;
}
model{
  lambdaG ~ normal(0, coefHyper)T[0,];
  lambdag_12 ~ normal(0, coefHyper)T[0,];
  tau ~ normal(0, coefHyper);
  matrix[I, nDim] lambdaQ = append_row(lambdaG, rep_matrix(lambdag_12,2))'.*Qmat;
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(StdSumScore*lambdaQ[i,]' + tau[i]);
  }
}
generated quantities{
  real rmsd_tau=rmsd(tau', true_tau');
  real rmsd_lambda=0;
  {
    matrix[I, nDim-1] lambda = append_row(lambdaG, lambdag_12);
    rmsd_lambda=rmsd(to_vector(true_lambda), to_vector(lambda));
  }
}
