\name{completegraph}
\alias{completegraph}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  Create a complete graph of class graphAM
}
\description{
  (From Wikipedia) A complete graph is a simple graph in which every
  pair of distinct vertices is connected by a unique edge.
}
\usage{
completegraph(nodeNames)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{nodeNames}{ Numeric or character string vector. }
}
%\details{}
\value{
  graphAM object.
}
%\references{%% ~put references to the literature/web site here ~}
\author{
Adrian Waddell and R. Wayne Oldford
}
%\note{%%  ~~further notes~~}

\seealso{
  \code{\link{navGraph}}, \code{\link{newgraph}},
  \code{\link{linegraph}}
}
\examples{
G1 <- completegraph(1:10)
G2 <- completegraph(LETTERS[1:7])
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ graph }

