% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getInits.R
\name{getInits}
\alias{getInits}
\title{Get Parameter Values for Initializing NUTS}
\usage{
getInits(modsum)
}
\arguments{
\item{modsum}{object generated from `$summary()` method on a `cmdstanr` model environment}
}
\value{
a named list object containing \emph{expected a priori} from ADVI-approximated posterior draws
}
\description{
Get Parameter Values for Initializing NUTS
}
