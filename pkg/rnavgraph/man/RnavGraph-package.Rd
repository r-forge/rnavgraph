\name{RnavGraph-package}
\alias{RnavGraph-package}
\alias{RnavGraph}
\docType{package}
\title{Overview RnavGraph package}
\description{
  GUI to explore high dimensional data using graphs as navigational
  infrastructure.

  This package implements some of the methods described in the Hurley
  and Oldford paper.

  Visualization instructions can be linked to a bullet on the graph. The
  bullet can be moved along the graph.

  With the \code{tk2d} graphics device, provided by the \pkg{RnavGraph}
  package, one can display images, glyphs, text and glyphs and modify
  their location smoothly.
}
\details{
The package vignette provides a detailed overview of the \pkg{RnavGraph}
package. Use \code{vignette("RnavGraph")}.
}
\author{
Adrian Waddell and R. Wayne Oldford
}
\references{
C. B. Hurley and R. W. Oldford. ''Graphs as navigational infrastructure for high dimensional data spaces.'' Computational Statistics (2011). 
}


\keyword{ dynamic }
\keyword{ graphs }
\keyword{ multivariate }
\keyword{ classif }

\seealso{
\code{\link{navGraph}}
}

\examples{
ng.iris <- ng_data(name = "iris", data = iris[,1:4],
		shortnames = c('s.L', 's.W', 'p.L', 'p.W'),
		group = iris$Species,
		labels = substr(iris$Species,1,2))

\donttest{nav <- navGraph(ng.iris)}
}
