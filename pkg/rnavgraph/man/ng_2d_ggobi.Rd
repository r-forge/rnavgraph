\name{ng_2d_ggobi}
\alias{ng_2d_ggobi}

\title{
  Visualization instruction for 2d scatterplots on a ggobi display
}
\description{
  Visualization instruction for a \code{navGraph} session that link the
  nodes of a navigation graph to 2d scatterplots and the edges to a 3d
  rigid rotation or a 4d transition.

  The scatterplots will be displayed on a ggobi display, provided by the
  \pkg{rggobi} package.
}
\usage{
ng_2d_ggobi(data, graph)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{data}{
    NG_data object.
  }
  \item{graph}{
    NG_graph object.
}
}
%\details{}
\value{
  NG_Viz2D_Ggobi object that inherits from the NG_Visualization class.
}
%\references{%% ~put references to the literature/web site here ~}
\author{
Adrian Waddell and R. Wayne Oldford
}
%\note{%%  ~~further notes~~}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
  \code{\link{navGraph}}, \code{\link{ng_data}}, \code{\link{ng_graph}},
  \code{\link{ng_get-methods}}, \code{\link{ng_set-methods}}, \code{\link{ng_2d}}, \code{\link{ng_2d_myplot}}
}
\examples{
## NG_data
ng.iris <- ng_data(name = "iris", data = iris[,1:4],
		shortnames = c('s.L', 's.W', 'p.L', 'p.W'),
		group = iris$Species)

## NG_graph
G <- completegraph(shortnames(ng.iris))
LG <- linegraph(G, sep = "::")
ng.lg <- ng_graph("3d transition", LG, "::", "kamadaKawaiSpring" )

## Visualization instruction
\donttest{
viz1 <- ng_2d_ggobi(ng.iris, ng.lg) 
}
\donttest{
viz1
}

## Start a navGraph session
\donttest{
nav <- navGraph(ng.iris, ng.lg, viz1)
}
}

