##
## Classes with Color-, Interaction- & Display-Settings
########################################################
## TODO: Eventually also save tk2d settings here

setClass(
		Class = "ColorSettings",
		representation = representation(
				background = "character",
				bullet = "character",
				bulletActive = "character",
				nodes = "character",
				nodesActive = "character",
				adjNodes = "character",
				adjNodesActive = "character",
				notVisitedEdge = "character",
				visitedEdge = "character",
				edgeActive = "character",
				labels = "character",
				labelsActive = "character",
				adjLabels = "character",
				adjLabelsActive = "character",
				path = "character"
		),
		prototype=list(
				background = "ivory",
				bullet = "yellow2",
				bulletActive = "orange",
				nodes = "purple3",
				nodesActive = "seagreen2",
				adjNodes = "violetred1",
				adjNodesActive = "hotpink",
				notVisitedEdge = "thistle1",
				visitedEdge = "plum",
				edgeActive = "blue",
				labels = "purple3",
				labelsActive = "seagreen2",
				adjLabels = "violetred",
				adjLabelsActive = "hotpink",
				path = "black"
		)
)

setClass(
		Class = "InteractionSettings",
		representation = representation(
				NSteps = "numeric",
				animationTime = "numeric",
				dragSelectRadius = "numeric",
				labelDistRadius = "numeric"
		),
		prototype = list(
				NSteps = 50,
				animationTime = 0.1,
				dragSelectRadius = 15,
				labelDistRadius = 30
		)
)

setClass(
		Class = "DisplaySettings",
		representation = representation(
				bulletRadius = "numeric",
				nodeRadius = "numeric",
				lineWidth = "numeric",
				highlightedLineWidth = "numeric"
		),
		prototype = list(
				bulletRadius = 15,
				nodeRadius = 10,
				lineWidth = 1,
				highlightedLineWidth = 3
		)
)

setClass(
		Class = "Tk2dDisplay",
		representation = representation(
				bg = "character",
				brush_colors = "character",
				brush_color = "character",
				linked = "logical"
		),
		prototype = list(
				bg = "grey16",
				brush_colors = c('darkorchid', 'hotpink', 'firebrick3', 'steelblue', 'olivedrab', 'coral', 'saddlebrown', 'dimgray', 'yellow1'),
				brush_color = "white",
				linked = TRUE
		)
)


setClass(
		Class = "NG_Settings",
		representation = representation(
				color = "ColorSettings",
				interaction = "InteractionSettings",
				display = "DisplaySettings",
				tk2d = "Tk2dDisplay"
		),
		prototype = list(
				color = new('ColorSettings'),
				interaction = new("InteractionSettings"),
				display = new("DisplaySettings"),
				tk2d = new("Tk2dDisplay")
		)
)
