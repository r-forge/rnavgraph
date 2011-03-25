## navGraph internal class for objects containing path information
setClass(
		Class = "NG_path",
		representation = representation(
				path = "character",
				info = "character",
				graphName = "character"
		),
		validity = function(object){		
			if(length(object@path) == length(object@info)){# && length(object@info) == length(object@graph)){
				return(TRUE)
			}else{
				return(FALSE)
			}
		})

setMethod(f = "[",
		signature = "NG_path",
		definition = function(x,i,j,drop){
			if(all(length(i)==1, j %in% c("path","info","comment","graph","all"))){
				if( j == "all"){ ## delete element
					return(new("NG_path", path = x@path[i], info = x@info[i], graphName = x@graphName[i]))					
				}else if(all(i > 0,any(match(j, c("path","info","graph","comment"))))){
					if(j == "path"){
						return(unlist(strsplit(x@path[i],' ')))
					}else if(j %in% c("info","comment")){
						return(x@info[i])
					}else if(j == "graph"){
						return(x@graphName[i])
					}
					
				}else{
					stop("[NG_path:'[' ]: wrong indices i and j")					
				}		
			}
			
		}
)

setMethod(f = "show",
		signature = "NG_path",
		definition = function(object){
			
			if(length(object@path) != 0) {
				
				cat("NG_path object\n")
				for(i in 1:length(object@path)) {
					cat(paste("Path",i,"-----------------\n"))
					cat(paste("Graph:",object@graphName[i],"\n"))
					cat(paste("Path:",object@path[i],"\n"))
					cat(paste("Comment:",object@info[i],"\n"))
				}
			}else {
				cat("NG_path object is empty.\n")
			}
		}
)




.parsePath <- function(path){
	return(gsub('\\s+',' ',sub("\\s*\n*$","",sub("^\\s+","",path))))
}

.parsePath2Vec <- function(path){
	return(unlist(strsplit(.parsePath(path), split = " ")))
}



