setClass(
		Class = "NG_Viz2D_Ggobi",
		representation = representation(
				GGobiDisp = "OptionalGGobiSPDisp"
		#	g = "OptionalGGobi",
		),
		contains = "NG_Visualization2d"
)


## object creator function
ng_2d_ggobi <- function(data,graph){
		
	require(rggobi) || stop('[ng_2d_ggobi] requires rggobi package!')
	require(RGtk2) || stop('[ng_2d_ggobi] requires RGtk2 package!')
	
	if(is(data,"NG_data") == FALSE){
		stop("[ng_2d_ggobi] data is no NG_data object.\n")
	}
	
	if(is(graph,"NG_graph") == FALSE){
		stop("[ng_2d_ggobi] graph is no NG_graph object.\n")
	}
	
	## When sending data to GGobi, the order of the variables stays consistant
	## with the order of the names.
	varNames <-	vizVarNames(graph,data)

	return( new("NG_Viz2D_Ggobi",
					graph = graph@name,
					data = data@name,
					from = nodes(graph@graph)[1],
					to = "",
					varList = varNames,
					mat = matrix(rep(0,length(varNames)*2),ncol = 2),
					transitionKind = 0)
	)
	
}





## Initialize Plots
setMethod(
		f = "inititializeViz",
		signature = "NG_Viz2D_Ggobi",
		definition = function(viz,ngEnv){
						
			## Start the 2D tour display
			viz@GGobiDisp <- display(ngEnv$g[viz@data])			
			pmode(viz@GGobiDisp) <- "2D Tour"
			
			## press the pause button, copied from faceoff					
			ggobi_gtk_main_window(ngEnv$g) -> ggwindow
			
			ggwindow[[1]] -> child1
			child1[[2]] -> child2
			child2[[1]] -> child3
			child3[[1]] -> child4
			child4[[1]] -> child5
			child4[[2]] -> childtemp
			childtemp[[1]] -> temp
			
			#gtkRangeSetValue(child5, 30)
			gtkToggleButtonSetActive(temp, TRUE)
			
			## initialize rotation matrix			
			viz <- initRotation(viz,ngEnv)
			
				## set rotation
			ggobi_display_set_tour_frame(viz@GGobiDisp,viz@mat)
			
			return(viz)
		}
)




setMethod(
		f = "updateViz",
		signature = "NG_Viz2D_Ggobi",
		definition = function(viz,ngEnv){
			
			viz <- ng_2dRotationMatrix(viz,ngEnv)
			
			## make transition
			ggobi_display_set_tour_frame(viz@GGobiDisp,viz@mat)
			
			return(viz)
			
		})




setMethod(
		f = "closeViz",
		signature = "NG_Viz2D_Ggobi",
		definition = function(viz,ngEnv){
			## close all GGobi displays
			invisible(sapply(displays.GGobi(ngEnv$g),function(x)close.GGobiDisplay(x)))
			
			##viz@GGobiDisp <- NULL
			
			return(viz)
		})


## For RGgobi
ggobi_display_set_tour_frame <- function (gd, value) {
	## ## Check for a correct matrix dimension
	## if(!((dim(value)[1] == dim.GGobiData(dataset.GGobiDisplay(a))[2]) &
	##      dim(value)[2] == 2))
	##   stop("Matrix is not of the same dimension as the ggobi dataset")
	
	## Check if the matrix is normal
	normal <- all(colSums(value^2) - 1 < 0.001)
	if (!normal) 
		stop("Matrix is not normal (colSums do not equal 1)")
	
	.GGobiCall <- getNamespace("rggobi")$.GGobiCall
	invisible(.GGobiCall("setTourProjection", gd, pmode(gd), 
					value))
	##gtkWindowUnstick(ggobi_gtk_main_window()) #should not need this- forces redraw
}
