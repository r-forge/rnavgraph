\name{ng_get_size}
\alias{ng_get_size}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
	Extract point sizes from an active navGraph session for a particular data set.
}
\description{
	If you use the brush and resisizing tool in navGraph, you can retrieve your point sizes information
	with this function as long the navGraph session is still active.
}
\usage{
ng_get_size(obj, dataName)
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
Nummerical vector with size values for each point.
}
%\references{%% ~put references to the literature/web site here ~}
\author{
Adrian Waddell and Wayne Oldford
}
%\note{%%  ~~further notes~~}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{navGraph}}, \code{\link{ng_set_size<-}}, \code{\link{ng_get_color}}, \code{\link{ng_set_color<-}}
}
\examples{
## Define a NG_data object
ng.iris <- ng_data(name = "IrisData", data = iris[,1:4])

## start a navGraph session
nav <- navGraph(ng.iris)

## get sizes from active navGraph session
sizes <- ng_get_size(nav, "IrisData")

}
