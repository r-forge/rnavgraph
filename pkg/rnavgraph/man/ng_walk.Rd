\name{ng_walk}
\alias{ng_walk}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  Walk a path on the current graph in a navGraph session
}
\description{
  If you create a path outside the navGraph session, you can let
  navGraph walk you path.

  A path has to be a sequence of node names of adjoining nodes in the
  current shown graph.

  If a path has been walked through, it gets added to the
  \code{activePath} in the path tool of the running navGraph session.
}
\usage{
ng_walk(nghandler, path)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{nghandler}{
    navGraph handler of a running navGraph session.
}
  \item{path}{
    Vector of node names that are adjoining in the current graph. A
  single character string with the node names separated by a space also works.
}
}
%\details{  %%  ~~ If necessary, more details than the description above ~~}
%\value{}
%\references{  %% ~put references to the literature/web site here ~}
\author{
  Adrian Waddell and R. Wayne Oldford
}
%\note{%%  ~~further notes~~}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
  \code{\link{navGraph}}
}
\examples{
## Define a NG_data object
ng.iris <- ng_data(name = "iris", data = iris[,1:4],
		shortnames = c('s.L', 's.W', 'p.L', 'p.W'))

## start a navGraph session
\donttest{nav <- navGraph(ng.iris)}

## Find linegraph
LG <- linegraph(completegraph(shortnames(ng.iris)))

## find a path
\donttest{library(PairViz)}
\donttest{path = eulerian(LG)}

## walk the path
\donttest{ng_walk(nav,path)}
}
