\name{linegraph}
\alias{linegraph}

\title{Linegraph of a graph}

\description{
  (From Wikipedia) The line graph L(G) of an undirected graph G is another graph L(G) that represents the adjacencies between edges of G. By definition, each vertex of L(G) represents an edge of G, and two vertices of L(G) are adjacent if and only if their corresponding edges share a common endpoint ("are adjacent") in G.
}

\usage{
linegraph(graph, sep = ":")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{graph}{ Undirected graph of class \code{graph}.
}
  \item{sep}{
    Separates the node names of G in the node names of the new graph L(G).
}
}
\details{
}
\value{
  graphNEL object.
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
  Adrian Waddell and R. Wayne Oldford
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~
\seealso{
  \code{\link{navGraph}}, \code{\link{completegraph}},
  \code{\link{newgraph}}
}
\examples{
G <- completegraph(LETTERS[1:4])
LG <- linegraph(G, sep = "xx")

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ graphs }

