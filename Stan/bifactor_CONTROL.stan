
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
  real<lower=0> lambdaMeanHyper;
  real tauMeanHyper;
  matrix[I,nDim] true_lambda;
  row_vector[I] true_tau;
  matrix[P,nDim] true_theta;
}
parameters{
  matrix[P, nDim] theta;
  row_vector<lower=0>[I] lambdaG;
  row_vector[I] lambdag_12;
  row_vector[I] tau;
}
model{
  to_vector(theta) ~ std_normal();
  lambdaG ~ normal(lambdaMeanHyper, coefHyper)T[0,];
  lambdag_12 ~ normal(lambdaMeanHyper, coefHyper);
  tau ~ normal(tauMeanHyper, coefHyper);
  matrix[nDim,I] lambdaMat = rep_matrix(0.0, nDim, I);
  lambdaMat[1,] += lambdaG;
  lambdaMat[2,] += lambdag_12;
  lambdaMat[3,] += lambdag_12;
  matrix[I,nDim] lambdaQ = lambdaMat'.*Qmat;
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(theta*lambdaQ[i,]' + tau[i]);
  }
}
generated quantities{
  real rmsd_tau = rmsd(tau', true_tau');
  real rmsd_theta = rmsd(to_vector(theta), to_vector(true_theta));
  real rmsd_lambda=0;
  {
    matrix[nDim,I] lambdaMat = rep_matrix(0.0, nDim, I);
    lambdaMat[1,] += lambdaG;
    lambdaMat[2,] += lambdag_12;
    lambdaMat[3,] += lambdag_12;
    rmsd_lambda+=rmsd(to_vector(lambdaMat), to_vector(true_lambda'));
  }
}
