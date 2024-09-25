
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
  matrix[I,nDim] true_lambda;
  row_vector[I] true_tau;
}
parameters{
  row_vector<lower=0>[I] lambdaG;
  row_vector[I] lambdag_12;
  row_vector[I] tau;
}
model{
  lambdaG ~ lognormal(1, coefHyper);
  lambdag_12 ~ normal(0, coefHyper);
  tau ~ normal(0, coefHyper);
  matrix[nDim,I] lambdaMat = rep_matrix(0.0, I, nDim);
  lambdaMat[1,] += lambdaG;
  lambdaMat[2,] += lambdag_12;
  lambdaMat[3,] += lambdag_12;
  matrix[I,nDim] lambdaQ = lambdaMat'.*Qmat;
  for(i in 1:I){
    Y[,i] ~ bernoulli_logit(StdSumScore*lambdaQ[i,]' + tau[i]);
  }
}
generated quantities{
  real rmsd_tau=rmsd(tau', true_tau');
  real rmsd_lambda=0;
  {
    matrix[nDim,I] lambdaMat = rep_matrix(0.0, nDim, I);
    lambdaMat[1,] += lambdaG;
    lambdaMat[2,] += lambdag_12;
    lambdaMat[3,] += lambdag_12;
    rmsd_lambda+=rmsd(to_vector(lambdaMat), to_vector(true_lambda));
  }
}
