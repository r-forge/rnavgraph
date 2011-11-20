\name{ng_set_color<-}
\alias{ng_set_color<-}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  Change colors of data points in an active navGraph session
}
\description{
   Specify new colors for each point for an active navGraph session.
}
\usage{
ng_set_color(obj, dataName) <- value
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{obj}{
	A navgraph handler of an active navGraph session.
}
  \item{dataName}{
String of the data name. If not specified and only one data set is beeing used in the navGraph session, it will default to this data. Otherwise, if multiple data sets are being used in a navGraph session, the function will list the name of these data sets and ask you to specify one.
}
  \item{value}{
	Replacement vector or single value specifing valid colors.
  }
}
\details{
   
}
\value{

}
%\references{%% ~put references to the literature/web site here ~}
\author{
Adrian Waddell and Wayne Oldford
}
%\note{%%  ~~further notes~~}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{navGraph}}, \code{\link{ng_get_color}}, \code{\link{ng_set_size<-}}, \code{\link{ng_get_size}}
}
\examples{
## Define a NG_data object
ng.iris <- ng_data(name = "IrisData", data = iris[,1:4])

## start a navGraph session
nav <- navGraph(ng.iris)

## set all point to red
ng_set_color(nav, "IrisData") <- 'red'
}
