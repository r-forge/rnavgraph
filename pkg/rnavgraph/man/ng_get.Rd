\name{ng_get}
\alias{ng_get}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
	Extract data from a NG_data, NG_graph, NG_path or navgraph handler object.
}
\description{
		Extract data from objects from some of the in RnavGraph specifically defined classes.
}
\usage{
ng_get(obj, what = NULL, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{obj}{
	Either a: navgraph handler, NG_data, NG_path, NG_graph object.
}
  \item{what}{
	String of what should be extracted from the object. You can get a list of possible accessible objects by not specifying the what argument.
}
  \item{\dots}{
	Currently not used.
}
}
%\details{ }
\value{
Object that was requested with what.
}
%\references{%% ~put references to the literature/web site here ~}
\author{
Adrian Waddell and Wayne Oldford
}
%\note{%%  ~~further notes~~}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{navGraph}}, \code{\link{ng_get-methods}}, \code{\link{ng_set}}, \code{\link{ng_set-methods}}
}
\examples{
## Define a NG_data object
ng.iris <- ng_data(name = "iris", data = iris[,1:4])

## start a navGraph session
\donttest{nav <- navGraph(ng.iris)}

## See what you can extract from the navGraph handler
\donttest{ng_get(nav)}

## get group
\donttest{ng_get(ng_get(nav,"data"),"group")}
}

