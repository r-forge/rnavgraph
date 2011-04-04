\name{scagEdgeWeights}
\alias{scagEdgeWeights}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  Create a from-to edge matrix with the scagnostic weights
}
\description{Create a from-to edge matrix with the scagnostic weights.}
\usage{
scagEdgeWeights(data,
				scags = c("Clumpy", "NotClumpy", "Monotonic", "NotMonotonic",
						  "Convex", "NotConvex", "Stringy", "NotStringy",
						  "Skinny", "NotSkinny", "Outlying","NotOutlying",
						  "Sparse", "NotSparse", "Striated", "NotStriated",
						  "Skewed", "NotSkewed"),
			    combineFn = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{data}{
    object to calculate scagnostics on: NG_data, a vector, a matrix or a
    data.frame.
  }
  \item{scags}{
    Single element or a subset of (with possible a "Not" preceding): \cr
      "Outlying", "Skewed", "Clumpy", "Sparse", "Striated",\cr
      "Convex", "Skinny", "Stringy", "Monotonic"
}
\item{combineFn}{
  Must be a function that takes in a vector of length \code{scags} and
  returns a single value. This return value comprises the new weights
  of the nodes get selected from.
}
}
%\details{%%  ~~ If necessary, more details than the description above ~~}
\value{
  a named list with \code{fromToEdgeMatrix} being a matrix and
  \code{nodeNames} being a vector.
}
%\references{%% ~put references to the literature/web site here ~}
\author{
  Adrian Waddell and R. Wayne Oldford
}
%\note{%%  ~~further notes~~}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
  \code{\link{navGraph}}, \code{\link{scagNav}}, \code{\link{scagGraph}}
}
\examples{
data(olive)
ng.olive <- ng_data(name = "Olive",
		data = olive[,-c(1,2)],
		shortnames = c("p1","p2","s","ol","l1","l2","a","e"),
		group = as.numeric(olive$Area)+1
)

edgeWts <- scagEdgeWeights(data = ng.olive,
		scags = c("Clumpy", "Skinny"),
		combineFn = max)
edgeWts$fromToEdgeMatrix[1:3,]


edgeWts <- scagEdgeWeights(data = ng.olive,
		scags = c("Clumpy", "Skinny"),
		combineFn = function(x){
			2*x[1]+3*x[2]
		})
edgeWts$fromToEdgeMatrix[1:3,]
}

