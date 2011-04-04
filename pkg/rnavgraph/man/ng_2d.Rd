\name{ng_2d}
\alias{ng_2d}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  Visualization instruction for 2d scatterplots on a tk2d display
}
\description{
  Visualization instruction for a \code{navGraph} session that link the
  nodes of a navigation graph to 2d scatterplots and the edges to a 3d
  rigid rotation or a 4d transition.

  The scatterplots will be displayed on a tk2d display, provided by the
  \pkg{RnavGraph} package. tk2d allows the user to display dots, glyphs,
  text and images at given x-y positions. Further interactivity such as
  selection, zooming, brushing, changing colors and changing sizes are
  provided by the tk2d display. tk2d displays can also link data between
  different \code{navGraph} sessions.
}
\usage{
ng_2d(data, graph, images = NULL, glyphs = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{data}{ NG_data object.
}
  \item{graph}{ NG_graph object.
}
  \item{images}{
    NG_image object. Order of the images must match the order of the
  data in the NG_data object. 
}
  \item{glyphs}{
    Vector of character strings matching either the \code{names} or
  \code{shortnames} of the NG_data object. 
  }
}
\details{
  The text labels in the tk2d display are taken from the labels slot in the
  NG_data object.  

  It the group slot of the NG_data object contains only colors from the
  \code{colors} function, objects get colored accordingly. Otherwise the
  group data gets mapped to some color key.
}
\value{
  NG_Viztk2d object that inherits from the NG_Visualization class.
}
%\references{%% ~put references to the literature/web site here ~}
\author{
Adrian Waddell and R. Wayne Oldford
}
%\note{%%  ~~further notes~~}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
  \code{\link{navGraph}}, \code{\link{ng_data}}, \code{\link{ng_graph}},
  \code{\link{ng_image_array_gray}}, \code{\link{ng_image_files}},
  \code{\link{ng_get-methods}}, \code{\link{ng_set-methods}}, \code{\link{ng_2d_ggobi}}, \code{\link{ng_2d_myplot}}
}
\examples{
## NG_data
ng.iris <- ng_data(name = "iris", data = iris[,1:4],
		shortnames = c('s.L', 's.W', 'p.L', 'p.W'),
		group = iris$Species,
		labels = substr(iris$Species,1,2))

## NG_graph
G <- completegraph(shortnames(ng.iris))
LG <- linegraph(G, sep = "++")
ng.lg <- ng_graph("3d transition", LG, "++", "fruchtermanReingold" )

## NG_image
## see the image demos: demo(package = "RnavGraph")

## Visualization instruction
viz1 <- ng_2d(ng.iris, ng.lg, glyphs = c("s.L","s.W","p.L","p.W"))
viz1
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ dynamic }