## TODO: pathGui has a few bugs documented in the vignette
## TODO: make buttons visually more pleasing
.pathGUI <- function(ngEnv) {
	
	if(!is.null(ngEnv$windowManager$paths)) {
		## bring window to front
		tkraise(ngEnv$windowManager$paths$tt)
	}else {
		boldfont <- tkfont.create(weight="bold")
		
		##GUI
		tt <- tktoplevel(, borderwidth = 5)  ## main tk window
		tktitle(tt) <- tktitle(tt) <- paste("Session ", ngEnv$ng_instance,", RnavGraph Paths", sep = '')
		ngEnv$windowManager$paths$tt <- tt
		
		
		tkbind(tt, '<Destroy>', function(){
					ngEnv$ngEnv$windowManager$paths <- NULL
				})
		
		f.active <- tkframe(tt)#, bg = 'blue')
		f.updown <- tkframe(tt)#, bg = 'red')
		f.paths <- tkframe(tt)#, bg = 'green')
		f.comments <- tkframe(tt)#, bg = 'orange')
		tkpack(f.active, f.updown, side = "top", fill = "x")
		
		tkpack(f.paths, side = "top", fill = "both", expand = TRUE)
		tkpack(f.comments, side = "top", fill = "x")
		
		## active Path
		f.active_t <- tkframe(f.active)#, bg = 'lightblue')
		f.active_b <- tkframe(f.active)#, bg = 'lightblue')
		tkpack(f.active_t, f.active_b, side = "top", fill = "x", anchor = "nw")
		
		tkpack(tklabel(f.active_t, text = "Active Path:"), side = "left", anchor = "w")
		entry.activePath <- tkentry(f.active_b, bg = "white", relief = "sunken", textvariable = ngEnv$activePath)
		tkpack(entry.activePath, side="left", expand = TRUE, fill = "x", anchor="w")
		
		## controls
		b.view <- tkbutton(f.active_b, text = "V")
		b.play <- tkbutton(f.active_b, text = "W")
		b.record <- tkbutton(f.active_b, text = "R")
		tkpack(b.record, b.play, b.view,tkframe(f.active_b, width = 10), side = "right", anchor = "e")
		
		## up down
		b.up <- tkbutton(f.updown, text = "up")
		b.down <- tkbutton(f.updown, text = "down")
		tkpack(tkframe(f.updown,width = 5),b.up,b.down, side = "left", anchor = "w", padx = 5)
		
		## Saved Paths
		f.paths_t <- tkframe(f.paths)
		f.paths_b <- tkframe(f.paths)
		tkpack(f.paths_t, side = "top", fill = "both")
		tkpack(f.paths_b, side = "top", fill = "both", expand = TRUE)
		f.paths_b_l <- tkframe(f.paths_b)
		f.paths_b_r <- tkframe(f.paths_b)
		tkpack(f.paths_b_l, side = "left", fill = "both", expand = TRUE)
		tkpack(f.paths_b_r, side = "left", fill = "y")
		
		tkpack(tklabel(f.paths_t, text = "Saved Paths:"), side = "left", anchor = "w", fill = "x")
		scr <- tkscrollbar(f.paths_b_r, repeatinterval=5, command=function(...){tkyview(tl,...);tkyview(tl2,...)})
		tl<-tklistbox(f.paths_b_l,height=12, selectmode="single", yscrollcommand=function(...)tkset(scr,...), background="white", exportselection=0)
		tl2<-tklistbox(f.paths_b_r,height=12, width = 20, selectmode="single", yscrollcommand=function(...)tkset(scr,...), background="white", exportselection=0)
		tkpack(tl, side="left", fill = "both", expand = TRUE)
		tkpack(scr, side="left", fill= "y")
		tkpack(tl2, side="left", fill="y")
		
		
		## comments
		
		f.comments_t <- tkframe(f.comments)
		f.comments_b <- tkframe(f.comments)
		tkpack(f.comments_t, f.comments_b, side = "top", fill = "x")
		
		tkpack(tklabel(f.comments_t, text = "Comments on the selected path"), side = "left", anchor = "w")
		
		b.saveComment <- tkbutton(f.comments_t, text = "save comment")
		tkpack(b.saveComment, side = "right", anchor = "e")
		
		
		scr1 <- tkscrollbar(f.comments_b, repeatinterval=5, command=function(...)tkyview(txt,...))
		txt <- tktext(f.comments_b,bg="white",font="courier",yscrollcommand=function(...)tkset(scr1,...), width=30, height = 12, wrap="word")
		tkpack(txt, side="left", fill = "x", expand = TRUE)
		tkpack(scr1, side="left",fill="y")
		
		
		## Functionality
		.pathAdd <- function(path, graphName, info = ""){
			## parse path delete unneeded spaces
			path <- .parsePath(path)
			## does Path already exist?
			if(length(ngEnv$paths@path)>0) {
				sel1 <- path == ngEnv$paths@path
				sel2 <- graphName == ngEnv$paths@graphName
				sel3 <- sel1 & sel2
			} else {
				sel3 <- FALSE
			}
			
			if(sum(sel3) == 0) { ## graph is new
				ngEnv$paths <- new("NG_path", path = c(ngEnv$paths@path,path),
						graphName = c(ngEnv$paths@graphName,graphName),
						info = c(ngEnv$paths@info,info))
				num <- length(ngEnv$paths@path)
				.updatePaths(num+1)
			} else {
				.updatePaths(which(sel3)[1])
			}
		}
		
		
		.pathDel <- function(){
			sel <- as.numeric(tkcurselection(tl))+1
			if(length(sel)!=0){
				cat("pathDel: ")
				print(sel)
				ngEnv$paths <- ngEnv$paths[-sel,"all"]
				.updatePaths(sel)
			}
		}
		
		
		.pathToActive <- function(){
			sel <- as.numeric(tkcurselection(tl))+1
			cat("pathToActive: ")
			print(sel)
			
			tclvalue(ngEnv$activePath) <- ngEnv$paths@path[sel]
			.updatePaths(sel)
		}
		
		.saveComment <- function(){
			sel <- as.numeric(tclvalue(tkcurselection(tl)))+1
			ngEnv$paths@info[sel] <- tclvalue(tkget(txt,"0.0","end"))
		}
		
		.updatePaths <- function(j){
			cat(paste(".updatePaths:",j,'\n'))
			
			tkdelete(tl,0,"end")
			tkdelete(tl2,0,"end")
			sapply(ngEnv$paths@path,function(path)tkinsert(tl,"end",paste(path,collapse = " ")))		
			sapply(ngEnv$paths@graphName,function(graph)tkinsert(tl2,"end",paste(graph,collapse = " ")))
			tkdelete(txt, '0.0', 'end')
			
			if(is.na(j) || j == 0 || length(ngEnv$paths@path) == 0){
				j <- 0
			}else{
				npaths <- length(ngEnv$paths@path)
				j <- min(max(j,1),npaths)
				## add background
				if(ngEnv$paths@graphName[j] == ngEnv$graph@name){
					tkconfigure(tl2,selectbackground = "green")
				}else{
					tkconfigure(tl2,selectbackground = "red")
				}		
			}
			tkinsert(txt, "end", ngEnv$paths@info[j])
			tkselection.set(tl,j-1)
			tkselection.set(tl2,j-1)
		}
		
		
		## Functionality with GUI
		tkconfigure(b.down, command = function().pathAdd(tclvalue(ngEnv$activePath),tclvalue(ngEnv$activePathGraph)))		
		tkconfigure(b.up, command = function().pathToActive())	
		tkconfigure(b.saveComment, command = function().saveComment())	
		
		
		tkbind(tl, "<Button-1>",function(W,y){sel <- as.numeric(tclvalue(tcl(W,"nearest",y)))+1;.updatePaths(sel)})
		tkbind(tl2, "<Button-1>",function(W,y){sel <- as.numeric(tclvalue(tcl(W,"nearest",y)))+1;.updatePaths(sel)})
		
		tkbind(tl, "<Key-Delete>",function(){.pathDel()})
		tkbind(tl, "<Key-BackSpace>",function(){.pathDel()})
		tkbind(tl2, "<Key-Delete>",function(){.pathDel()})
		tkbind(tl2, "<Key-BackSpace>",function(){.pathDel()})
		
		tkbind(entry.activePath, "<Button-1>", function(){
					if(tclvalue(ngEnv$activePath) %in% ngEnv$paths@path){ ## a new path
						.updatePaths(0)
					}else{
						.updatePaths(sel)
					}
				})
		
		tkconfigure(b.view, command = function().showPath(ngEnv, tclvalue(ngEnv$activePath)))
		tkconfigure(b.play, command = function().walkPath(ngEnv, tclvalue(ngEnv$activePath)))
		
		
	}
	
}





