\name{ng_set<-}
\alias{ng_set<-}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Modify data in a NG_data, NG_graph, NG_path or navgraph handler object.
}
\description{
   Modifies data in some of the in RnavGraph specifically defined classes.
}
\usage{
ng_set(object, what) <- value
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{object}{
	Either a: navgraph handler, NG_data, NG_path, NG_graph object.
}
  \item{what}{
	String of what should be modified within the object.
}
  \item{value}{
	Replacement value.
}
}
\details{
Using ng_set is risky because we don't guarantee that the objects gets updated correctly. We recommend to just re-create the object.
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
\code{\link{navGraph}}, \code{\link{ng_set-methods}}, \code{\link{ng_get}}, \code{\link{ng_get-methods}} , \code{\link{ng_set_color<-}}, \code{\link{ng_get_color}},  \code{\link{ng_set_size<-}}, \code{\link{ng_get_size}}
}
%\examples{}
