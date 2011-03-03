\name{ng_graph}
\alias{ng_graph}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  Create an NG_data object to be used by a navGraph session
}
\description{
    NG_graph objects wrap the transition graphs and additional
    information such as graph name and graph layout.

    The node names of the graph split by the chosen \code{sep} character
    sting must match either the variable names- or the short names of
    the NG_data object.
}
\usage{
ng_graph(name, graph, sep = ":", layout = "circle")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{name}{
    Name of graph. This name will be displayed in the pull down menu
    within a navGraph session.
}
  \item{graph}{
    Undirected graph objects of class \code{graph}. See the package \pkg{graph}.
  }
  \item{sep}{
    Node names represent a set of variables whose name are separated by
    the character string \code{sep} (containing no spaces).
}
  \item{layout}{
    One of the following strings: "circle", "kamadaKawaiSpring",
    "fruchtermanReingold" or "random".
}
}
\details{
  The number of \code{sep} occurrences in each node name of the graph must be
    the same.
%%  ~~ If necessary, more details than the description above ~~
}
\value{
  NG_graph object.
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
  \code{\link{navGraph}}, \code{\link{newgraph}}, \link{completegraph},
  \code{\link{linegraph}}, \code{\link{complement}},
  \code{\link{ng_get-methods}}, \code{\link{ng_set-methods}}
}
\examples{
G <- completegraph(LETTERS[1:4])
LG <- linegraph(G, sep = "++")

ng.lg <- ng_graph("3d transition", LG, "++", "fruchtermanReingold" )
plot(ng.lg)

## If you have the Rgraphviz package working, plot graph object of class graph
\dontrun{library(Rgraphviz)}
\dontrun{plot(LG)}


}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ graphs }
