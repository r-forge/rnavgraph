.onLoad <- function(lib, pkg) {
	
	.Tcl('set ng_windowManager("ngInstance") 0')
	
	## graph display
	tclfile <- file.path(.find.package(package = "RnavGraph"),"tcl", "GraphDisplay.tcl")
	tcl("source", tclfile)
	
	## image resizing function in C 
	.Tcl(paste('load "',system.file("libs",.Platform$r_arch,paste("ImgscaleTea",.Platform$dynlib.ext,sep=''),package="RnavGraph"),'"',sep=''))
	.Tcl(paste('load "',system.file("libs",.Platform$r_arch,paste("DisplaystuffTea",.Platform$dynlib.ext,sep=''),package="RnavGraph"),'"',sep=''))
	
	
	## tk2d display
	tclfile <- file.path(.find.package(package = "RnavGraph"),"tcl", "tkScatterplotV3.tcl")
	tcl("source", tclfile)
	
	## load Img tk extension
	sysname <- Sys.info()[1]
	didLoad <- TRUE
	if(sysname == "Windows") {
		## TODO: Img extension for windows. Alternative R functions?
	} else if (sysname == "Darwin") {
		addTclPath("/System/Library/Tcl")
		didLoad <- tclRequire('Img')
	} else {
		didLoad <- tclRequire('Img')
	}
	
	if(identical(didLoad,FALSE)) {
		warning("Can not load the tk Img extension. Hence you can not use the 'ng_image_files' R function.")	
	}
	
}

.onAttach <- function(lib, pkg) {
	packageStartupMessage("\nRnavGraph Version ",
			utils::packageDescription("RnavGraph", field="Version"),
			'\nPlease read the package vignette. Use vignette("RnavGraph").\n\n')	
}