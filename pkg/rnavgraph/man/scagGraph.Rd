\name{scagGraph}
\alias{scagGraph}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  Create a list of graphs, given the scagnostics edge weights
}
\description{
  \code{scagGraph} is useful to turn the output of
  \code{\link{scagEdgeWeights}} into a list of graphs.
}
\usage{
scagGraph(edgeWeights, topFrac = 0.2)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{edgeWeights}{
    List returned by the \code{\link{scagEdgeWeights}} function.
}
  \item{topFrac}{
    Keep the nodes with the \code{topFrac} fraction of the scagnostic
    weights.
}
}
%\details{%%  ~~ If necessary, more details than the description above ~~}
\value{
  graph object or a list of graph objects.
}
%\references{%% ~put references to the literature/web site here ~}
\author{
  Adrian Waddell and R. Wayne Oldford
}
%\note{%%  ~~further notes~~}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
  \code{\link{navGraph}}, \code{\link{scagNav}}, \code{\link{scagEdgeWeights}}
}
\examples{
data(olive)
ng.olive <- ng_data(name = "Olive",
		data = olive[,-c(1,2)],
		shortnames = c("p1","p2","s","ol","l1","l2","a","e"),
		group = as.numeric(olive$Area)+1
)

edgeWts <- scagEdgeWeights(data = ng.olive,
		scags = c("Clumpy", "Skinny"))
G1 <- scagGraph(edgeWts, topFrac = 0.2)

edgeWts <- scagEdgeWeights(data = ng.olive,
		scags = c("Clumpy", "Skinny"),
		combineFn = max)
G2 <- scagGraph(edgeWts, topFrac = 0.1)

## Now you can start a navGraph session
\donttest{nav <- navGraph(ng.olive, G1)}

\donttest{nav <- navGraph(ng.olive, G2)}
}


