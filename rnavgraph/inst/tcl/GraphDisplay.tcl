proc adjustEdges {canvas node adj} {
    set nodeCoords [$canvas coords [list node && $node]]
    set x [expr ([lindex $nodeCoords 0] + [lindex $nodeCoords 2])/2 ]
    set y [expr ([lindex $nodeCoords 1] + [lindex $nodeCoords 3])/2 ]
    
    foreach adjNode $adj {
	set adjNodeCoords [$canvas coords [list node && $adjNode]]
	set adjX [expr ([lindex $adjNodeCoords 0] + [lindex $adjNodeCoords 2])/2 ]
	set adjY [expr ([lindex $adjNodeCoords 1] + [lindex $adjNodeCoords 3])/2 ]
	$canvas coords [list edge && $node && $adjNode] $x $y $adjX $adjY 
    }
}

				
## This method is invoked when the current window is
## resized and the items will "scale" without changing their area
proc scaleNoArea {canvas what x0 y0 xf yf} {
    set objectList [$canvas find withtag $what]
    foreach obj $objectList {
	set objCoord [$canvas coords $obj]
	# puts stdout $objCoord
	set x [expr ([lindex $objCoord 0] + [lindex $objCoord 2])/2 ]
	set y [expr ([lindex $objCoord 1] + [lindex $objCoord 3])/2 ]
	set xNew [expr $x0+(($x-$x0)*$xf)]
	set yNew [expr $y0+(($y-$y0)*$yf)]
	$canvas move $obj [expr $xNew-$x] [expr $yNew-$y]
    }
}


				

proc getxyCoord {canvas obj} {
    set objCoord [$canvas coords $obj]
    set xNode [expr ([lindex $objCoord 0] + [lindex $objCoord 2])/2 ]
    set yNode [expr ([lindex $objCoord 1] + [lindex $objCoord 3])/2 ]
    return [list $xNode $yNode]
}


proc minThetaNode {canvas node adj dx dy} {
    set len [expr sqrt([expr pow($dx,2)] + [expr pow($dy,2)])]
    
    set dxnorm [expr $dx/$len]
    set dynorm [expr $dy/$len]
    set node [getxyCoord $canvas [list $node && node]]  
    
    foreach adjNode $adj {
	set adjCoord [getxyCoord $canvas [list $adjNode && node]]
	set dxAdj [expr [lindex $adjCoord 0] - [lindex $node 0]]
	set dyAdj [expr [lindex $adjCoord 1] - [lindex $node 1]]
	
	set lenAdj [expr sqrt([expr pow($dxAdj,2)]+[expr pow($dyAdj,2)])]
	set dxAdjNorm [expr $dxAdj/$lenAdj] 
	set dyAdjNorm [expr $dyAdj/$lenAdj] 
	
	set cosPhi [expr ($dxnorm * $dxAdjNorm)+($dynorm*$dyAdjNorm)]
	lappend myList [expr acos($cosPhi)]
    }
    return $myList
}

proc scaleNodes {canvas ratio} {
    set ids [$canvas find withtag node]
    
    foreach id $ids {
	set xy [getxyCoord $canvas $id]
	$canvas scale $id [lindex $xy 0] [lindex $xy 1] $ratio $ratio
    }
}

proc scaleObj {canvas ratio tag} {
    set ids [$canvas find withtag $tag]
    
    foreach id $ids {
	set xy [getxyCoord $canvas $id]
	$canvas scale $id [lindex $xy 0] [lindex $xy 1] $ratio $ratio
    }
    update idletasks
}



proc getNodeNames {canvas} {
    set ids [$canvas find withtag node]
    foreach id $ids {
	set nodeName [lindex [$canvas gettags $id] 2]
	lappend nodeNames $nodeName
	set xy [getxyCoord $canvas $id]
	lappend xNodes [lindex $xy 0]
	lappend yNodes [lindex $xy 1]								
	set xy [$canvas coords [list label && $nodeName]]
	lappend xLabels [lindex $xy 0]
	lappend yLabels [lindex $xy 1]
    }
    return [concat $nodeNames $xNodes $yNodes $xLabels $yLabels]
}


proc getEdgeFromToList {canvas} {
    set ids [$canvas find withtag edge]
    if {[llength $ids] > 0} {
	foreach id $ids {
	    lappend fromList [lindex [$canvas gettags $id] 2]              
	    lappend toList [lindex [$canvas gettags $id] 3]                
	    lappend visited [lsearch -exact [$canvas gettags $id] visited] 
	}
	return [concat $fromList $toList $visited]
    }
    return {}
}

proc moveImg {c img x y} {
    foreach image $img x_coord $x y_coord $y {
	$c coords $image $x_coord $y_coord
    }
    update idletasks
}
				
