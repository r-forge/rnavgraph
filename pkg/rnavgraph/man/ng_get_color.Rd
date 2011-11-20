\name{ng_get_color}
\alias{ng_get_color}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
	Extract point coloring from an active navGraph session for a particular data set.
}
\description{
	If you use the brush and coloring tool in navGraph, you can retrieve your coloring information
	with this function as long the navGraph session is still active.
}
\usage{
ng_get_color(obj, dataName)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{obj}{
	A navgraph handler of an active navGraph session.
}
  \item{dataName}{
	String of the data name. If not specified and only one data set is beeing used in the navGraph session, it will default to this data. Otherwise, if multiple data sets are being used in a navGraph session, the function will list the name of these data sets and ask you to specify one.
}
}
%\details{ }
\value{
Vector with color values for each point.
}
%\references{%% ~put references to the literature/web site here ~}
\author{
Adrian Waddell and Wayne Oldford
}
%\note{%%  ~~further notes~~}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{navGraph}}, \code{\link{ng_set_color<-}}, \code{\link{ng_get_size}}, \code{\link{ng_set_size<-}}
}
\examples{
## Define a NG_data object
ng.iris <- ng_data(name = "IrisData", data = iris[,1:4])

## start a navGraph session
nav <- navGraph(ng.iris)

## get colors from active navGraph session
cols <- ng_get_color(nav, "IrisData")

}
