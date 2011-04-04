\name{newgraph}
\alias{newgraph}

\title{
  Create a graph object of class graph
}
\description{
  Create a graph object of class graphNEL or graphAM. You might also use
  the graph creating facility provided by the \pkg{graph} package.
}
\usage{
newgraph(nodeNames, mat, weights = NULL, directed = FALSE, isAdjacency = FALSE,...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{nodeNames}{
     Numeric or character string vector.
}
  \item{mat}{
    Either an adjacency matrix or a from to matrix.
}
  \item{weights}{
    Numeric weights for edges. Either in the same order as the from to
  matrix or as a square matrix, depending what one have chosen for the
  \code{mat} argument.
}
  \item{directed}{
    Logical value for defining a directed or undirected graph.
}
  \item{isAdjacency}{
    If argument mat is adjacency matrix.
}
}
%\details{%%  ~~ If necessary, more details than the description above ~~}
\value{
  graphNEL or grapAM object.
}
%\references{%% ~put references to the literature/web site here ~}
\author{
Adrian Waddell and R. Wayne Oldford
}
%\note{%%  ~~further notes~~}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{navGraph}}, \code{\link{completegraph}}, \code{\link{linegraph}}
}
\examples{
## Using from to matrices
from <- c("A","A","C","C")
to   <- c("B","C","B","D")
ftEmat <- cbind(from,to)

## note how the E node is added
G <- newgraph(nodeNames = LETTERS[1:5], mat = ftEmat)

## say you would like to add weights to the graph
weights <- c(2,1,3,4)
G <- newgraph(nodeNames = LETTERS[1:5], mat = ftEmat, weights = weights)

## newgraph with adjacency matrix
V <- c('s.L', 's.W', 'p.L', 'p.W')
adjM <- matrix(c(0,1,1,0,1,0,1,1,1,1,0,0,0,1,0,0), ncol = 4)
all(adjM == t(adjM)) ## is symmetric (undirected)
G <- newgraph(nodeNames = V, mat= adjM, isAdjacency=TRUE)

## if you use adjacency matrices, you can add a matrix with weights
adjM <-     matrix(c(0,0,1,0,1,0,1,1,0,0,0,0,0,1,0,0), ncol = 4)
weightsM <- matrix(c(0,0,5,0,2,0,1,3,0,0,0,0,0,7,0,0), ncol = 4)
G <- newgraph(nodeNames = V, mat= adjM, weights = weightsM, directed = TRUE, isAdjacency=TRUE)
edgeData(G, attr = "weight")
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ graphs }
