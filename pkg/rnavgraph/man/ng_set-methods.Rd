\name{ng_set-methods}
\docType{methods}
\alias{ng_set-methods}
\alias{ng_set,NG_data-method}
\alias{ng_set,NG_graph-method}
\title{Change data in NG_... objects}
\description{
  Care must be taken when using the \code{ng_set} method, as one might
  create inconsistency in some objects.

  Its use is \code{ng_set(object)} to see what you can modify and
  \code{ng_set(object,"what") <- ...}. See \code{\link{ng_set<--methods}}.
}
\section{Methods}{
\describe{

\item{\code{signature(object = "NG_data")}}{ }

\item{\code{signature(object = "NG_graph")}}{ }
}}
\keyword{methods}
