\name{ng_2d_myplot}
\alias{ng_2d_myplot}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  Visualization instruction for 2d scatterplots on a user defined display
}
\description{
  Visualization instruction for a \code{navGraph} session that link the
  nodes of a navigation graph to 2d scatterplots and the edges to a 3d
  rigid rotation or a 4d transition.

  \code{navGraph} will call at any bullet state change a function the
  user defines in the global environment.

  The executed function should contain plot instruction and have any
  subset of these arguments

  \tabular{ll}{
    \bold{argument} \tab \bold{description}\cr 
    x \tab x-coordinate \cr
    y \tab y-coordinate \cr
    group \tab group slot from NG_data object\cr
    labels \tab labels slot from NG_data object\cr
    order \tab order of points. In 3d rigid rotation,
    the order increases with the distance
    of a the point from the viewer.\cr
    from \tab node name the bullet moves from\cr
    to \tab node name the bullet moves to\cr
    percentage \tab in between percentage of bullet\cr
    data \tab data name of NG_data object
  }
    
}
\usage{
ng_2d_myplot(data, graph, fnName, device = "base", scaled = TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{data}{ NG_data object.
}
  \item{graph}{ NG_graph object.
}
  \item{fnName}{
    Character sting of the function name defined in the global
    environment \code{.GlobalEnv}. If a function with the name
    \code{fnName.init} also exists, it gets called to initialize the
    plots.
}
  \item{device}{
    One of the following choices: "base", "grid", "ggplot2", "lattice"
    or "rgl".
}
  \item{scaled}{
    Logical. If TRUE, scaled x and y coordinates get passed to the
    function \code{fnName} which lie within the rectangle defined by
    (-1,-1) and (1,1).
}
}
%\details{%%  ~~ If necessary, more details than the description above ~~}
%\value{}
%\references{%% ~put references to the literature/web site here ~}
\author{
  Adrian Waddell and R. Wayne Oldford
}
\note{
  Note that the base graphic device (including \pkg{grid},
  \pkg{ggplot2} and the \pkg{lattice} device) don't have double
  buffering implemented in Linux and OSX but in Windows they
  have. Hence, in Windows you will get smooth plots. But in OSX the
  plots only flush to the screen after a certain idle time from writing
  data to the device. In Linux, the device gets updated after every plot
  command but the user will experience a white flickering from redrawing
  the plot.
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
  \code{\link{navGraph}}, \code{\link{ng_data}}, \code{\link{ng_graph}},
  \code{\link{ng_get-methods}}, \code{\link{ng_set-methods}}, \code{\link{ng_2d}}, \code{\link{ng_2d_ggobi}}
}
\examples{
library(grid)

## NG_data
ng.iris <- ng_data(name = "iris", data = iris[,1:4],
		shortnames = c('s.L', 's.W', 'p.L', 'p.W'),
		group = iris$Species,
		labels = substr(iris$Species,1,2))

## NG_graph
V <- shortnames(ng.iris)
G <- completegraph(V)
LG <- linegraph(G)
LGnot <- complement(LG)
ng.lg <- ng_graph(name = '3D Transition', graph = LG, layout = 'circle')
ng.lgnot <- ng_graph(name = '4D Transition', graph = LGnot, layout = 'circle')

## initialization plot
myPlot.init <- function(x,y,group,labels,order) {
	pushViewport(plotViewport(c(5,4,2,2)))
	pushViewport(dataViewport(c(-1,1),c(-1,1),name="plotRegion"))
	
	grid.points(x,y, name = "dataSymbols")
	grid.rect()
	grid.xaxis()
	grid.yaxis()
	grid.edit("dataSymbols", pch = 19)
	grid.edit("dataSymbols", gp = gpar(col = group))
}

## update plot
myPlot <- function(x,y,group,labels,order) {
  print(order)
	grid.edit("dataSymbols",
           x = unit(x,"native"),
           y = unit(y,"native"))
      }

## Visualization instruction
viz1 <- ng_2d_myplot(ng.iris,ng.lg,fnName = "myPlot",
           device = "grid", scaled=TRUE)

## navGraph session
\donttest{nav <- navGraph(ng.iris,ng.lg, viz1)}
}

