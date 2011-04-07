require(RnavGraph) || stop("RnavGraph library not available")
require(RnavGraphImageData) || stop('You need the RnavGraphImageData package installed!')
require(RDRToolbox)|| stop('You need the RDRToolbox package installed!')

local({
			data(frey)
			
			## LLE
			d_low <- LLE(t(frey),dim=5,k=12)
			
			## Images
			## sample a few
			sel <- sample(1:dim(frey)[2],600, replace = FALSE)
			ng.frey <- ng_image_array_gray('Brendan_Frey',frey[,sel],28,20, img_in_row = FALSE, rotate = 90)
			ng.frey
			
			
			
			ng.lle.frey <- ng_data(name = "ISO_frey",
					data = data.frame(d_low[sel,]),
					shortnames = mapply(function(x){paste("i",x,sep="")},1:5))
			
			nav <- scagNav(ng.lle.frey,c("Clumpy","Outlying","Skewed","Monotonic", "Striated"),
					images=ng.frey)
			
		})

cat(paste("\n\nThe source code of this demo file is located at:\n",system.file("demo", "ng_2d_images_frey.R", package="RnavGraph"),"\n\n\n"))
