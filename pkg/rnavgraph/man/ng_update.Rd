\name{ng_update}
\alias{ng_update}

\title{
  Synchronize a navGraph handler with a running navGraph sesson
}
\description{
  The navGraph handler can be used to interact with a running navGraph
  session via the R prompt.
  
  For the tk2d and ggobi display one can change color and size of the
  data points (in ggobi also the shapes). You can retrieve this
  information by updating the navGraph handler and reading the group
  attribute of the data object back. See the examples.
}
\usage{
ng_update(nghandler)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{nghandler}{
    navGraph handler of a running navGraph session.
  }
}
%\details{%%  ~~ If necessary, more details than the description above ~~}
\value{
  updated navGraph handler.
}
%\references{%% ~put references to the literature/web site here ~}
\author{
  Adrian Waddell and R. Wayne Oldford
}
%\note{%%  ~~further notes~~}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
  \code{\link{navGraph}}, \code{\link{ng_walk}}, \code{\link{ng_get-methods}}
}

\examples{
## Define a NG_data object
ng.iris <- ng_data(name = "iris", data = iris[,1:4])

## start a navGraph session
\donttest{nav <- navGraph(ng.iris)}

## modify colors of points

## update navGraph handler
\donttest{nav <- ng_update(nav)}
\donttest{nav # show method}

## get information form navGraph handler
\donttest{ng_get(nav)}

## get group attribute back
\donttest{ng_get(ng_get(nav,"data"),"group")}
}