## carfule what argument the function takes (vector or string?)
.isPath <- function(graph,path){
	
	t.nodes <- nodeNr(graph,nodeSeq)
	
	edgeM <- matrix(tail(head(rep(t.nodes,each=2), n=-1L), n=-1L),ncol=2, byrow = 2)	
	
	l.p <- apply(edgeM,1, FUN = function(x){any(x[2] == adjacent(graph,x[1],'node',retNr=TRUE))})
	
	
	if(any(is.na(l.p))){
		tkmessageBox(message = "at least one node does not exist")
		stop("your path is not correct.\n")
	}else{
		if(all(l.p)){
			return(TRUE)
		}else{
			tkmessageBox(message = "path does not exist")
			stop("path does not exist.\n")
		}
	}
}


## path is a string or vector
.isPathOnCanvas <- function(ngEnv, path) {
	
	if(length(path) == 1) {
		nodes <- .parsePath2Vec(path)
	}else {
		nodes <- path
	}
	n <- length(nodes)
	edgeMatrix <- cbind(nodes[1:(n-1)],nodes[2:n])
	edgeExists <- apply(edgeMatrix,1, FUN = function(row){
				length(.tcl2str(tcl(ngEnv$canvas,'find','withtag',paste('edge && ',row[1],' && ', row[2]))))
			})
	if(0 %in% edgeExists){
		tkmessageBox(message = "path does not exist")
		stop("path does not exist.\n")
	}else{
		return(TRUE)
	}
}

