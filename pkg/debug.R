#library(RnavGraph)

A <- function(){
  rm(list = ls(), envir = .GlobalEnv)
  library(RnavGraph)
  library(PairViz)
  
  data(olive) ## saved in RnavGraph package
  
  d.olive <<- data.frame(olive[,-c(1,2)])
  ng.olive <<- ng_data(name = "Olive",
                      data = d.olive,
                      shortnames = c("p1","p2","s","oleic","l1","l2","a","e"),
                      group = as.numeric(olive[,"Area"]),
                      labels = as.character(olive[,"Area"])
                      )
 

  G <<- completegraph(shortnames(ng.olive))
  LG <<- linegraph(G)
  ng.lg <<- ng_graph("3d olive",LG, layout = 'kamadaKawaiSpring')
  ng.lgnot <<- ng_graph("4d olive",complement(LG), layout = 'kamadaKawaiSpring')
  

  
  nav <<- navGraph(ng.olive,
                  list(ng.lg,ng.lgnot),
                  list(ng_2d(ng.olive,ng.lg,glyphs = eulerian(as(G,"graphNEL"))),ng_2d(ng.olive,ng.lgnot)))
  
  nav1 <<- navGraph(ng.olive,
                   list(ng.lg,ng.lgnot),
                   list(ng_2d(ng.olive,ng.lg,glyphs = eulerian(as(G,"graphNEL"))),ng_2d(ng.olive,ng.lgnot)))
  
}

B <- function() {
  library(RnavGraph)
  library(grid)

ng.iris <- ng_data(name = "iris", data = iris[,1:4],
		shortnames = c('s.L', 's.W', 'p.L', 'p.W'),
		group = iris$Species,
		labels = substr(iris$Species,1,2))

V <- shortnames(ng.iris)
G <- completegraph(V)
LG <- linegraph(G)
LGnot <- complement(LG)
ng.lg <- ng_graph(name = '3D Transition', graph = LG, layout = 'circle')
ng.lgnot <- ng_graph(name = '4D Transition', graph = LGnot, layout = 'circle')

  
myPlot.init <<- function(x,y,group,labels,order) {

	pushViewport(plotViewport(c(5,4,2,2)))
	pushViewport(dataViewport(c(-1,1),c(-1,1),name="plotRegion"))
	
	grid.points(x,y, name = "dataSymbols")
	grid.rect()
	grid.xaxis()
	grid.yaxis()
	grid.edit("dataSymbols", pch = 19)
	grid.edit("dataSymbols", gp = gpar(col = group))
}

myPlot <<- function(x,y,group,labels,order) {
  print(order)
	grid.edit("dataSymbols", x = unit(x,"native"), y = unit(y,"native"))
      }

viz1 <- ng_2d_myplot(ng.iris,ng.lg,fnName = "myPlot" , device = "grid",scaled=TRUE)

nav <<- navGraph(ng.iris,ng.lg, viz1)
 
}


C <- function(){
  library(RnavGraph)

  V <-  c('s.L', 's.W', 'p.L', 'p.W')
 
  G <- completegraph(V)
  LG <- linegraph(G, sep = '++')
  
  
  ng.LG <- ng_graph(name = "3D Transition", graph = LG, sep = '++', layout = "circle")
ng.LG  

LGnot <- complement(LG)
ng.LGnot <- ng_graph(name = "4D Transition", graph = LGnot, sep = "++", layout = "circle")

## plotting of NG_graph objects
par(mfrow = c(1,2))
plot(ng.LG)
plot(ng.LGnot)

}



D <- function(){
  library(RnavGraph)

  data(olive)
ng.olive <- ng_data(name = "Olive",
		data = olive[,-c(1,2)],
		shortnames = c("p1","p2","s","ol","l1","l2","a","e"),
		group = as.numeric(olive$Area)+1
)

edgeWts <- scagEdgeWeights(data = ng.olive,
		scags = c("Clumpy", "Skinny"))
G1 <<- scagGraph(edgeWts, topFrac = 0.2)

  nav1 <<- navGraph(ng.olive,G1)
  
edgeWts <- scagEdgeWeights(data = ng.olive,
		scags = c("Clumpy", "Skinny"),
		combineFn = max)
G2 <<- scagGraph(edgeWts, topFrac = 0.1)

    nav2 <<- navGraph(ng.olive,G2)

}

E  <- function(){
  library(RnavGraph)
  demo("ng_2d_images_faces")
}

F <- function(){
  library(RnavGraph)
  demo("ng_2d_images_frey")
}
