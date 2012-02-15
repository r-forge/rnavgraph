\name{NG_Visualization-class}
\Rdversion{1.1}
\docType{class}
\alias{NG_Visualization-class}

\title{Class \code{"NG_Visualization"}}
\description{
   Used when custom visualization instructions are defined using
   initializeViz, updateViz and closeViz.

   See package vignette for more details.

}
\section{Objects from the Class}{A virtual Class: No objects may be created from it.}
\section{Slots}{
  \describe{
    \item{\code{graph}:}{Graph name in slot name of NG_graph object.}
    \item{\code{data}:}{Data name in slot name of NG_data object.}
    \item{\code{from}:}{Start from node. Not used anymore.}
    \item{\code{to}:}{Start to node. Not used anymore.}
    \item{\code{varList}:}{Vector with all variable names that are used in graph.}
  }
}
\section{Methods}{
  \describe{
    \item{show}{\code{signature(object = "NG_Visualization")}: ... }
	 }
}
\author{
Adrian Waddell and Wayne Oldford
}
\note{
  Read more about the use of this class in the package vignette.
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{initializeViz-methods}}
}
\examples{
showClass("NG_Visualization")
}
\keyword{classes}