## path is a string 
.walkPath <- function(ngEnv, path) {
	if(path != "") {
		.isPathOnCanvas(ngEnv, path)

		if(length(path) == 1) {
			nodes <- .parsePath2Vec(path)
		}else {
			nodes <- path
		}
		
		n <- length(nodes)
		#browser()

		
		## first color the total path
		for(i in 1:(n-1)) {
			tkitemconfigure(ngEnv$canvas, paste('edge && ', nodes[i], ' && ', nodes[i+1]),
					fill = ngEnv$settings@color@path)
		}
		
		## jump to first node
		ngEnv$bulletState$from <- nodes[1]
		ngEnv$bulletState$percentage <- 0 
		.updatePlots(ngEnv)
		.arriveAtNode(ngEnv)
		xynode <- .tcl2xy(tkcoords(ngEnv$canvas,paste('node && ',nodes[1])))
		xybullet <- .tcl2xy(tkcoords(ngEnv$canvas,'bullet'))
		dxy <- xynode-xybullet
		tkmove(ngEnv$canvas, 'bullet',dxy[1],dxy[2])
		
		print(nodes)
		for(i in 2:n) {
#			ngEnv$bulletState$from <- nodes[i]
			ngEnv$bulletState$to <- nodes[i]
			ngEnv$bulletState$percentage <- 0
	
			tkitemconfigure(ngEnv$canvas, 'edge', width = ngEnv$settings@display@lineWidth)
			
			tkitemconfigure(ngEnv$canvas, paste('edge && ', nodes[i-1], ' && ', nodes[i]),
					fill = ngEnv$settings@color@path,
					width = ngEnv$settings@display@highlightedLineWidth)
			
			
			.walkEdge(ngEnv, path = !(i == n))
		}		
	}
}


.showPath <- function(ngEnv,path) {
	.isPathOnCanvas(ngEnv, path)
	if(length(path) == 1) {
		nodes <- .parsePath2Vec(path)
	}else {
		nodes <- path
	}
	n <- length(nodes)
	edgeMatrix <- cbind(nodes[1:(n-1)],nodes[2:n])
	
	
	for(i in 1:nrow(edgeMatrix)) {
		tkitemconfigure(ngEnv$canvas, 'edge', width = ngEnv$settings@display@lineWidth)
		tkitemconfigure(ngEnv$canvas, paste('edge && ', edgeMatrix[i,1], ' && ', edgeMatrix[i,2]),
				fill = ngEnv$settings@color@path,
				width = ngEnv$settings@display@highlightedLineWidth)
		tcl('update','idletasks')
		Sys.sleep(0.6)
	}
}












setMethod(f = "ng_get",
		signature = "NG_path",
		definition = function(obj, what=NULL, ...){
			possibleOptions <- c("path","graph","comment")
			
			if(is.null(what)){
				cat("Get what? Possible options are: ")
				cat(paste(possibleOptions, collapse = ", "))
				cat("\n")
			}else{
				if(any(is.na(match(what,possibleOptions)))){
					stop(paste("[ng_get] object",what,"is not defined."))
				}
				
				if(what == "path"){
					return(obj@path)
				}else if(what == "graph"){
					return(obj@graph)
				}else if(what == "comment"){
					return(obj@info)
				}
			}
		})

