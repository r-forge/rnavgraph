\name{shortnames}
\alias{shortnames}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
 	Returns the shortnames of a NG_data object.
}
\description{
	Shortnames are useful to reduce the node names of navigation graphs. The node names of navigation graphs are either linked with the names or the shortnames of the NG_data object.
}
\usage{
shortnames(x)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
	NG_data object.
}
}
%\details{}
\value{
	Vector of strings.
}
%\references{%% ~put references to the literature/web site here ~}
\author{
Adrian Waddell and Wayne Oldford
}
%\note{%%  ~~further notes~~}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{navGraph}}, \code{\link{ng_data}}
}
\examples{
## Define a NG_data object
ng.iris <- ng_data(name = "iris", data = iris[,1:4])

## Display shortnames
shortnames(ng.iris) ## no shortnames defined yet

## Modify the shortnames
shortnames(ng.iris) <- c("sL","sW","pL","pW")

## Display updated shortnames
shortnames(ng.iris) ## no shortnames defined yet

}
