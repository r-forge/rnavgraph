\name{ng_set}
\alias{ng_set}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
	Shows which data can be modified in a NG_data, NG_graph, NG_path or navgraph handler object.
}
\description{
	Show what can be changed in objects from some of the in RnavGraph specifically defined classes.
}
\usage{
ng_set(object)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{object}{
	Either a: navgraph handler, NG_data, NG_path, NG_graph object.
}
}
%\details{%%  ~~ If necessary, more details than the description above ~~}
\value{
No return value. Only a string gets printed onto the comand prompt of all possible data that can be modified within the object.
}
%\references{%% ~put references to the literature/web site here ~}
\author{
Adrian Waddell and Wayne Oldford
}
\note{
	Using ng_set is risky because we don't guarantee that the objects gets updated correctly. We recommend to just re-create the object.
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{navGraph}}, \code{\link{ng_set-methods}}, \code{\link{ng_get}}, \code{\link{ng_get-methods}}, \code{\link{ng_set_color<-}}, \code{\link{ng_get_color}},  \code{\link{ng_set_size<-}}, \code{\link{ng_get_size}}
}
%\examples{}
