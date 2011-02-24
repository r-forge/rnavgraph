## Author: Adrian Waddell
## Date Sep 9, 2010

#package require Tk
#load ./imgscale[info sharedlibextension]




## Initialize stuff
set ng_mouse_x 0

set ng_mouse_y 0
set ng_shift_L 0
set ng_ctrl_L 0

set ng_windowManager("zbox_width") [expr {1.125*160}] 
set ng_windowManager("zbox_height") [expr {1.125*90}]




## Initializes new toplevel window with plot and bindings
##
## ttID:        Toplevel ID of window R assigns to tcl
##
## ngInstance:  How often was navGraph called in R
##              This is important to tell the display
##              to which data it should access
##
## dataName:    Unique name of data, so meta data for each point
##              can be accessed
##
## 

proc tk_2d_display {ttID ngInstance ngLinkedInstance dataName viz withImages withGlyphs {title "tk2d display"}} {
    global ng_windowManager
    global ng_data

    ## Window can only be destroyed by navGraph
    wm protocol $ttID WM_DELETE_WINDOW {
	tk_messageBox -message "Only RnavGraph can destroy this window!"
    }


    ## Create Canvas and Sidebar
    wm title $ttID $title
    set nav [frame $ttID\.nav]
    pack $nav -side right -anchor n -fill y
    #pack propagate $ttID\.nav 0
    
    
    
    
    
    
    set canvas_2d [canvas $ttID\.canvas\
		       -bg $ng_data("$ngLinkedInstance\.$dataName\.bg")\
		       -width 600\
		       -height 450]
    pack $canvas_2d -side left -fill both -expand 1
    set ng_windowManager("$ngInstance\.$viz\.width") 600
    set ng_windowManager("$ngInstance\.$viz\.height") 450
    
    
    
    
    ## for zooming
    set ng_windowManager("$ngInstance\.$viz\.zoom_center_x") 0
    set ng_windowManager("$ngInstance\.$viz\.zoom_center_y") 0
    set ng_windowManager("$ngInstance\.$viz\.zoom_factor") 1
    
    
    
    ## save id
    lappend ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") $ttID
    
    
    
    ## attach ngInstance and dataName to window
    label $ttID\.dataName -text $dataName
    label $ttID\.ngInstance -text $ngInstance
    label $ttID\.ngLinkedInstance -text $ngLinkedInstance
    label $ttID\.viz -text $viz
    
    
    ## Create Navigation frames
    pack [frame $nav\.axis]\
	[frame  $nav\.zoom]\
	[frame  $nav\.plotType]\
	[frame  $nav\.tools]\
	-side top -fill x -padx 5 -pady 2.5 -anchor w
    

    ## Plot type radio buttons
    pack [label $nav\.plotType.label -text "Plot Type:"] -side top -anchor w
    set ng_windowManager("$ngInstance\.$viz.plotType") "shapes"
    radiobutton $nav\.plotType.rshape -text dots\
	-variable ng_windowManager("$ngInstance\.$viz.plotType")\
	-value shapes\
	-command "switch_plot_type shapes $ttID $ngInstance $ngLinkedInstance $dataName $viz"
    pack $nav\.plotType.rshape -side top -anchor w -expand true
    if {$withImages} {
	radiobutton $nav\.plotType.rimg -text images\
	    -variable ng_windowManager("$ngInstance\.$viz.plotType")\
	    -value images\
	    -command "switch_plot_type images $ttID $ngInstance $ngLinkedInstance $dataName $viz"
	pack $nav\.plotType.rimg -side top -anchor w
    }
    if {$withGlyphs} {
	radiobutton $nav\.plotType.rglyphs -text glyphs\
	    -variable ng_windowManager("$ngInstance\.$viz.plotType")\
	    -value glyphs\
	    -command "switch_plot_type glyphs $ttID $ngInstance $ngLinkedInstance $dataName $viz"
	pack $nav\.plotType.rglyphs -side top -anchor w
    }
    if {[llength $ng_data("$ngLinkedInstance\.$dataName\.text")] > 0} {
	radiobutton $nav\.plotType.rtext -text text\
	    -variable ng_windowManager("$ngInstance\.$viz.plotType")\
	    -value text\
	    -command "switch_plot_type text $ttID $ngInstance $ngLinkedInstance $dataName $viz"
	pack $nav\.plotType.rtext -side top -anchor w
    }

    
    ## Zoom Box
    pack [frame $nav\.zoom.flabel] [frame $nav\.zoom.fcanvas]\
	-side top -fill x
    pack [label  $nav\.zoom.flabel.l -text "Zoom:"]\
	[label  $nav\.zoom.flabel.lz -text 1] -side left
    
    set canvas_zoom [canvas $nav\.zoom.fcanvas.canvas -bg gray\
			 -width $ng_windowManager("zbox_width")\
			 -height $ng_windowManager("zbox_height")]
    pack $canvas_zoom -side top -anchor c
    
    

    ## Tools
    ##
    set ftools "$nav\.tools"
    
    ## Brush
    set ng_windowManager("$ngInstance\.$viz\.brush") off
    ## CARE: set ng_data("$ngLinkedInstance\.$viz\.brush.data_i") ""
    
    pack [frame $ftools\.brush] -fill x -side top -pady 2
    label $ftools\.brush.l -text "Brush:"
    set cb_brush\
	[checkbutton $ftools\.brush.cb\
	     -variable ng_windowManager("$ngInstance\.$viz\.brush")\
	     -onvalue on -offvalue off]
    pack $ftools\.brush.l $cb_brush -side left 


    ## used also later
    set bw [expr {$ng_windowManager("zbox_width")/9}]  
    
    pack [frame $ftools\.brush.sp -width 5] -side right
    pack [canvas $ftools\.brush.c -width [expr {$bw-8}] -height [expr {$bw-8}] -bg $ng_data("$ngLinkedInstance\.$dataName\.brush_color")] -side right

    pack [label $ftools\.brush.cl -text "color: "] -side right

    ## change brush color
    bind $ftools\.brush.c <Double-ButtonRelease-1> {

	set col [%W cget -bg]
	set new_col [tk_chooseColor -initialcolor $col]
	
	if {$new_col ne ""} {
	    set ttID [winfo toplevel %W]
	    set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
	    set dataName [$ttID\.dataName cget -text]
	    set viz [$ttID\.viz cget -text]

	    set ::ng_data("$ngLinkedInstance\.$dataName\.brush_color") $new_col

	    foreach tt $::ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
		set ngInstance [$tt\.ngInstance cget -text]
		$tt\.nav\.tools\.brush\.c configure -bg $new_col
		update_displays $tt $ngInstance $dataName $viz
	    }

	 
	}
    }




    ## Selection
    pack [frame $ftools\.selection] -side top -fill x -pady 2

    label $ftools\.selection.l -text "Selection:"
    set sel_none [label $ftools\.selection.lnone\
		      -text " none " -activebackground "darkgrey"] 
    set sel_all [label $ftools\.selection.lall\
		     -text " all " -activebackground "darkgrey"] 
    set sel_inv [label $ftools\.selection.linvert\
		     -text " invert " -activebackground "darkgrey"] 
    
    pack $ftools\.selection.l $sel_none $sel_all $sel_inv -side left
    
    foreach widget [list $sel_none $sel_all $sel_inv] { 
	bind $widget "<Any-Enter>" {
	    %W configure -state active
    }
	bind $widget "<Any-Leave>" {
	    %W configure -state normal
	}
    }

    # Color see variable bw a few lines above
    set canvas_col [canvas $ftools\.can -width $ng_windowManager("zbox_width")\
			-height [expr {2*$bw}]]
    
    pack $canvas_col -side top -pady 2
    set x 0; set y 1
    
        
    foreach col $ng_data("$ngLinkedInstance\.$dataName\.brush_colors")\
	id [list 0 1 2 3 4 5 6 7 8] {
	$canvas_col create rect [expr $x*$bw] [expr $y*$bw]\
	    [expr ($x+1)*$bw] [expr ($y+1)*$bw] -width 0\
	    -tag [list brush color rect $id]
	$canvas_col create rect [expr $x*$bw+4] [expr $y*$bw+4]\
	    [expr ($x+1)*$bw-4] [expr ($y+1)*$bw-4] -fill $col\
	    -width 0 -tag [list brush color dot $id]
	incr x
	if {$x == 9} {
	    set x 0
	    incr y
	}
	
    }
    
    $canvas_col create text 2 [expr {$bw/2}] -text "color:" -anchor w
    
    $canvas_col create text [expr {180-$bw}] [expr {$bw/2}]\
	-text "bg:" -anchor e
    $canvas_col create rect [expr {8*$bw+4}] [expr 4]\
	[expr {9*$bw-4}] [expr {$bw-4}]\
	-fill $ng_data("$ngLinkedInstance\.$dataName\.bg")\
	-width 0 -tag [list brush color dot bg]
    
    
    $canvas_col bind "color && !bg" <ButtonPress-1> {

	set widget [lindex [%W itemcget current -tag] 3]

	set ttID [winfo toplevel %W]
	set ngLinekdInstance [$ttID\.ngLinkedInstance cget -text]
	set dataName [$ttID\.dataName cget -text]

	## select same or new color
	if {[$ttID\.nav\.tools\.can itemcget "$widget && rect" -fill] eq "darkgray"} {
	    foreach tt $::ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
		$tt\.nav\.tools\.can itemconfigure rect -fill ""
	    } 
	} else {
	    foreach tt $::ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
		$tt\.nav\.tools\.can itemconfigure rect -fill ""
		$tt\.nav\.tools\.can itemconfigure "$widget && rect"\
		    -fill darkgray
	    }
	}
    }
    
    $canvas_col bind "color && !bg" <Double-ButtonRelease-1> {
	set widget [lindex [%W itemcget current -tag] 3]
	set col [%W itemcget "$widget && dot" -fill]
	set new_col [tk_chooseColor -initialcolor $col]

	if {$new_col ne ""} {
	    set ttID [winfo toplevel %W]
	    set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
	    set dataName [$ttID\.dataName cget -text]
	    
	    foreach tt $::ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
		$tt\.nav\.tools\.can itemconfigure "$widget && dot"\
		    -fill $new_col
	    }
	    
	    ## save new in brush list
	    puts stdout "widget $widget and col $new_col"
	    lset ::ng_data("$ngLinkedInstance\.$dataName\.brush_colors") $widget $new_col

	    
	}
    }
    

    ## Change Background Color
    $canvas_col bind "color && bg" <Double-ButtonRelease-1> {

	set col [%W itemcget "bg && dot" -fill]
	set new_col [tk_chooseColor -initialcolor $col]
	
	
	if {$new_col ne ""} {
	    set ttID [winfo toplevel %W]
	    set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
	    set dataName [$ttID\.dataName cget -text]

	    set ::ng_data("$ngLinkedInstance\.$dataName\.bg") $new_col
	    foreach tt $::ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
		$tt\.canvas configure -bg $new_col
		$tt\.nav.zoom.fcanvas.canvas itemconfigure "zbox" -fill $new_col
		$tt\.nav\.tools\.can itemconfigure "bg && dot"\
		    -fill $new_col
	    }
	}
    }
    

    
   
    ## Size
    pack [frame $ftools\.scale] -side top -fill x -pady 2

    label $ftools\.scale.l -text "size:" 
    label $ftools\.scale.labs -text "abs:" 
    label $ftools\.scale.lrel -text "rel:" 
    set sp_rel [label $ftools\.scale.lp -text " + " -bg grey -activebackground darkgray]
    set sm_rel [label $ftools\.scale.lm -text " - " -bg grey -activebackground darkgray]
    set sp_abs [label $ftools\.scale.lpabs -text " + " -bg grey -activebackground darkgray]
    set sm_abs [label $ftools\.scale.lmabs -text " - " -bg grey -activebackground darkgray]
    
 
    foreach widget [list $sm_rel $sp_rel $sm_abs $sp_abs] { 
	bind $widget "<Any-Enter>" {
	    %W configure -state active
	}
	bind $widget "<Any-Leave>" {
	    %W configure -state normal
	}
    }
    
    pack $ftools\.scale.l -side left
    pack $ftools\.scale.labs -side left -padx 2
    pack $sm_abs $sp_abs -side left -padx 1
    pack $ftools\.scale.lrel -side left -padx 2
    pack $sm_rel $sp_rel -side left -padx 1
    
    
    
    pack [ttk::frame $nav\.statusbar] -side bottom -fill x
    pack [ttk::sizegrip $nav\.statusbar.grip] -side right -anchor se
    

    

    ## #############################
    ## Bindings
    ## #############################


    # resize points
    bind $sm_rel <Button-1> {
    	set ttID [winfo toplevel %W]
	change_size $ttID 0 "-1"
    }
    
    bind $sp_rel <Button-1> {
	set ttID [winfo toplevel %W]
	change_size $ttID 0 "1"
    }
    
    # resize points
    bind $sm_abs <Button-1> {
    	set ttID [winfo toplevel %W]
	change_size $ttID 1 "-1"
    }
    
    bind $sp_abs <Button-1> {
	set ttID [winfo toplevel %W]
	change_size $ttID 1 "1"
    }
    


    #button press in main
    bind $canvas_2d <Button-1> {
	#puts stdout "Button Click"
	set ::ng_mouse_x %x
	set ::ng_mouse_y %y

	## if brush is on, the brush square should folow the mouse
	set ttID [winfo toplevel %W]
	set ngInstance [$ttID\.ngInstance cget -text]
	set viz [$ttID\.viz cget -text]
	if {$::ng_windowManager("$ngInstance\.$viz\.brush") eq "on"} {
	    set brush_xy [$ttID\.canvas coords "brush && area"]
	    set dx [expr {%x-[lindex $brush_xy 2]}]
	    set dy [expr {%y-[lindex $brush_xy 3]}]
	    brush $ttID $dx $dy
	}
    }

    bind $ttID <KeyPress-Shift_L> {
	#puts stdout "Shift down"
	set ::ng_shift_L 1

	set ttID [winfo toplevel %W]
        set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
	## if brush is on select point below it
	set dataName [$ttID\.dataName cget -text]

	foreach tt $::ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
	    set viz [$tt\.viz cget -text]
            set ngInstance [$tt\.ngInstance cget -text]
	    if {$::ng_windowManager("$ngInstance\.$viz\.brush") eq "on"} {
		brush $tt 0 0
	    }
	}
    }    
    bind $ttID <KeyRelease-Shift_L> {
	#puts stdout "Shift release"
	set ::ng_shift_L 0
    }
    bind $ttID <KeyPress-Control_L> {
	#puts stdout "Ctrl down"
	set ::ng_ctrl_L 1
    }    
    bind $ttID <KeyRelease-Control_L> {
	#puts stdout "Ctrl release"
	set ::ng_ctrl_L 0
    }


    

    # select Bindings
    $canvas_2d bind data <Shift-Button-1> {
	set ttID [winfo toplevel %W]
	## TODO maybe a %... will do?
	set id [$ttID\.canvas find withtag current]
	modify_2d $ttID select $id
    }

    ## reset button
    bind $sel_none <Button-1> {
    	global ng_data
    	set ttID [winfo toplevel %W]
	set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
    	set dataName [$ttID\.dataName cget -text]
	
	set n [llength $ng_data("$ngLinkedInstance\.$dataName\.selected")]
	set ng_data("$ngLinkedInstance\.$dataName\.selected") [lrepeat $n 0]

	foreach tt $::ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
		set ngInstance [$tt\.ngInstance cget -text]	    
		set tviz [$tt\.viz cget -text]
	    update_displays $tt $ngInstance $dataName $tviz
	}


	
    }

    ## Highlight all
    bind $sel_all <Button-1> {
    	global ng_data
    	set ttID [winfo toplevel %W]
	set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
    	set dataName [$ttID\.dataName cget -text]
	
	
	set n [llength $ng_data("$ngLinkedInstance\.$dataName\.selected")]
	set ng_data("$ngLinkedInstance\.$dataName\.selected") [lrepeat $n 1]

	foreach tt $::ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
	    set tviz [$tt\.viz cget -text]
	    set ngInstance [$tt\.ngInstance cget -text]
	    update_displays $tt $ngInstance $dataName $tviz
	}
    }
    
    
    ## inversion button
    bind $sel_inv <Button-1> {
    	global ng_data
    	set ttID [winfo toplevel %W]
    	set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
    	set dataName [$ttID\.dataName cget -text]



	set i 0
	foreach sel $ng_data("$ngLinkedInstance\.$dataName\.selected") {
	    if {$sel} {
		lset ng_data("$ngLinkedInstance\.$dataName\.selected") $i 0
	    } else {
		lset ng_data("$ngLinkedInstance\.$dataName\.selected") $i 1
	    }
	    incr i
	}
	

	foreach tt $::ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
	    set tviz [$tt\.viz cget -text]
	    set ngInstance [$tt\.ngInstance cget -text]
	    update_displays $tt $ngInstance $dataName $tviz
	}


    }
    
    
    
    
    
    

    ## brush on button
    bind $cb_brush <ButtonPress-1> {
    	set ttID [winfo toplevel %W]
    	set viz [$ttID\.viz cget -text]
    	set ngInstance [$ttID\.ngInstance cget -text]
    
#	puts stdout "Toggle Brush $ngInstance"

    	if {$::ng_windowManager("$ngInstance\.$viz\.brush") eq on} {
    	    #puts stdout "turn off"
    	    $ttID\.canvas delete brush
    	} else {
    	    #puts stdout "turn on"
    	    $ttID\.canvas create rect 10 10 70 70 -outline grey85 -width 2\
    		-tag [list brush area]
    	    $ttID\.canvas create rect 67 67 73 73 -fill grey\
    		-tag [list brush corner]
    	}
    }
    
    bind $cb_brush <ButtonRelease-1> {
    	set ttID [winfo toplevel %W]
    	set ngInstance [$ttID\.ngInstance cget -text]
	set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
    	set dataName [$ttID\.dataName cget -text]
	
    	brush_highlight $ttID $ngInstance $ngLinkedInstance $dataName false
    }
    

    ## Move and resize brush    
    bind $canvas_2d <B1-Motion> {
#	puts stdout all
	set dx [expr {%x - $::ng_mouse_x}]
	set dy [expr {%y - $::ng_mouse_y}]
		
	set ttID [winfo toplevel %W]
	set ngInstance [$ttID\.ngInstance cget -text]
	set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
	set dataName [$ttID\.dataName cget -text]
	set viz [$ttID\.viz cget -text]
	## if brush is over

	## if brush is on move brush
	if {$::ng_windowManager("$ngInstance\.$viz\.brush") eq "on"} {
	    brush $ttID $dx $dy
	} else {
	    if {!$::ng_shift_L} {
	    set path "$ngInstance\.$viz\."
	    ## otherwise move zoom area if zoom > 1
	    if {$::ng_windowManager("$path\zoom_factor")>1} {		
		set ddx [expr {double($dx)/$::ng_windowManager("$path\cwidth")\
				   /sqrt($::ng_windowManager("$path\zoom_factor"))\
				   *2.0}]
		set ddy [expr {double($dy)/$::ng_windowManager("$path\cheight")\
				   /sqrt($::ng_windowManager("$path\zoom_factor"))\
				   *2.0}]
		
		set ::ng_windowManager("$path\zoom_center_x")\
		    [expr {$::ng_windowManager("$path\zoom_center_x")-$ddx}]
		set ::ng_windowManager("$ngInstance\.$viz\.zoom_center_y")\
		    [expr {$::ng_windowManager("$path\zoom_center_y")-$ddy}]
		
		## HERE
		update_zoomfactor $ttID $path\
		    $::ng_windowManager("$path\zoom_factor")\
		    $::ng_windowManager("$path\zoom_center_x")\
		    $::ng_windowManager("$path\zoom_center_y")
		
		
		display_data $ttID $ngInstance $ngLinkedInstance $dataName $viz
		display_zoombox $ttID $ngInstance $ngLinkedInstance $dataName $viz
		brush $ttID 0 0
		update idletasks
	    }
	    }
	}
	
	set ::ng_mouse_x %x
	set ::ng_mouse_y %y
    }
    
    ## resize brush
    $canvas_2d bind "brush && corner" <B1-Motion> {
#	puts stdout A
	set dx [expr {%x - $::ng_mouse_x}]
	set dy [expr {%y - $::ng_mouse_y}]
	
	set ttID [winfo toplevel %W ]
	set brush_xy [$ttID\.canvas coords "brush && area"]

	## constrain resizing
	if {[lindex $brush_xy 0] > [lindex $brush_xy 2] + $dx} {
	    set dx [expr [lindex $brush_xy 0] - [lindex $brush_xy 2]]
	}
	if {[lindex $brush_xy 1] > [lindex $brush_xy 3] + $dy} {
	    set dy [expr [lindex $brush_xy 1] - [lindex $brush_xy 3]]
	}	

	$ttID\.canvas coords "brush && area"\
	    [lindex $brush_xy 0] [lindex $brush_xy 1]\
	    [expr {[lindex $brush_xy 2] + $dx}]\
	    [expr {[lindex $brush_xy 3] + $dy}]
	
	$ttID\.canvas move "brush && corner" $dx $dy
	
#	set brush_xy [$ttID\.canvas coords brush]
#	set sel [$ttID\.canvas find overlapping\
#		     [lindex $brush_xy 0] [lindex $brush_xy 1]\
#		     [lindex $brush_xy 2] [lindex $brush_xy 3]]
	
#	brush_highlight $ttID $ngInstance $ngLinkedInstance $dataName false
	
	set ::ng_mouse_x %x
	set ::ng_mouse_y %y
    }
    

   
    ## resize window
    set ng_windowManager("$ngInstance\.$viz\.isConfigured") 0
    bind $ttID <Configure> {
	set ttID [winfo toplevel %W]
	set viz [$ttID\.viz cget -text]
	set ngInstance [$ttID\.ngInstance cget -text]
	set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
	
	set w [winfo width $ttID]
	set h [winfo height $ttID]
	
#	puts stdout configure

	if {!(($::ng_windowManager("$ngInstance\.$viz\.width") == $w) &&\
		 ($::ng_windowManager("$ngInstance\.$viz\.height") == $h))} { 
	    

	    if {[info exists ::_(after)]} { 
		foreach e $::_(after) {
		    after cancel $e
		    #puts stdout "After Cancelled: $e"
		}
		unset ::_(after)
	    }
	    
	    ## delete brush from window
	    if {$ng_windowManager("$ngInstance\.$viz\.brush") eq on} {
		set ng_windowManager("$ngInstance\.$viz\.brush") off
		$ttID\.canvas delete brush
		brush_highlight $ttID $ngInstance $ngLinkedInstance $dataName false
	    }


	    $ttID\.canvas delete data
	    $ttID\.canvas delete resize
	    
	    set can_w [winfo width $ttID\.canvas]
	    set can_h [winfo height $ttID\.canvas]

	    $ttID\.canvas create text [expr {$can_w/2}] [expr {$can_h/2}]\
		-text "$can_w x $can_h" -fill grey85\
		-font {-size 24 -weight bold}\
		-tag resize
	    update idletasks
	    set ::ng_windowManager("$ngInstance\.$viz\.isConfigured") 1

	    set ::ng_windowManager("$ngInstance\.$viz\.width") $w
	    set ::ng_windowManager("$ngInstance\.$viz\.height") $h
	    set ::ng_windowManager("$ngInstance\.$viz\.cwidth") $can_w
	    set ::ng_windowManager("$ngInstance\.$viz\.cheight") $can_h



	    lappend ::_(after) [after 500 {
		if {$::ng_windowManager("$ngInstance\.$viz\.isConfigured")} {
		    #puts stdout "After Executed"
		    set dataName [$ttID\.dataName cget -text]
		    $ttID\.canvas delete resize
		    display_data $ttID $ngInstance $ngLinkedInstance $dataName $viz
		    display_zoombox $ttID $ngInstance $ngLinkedInstance $dataName $viz
		    set ::ng_windowManager("$ngInstance\.$viz\.isConfigured") 0
		    brush_highlight $ttID $ngInstance $ngLinkedInstance $dataName false
		    update idletasks
		}
	    }]
	    #puts stdout "After Started: $::_(after)"	    
	    
	
	}
    }
    
#    bind $ttID <FocusIn> {
#	set ttID [winfo toplevel %W]
#	set ngInstance [$ttID\.ngInstance cget -text]
#	set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
#	set viz [$ttID\.viz cget -text]
#	if {$::ng_windowManager("$ngInstance\.$viz\.isConfigured")} {
#	    set dataName [$ttID\.dataName cget -text]
#	    $ttID\.canvas delete resize
#	    display_data $ttID $ngInstance $ngLinkedInstance $dataName $viz
#	    display_zoombox $ttID $ngInstance $ngLinkedInstance $dataName $viz
#	    set ::ng_windowManager("$ngInstance\.$viz\.isConfigured") 0
#	    brush_highlight $ttID $ngInstance $ngLinkedInstance $dataName false
#	    update idletasks
#	}
#    }

    
    ## Zooming with scroll wheel in main window


    if {[regexp -nocase Windows $::tcl_platform(os)]} {
	# zoom windows
	bind $canvas_2d <MouseWheel> {
	    if {%D > 0} {
		zoom_main [winfo toplevel %W] %x %y +1
	    } else {
		zoom_main [winfo toplevel %W] %x %y -1
	    }
	}
	## add interactivity to zoom box    
	bind $canvas_zoom <MouseWheel> {
	    if {%D > 0} {
		zoom_world [winfo toplevel %W] +1
	    } else {
		zoom_world [winfo toplevel %W] -1
	    }
	}
    } else {
	## zoom in (linux, OSX)
	bind $canvas_2d <Button-4> {
	    zoom_main [winfo toplevel %W] %x %y +1
	}
	## zoom out (linux, OSX)
	bind $canvas_2d <Button-5> {
	    zoom_main [winfo toplevel %W] %x %y -1
	}
	
	## add interactivity to zoom box
	## zoom in in zoom box
	bind $canvas_zoom <Button-4> {
	    zoom_world [winfo toplevel %W] +1
	}
	## zoom out in zoom box
	bind $canvas_zoom <Button-5> {
	    zoom_world [winfo toplevel %W] -1
	}
    }

    
    ## move viewing region in zoom box
    bind $canvas_zoom <Button-1> {
	set ::ng_mouse_x %x
	set ::ng_mouse_y %y
    }
    
    bind $canvas_zoom <B1-Motion> {
#	puts stdout all
	set dx [expr {%x - $::ng_mouse_x}]
	set dy [expr {%y - $::ng_mouse_y}]
	
	set ttID [winfo toplevel %W]
	set ngInstance [$ttID\.ngInstance cget -text]
	set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
	set viz [$ttID\.viz cget -text]
	
	## if brush is on move brush
	set path "$ngInstance\.$viz\."
	## otherwise move zoom area if zoom > 1
	if {$::ng_windowManager("$path\zoom_factor")>1} {		
	    set ddx [expr {2.0*double($dx)/$::ng_windowManager("$ngInstance\.$viz\.zbox_area_width")}]
	    set ddy [expr {2.0*double($dy)/$::ng_windowManager("$ngInstance\.$viz\.zbox_area_height")}]
	    
	    set ::ng_windowManager("$path\zoom_center_x")\
		[expr {$::ng_windowManager("$path\zoom_center_x")+$ddx}]
	    set ::ng_windowManager("$ngInstance\.$viz\.zoom_center_y")\
		[expr {$::ng_windowManager("$path\zoom_center_y")+$ddy}]
	    
	    ## HERE
	    update_zoomfactor $ttID $path\
		$::ng_windowManager("$path\zoom_factor")\
		$::ng_windowManager("$path\zoom_center_x")\
		$::ng_windowManager("$path\zoom_center_y")
	    
	    
	    display_data $ttID $ngInstance $ngLinkedInstance $dataName $viz
	    display_zoombox $ttID $ngInstance $ngLinkedInstance $dataName $viz
	    brush $ttID 0 0
	    update idletasks
	    
	}
	set ::ng_mouse_x %x
	set ::ng_mouse_y %y
    }

    

    
    ##
    
    update idletasks
    set ng_windowManager("$ngInstance\.$viz\.cwidth") [winfo width $canvas_2d]
    set ng_windowManager("$ngInstance\.$viz\.cheight") [winfo height $canvas_2d]
    
    ## initialize everything
    display_data $ttID $ngInstance $ngLinkedInstance $dataName $viz
    display_zoombox $ttID $ngInstance $ngLinkedInstance $dataName $viz
    brush_highlight $ttID $ngInstance $ngLinkedInstance $dataName 0    

}


## zoom main canvas
proc zoom_main {ttID x y direction} {
    set ngInstance [$ttID\.ngInstance cget -text]
    set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
    set viz [$ttID\.viz cget -text]
    set dataName [$ttID\.dataName cget -text]
    

    set dir [expr {pow(1.1,$direction)}]
    set path "$ngInstance\.$viz\."
    ## some complicated formula...
    set sorig [expr {2/sqrt($::ng_windowManager("$path\zoom_factor"))}]
    set snew [expr {2/sqrt($::ng_windowManager("$path\zoom_factor")*$dir)}]
    update_zoomfactor $ttID $path\
	[expr {$::ng_windowManager("$path\zoom_factor")*$dir}]\
	[expr {$::ng_windowManager("$path\zoom_center_x")+\
		   (0.5-double($x)/$::ng_windowManager("$path\cwidth"))*\
		   ($snew-$sorig)}]\
	[expr {$::ng_windowManager("$path\zoom_center_y")+\
		   (0.5-double($y)/$::ng_windowManager("$path\cheight"))*\
		   ($snew-$sorig)}]
    ## refresh display 
    display_data $ttID $ngInstance $ngLinkedInstance $dataName $viz
    display_zoombox $ttID $ngInstance $ngLinkedInstance $dataName $viz
    brush $ttID 0 0
    update idletasks
}

## zoom world display
proc zoom_world {ttID direction} {
    set ngInstance [$ttID\.ngInstance cget -text]
    set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
    set viz [$ttID\.viz cget -text]
    set dataName [$ttID\.dataName cget -text]
    
    set path "$ngInstance\.$viz\."
    
    ## same center
    update_zoomfactor $ttID $path\
	[expr {$::ng_windowManager("$path\zoom_factor")*pow(1.1,$direction)}] \
	$::ng_windowManager("$path\zoom_center_x") \
	$::ng_windowManager("$path\zoom_center_y")
    ## refresh display 
    display_data $ttID $ngInstance $ngLinkedInstance $dataName $viz
    display_zoombox $ttID $ngInstance $ngLinkedInstance $dataName $viz
    brush $ttID 0 0
    update idletasks
}














## select a new plot type
proc switch_plot_type {what ttID ngInstance ngLinkedInstance dataName viz} {
    
    switch -exact $what {
	shapes {
	    display_shapes $ttID $ngInstance $ngLinkedInstance $dataName $viz	
	}
	text {
	    display_text $ttID $ngInstance $ngLinkedInstance $dataName $viz	
	}
	glyphs {
	    display_glyphs $ttID $ngInstance $ngLinkedInstance $dataName $viz
	}
	images {
	    display_images $ttID $ngInstance $ngLinkedInstance $dataName $viz
	}
	
	
    }
    
    brush_highlight $ttID $ngInstance $ngLinkedInstance $dataName true

    
}


## update the zoomfactor
proc update_zoomfactor {ttID path factor center_x center_y} {
    global ng_windowManager
    
    if {$factor > 1} {
	if {$center_x < -1} {	
	    set $center_x -1 
	} elseif {$center_x > 1} {
	    set $center_x 1
	}
	if {$center_y < -1} {	
	    set $center_y -1 
	} elseif {$center_y > 1} {
	    set $center_y 1
	}
	

	set ifactor2 [expr {1/sqrt($factor)}]
	if {[expr {$center_x - $ifactor2}] < -1} {
	    ## move region to the right
	    set ng_windowManager("$path\zoom_center_x")\
		[expr {-1+ $ifactor2}]
	    #puts stdout "Move right: [expr {$center_x - $ifactor2}] < -1"
	} elseif {[expr {$center_x + $ifactor2}] > 1} {
	    ## move region to the left
	    set ng_windowManager("$path\zoom_center_x")\
		[expr {1 - $ifactor2}]
	    #puts stdout "Move left: [expr {$center_x + $ifactor2}] > 1"
	} else {
	    set ng_windowManager("$path\zoom_center_x") $center_x
	}

	if {[expr {$center_y - $ifactor2}] < -1} {
	    ## move region up
	    set ng_windowManager("$path\zoom_center_y")\
		[expr {-1+ $ifactor2}]
	    #puts stdout "Move up: [expr {$center_y - $ifactor2}] < -1"
	} elseif {[expr {$center_y + $ifactor2}] > 1} {
	    ## move region down
	    set ng_windowManager("$path\zoom_center_y")\
		[expr {1 - $ifactor2}]
	    #puts stdout "Move down: [expr {$center_y + $ifactor2}] > 1"
	} else {
	    set ng_windowManager("$path\zoom_center_y") $center_y
	}
    } else {
	set ng_windowManager("$path\zoom_center_x") 0
	set ng_windowManager("$path\zoom_center_y") 0
    }
    set ng_windowManager("$path\zoom_factor") $factor
    $ttID\.nav.zoom.flabel.lz configure -text [format "%1.4f" $factor]

}





## brushing
proc brush {ttID dx dy} {
    #set ttID [winfo toplevel $widget]
    set dataName [$ttID\.dataName cget -text]
    set ngInstance [$ttID\.ngInstance cget -text]
    set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
    set viz [$ttID\.viz cget -text]

    ## TODO constrain Brush?
    
    
    ## Move Brush
    $ttID\.canvas move brush $dx $dy
    
    ## higlight point
    if {$::ng_shift_L == 1} {
	## Select point under brush
	if {$::ng_windowManager("$ngInstance\.$viz\.brush") eq "on"} {
	    set brush_xy [$ttID\.canvas coords brush]
	    if {$brush_xy eq ""} {
		$ttID\.nav.tools.brush.cb toggle
		$ttID\.canvas delete brush
	    } else {
		set sel [$ttID\.canvas find overlapping\
			     [lindex $brush_xy 0] [lindex $brush_xy 1]\
			     [lindex $brush_xy 2] [lindex $brush_xy 3]]
		
		modify_2d $ttID permanentbrush [lrange $sel 0 end-2]
	    }
	}
    } else {
	brush_highlight $ttID $ngInstance $ngLinkedInstance $dataName false
    }
}


## only temporary brushing 
proc brush_highlight {ttID ngInstance ngLinkedInstance dataName freshPlot} {
    global ng_windowManager
    global ng_data


    set total_sel {}    
    foreach tt $ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
	set viz [$tt\.viz cget -text]
	set ngInstance [$tt\.ngInstance cget -text]
	## check if brush is on
	if {$ng_windowManager("$ngInstance\.$viz\.brush") eq "on"} {
	    

	    set brush_xy [$tt\.canvas coords brush]
	    
#	    set tmp $ng_windowManager("$ngInstance\.$viz\.brush")
#	    puts stdout "Instance $ngInstance : Switch $tmp"
#	    puts stdout "BRUSH XY COORD: $brush_xy"
	    
	    if {$brush_xy eq ""} {
		$tt\.nav.tools.brush.cb toggle
		$tt\.canvas delete brush
	    } else {
		
		set sel [$tt\.canvas find overlapping\
			     [lindex $brush_xy 0] [lindex $brush_xy 1]\
			     [lindex $brush_xy 2] [lindex $brush_xy 3]]
		# check if previously brushed
		foreach id $sel {
		    set tags [$tt\.canvas gettags $id]
		    if {[lindex $tags 0] eq "data"} {
			lappend total_sel [lindex $tags 1]
		    }
		}
	    }
	}
    }
    ## get unique elements  
    set total_sel [lsort -unique $total_sel]

    if {!$freshPlot} {
	## see which poins are new not in the brush regoin anymore 
	foreach point $ng_data("$ngLinkedInstance\.$dataName\.total_brushed") {
	    ## is the point anyway selected
	    if {![lindex $ng_data("$ngLinkedInstance\.$dataName\.selected") $point]} {
		if {[lsearch -exact $total_sel $point] == -1} {
		    ## get color
		    set col [lindex $ng_data("$ngLinkedInstance\.$dataName\.color") $point]
		    foreach tt1 $ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
			## color it to its original color
			$tt1.canvas itemconfigure "data && $point && !image" -fill $col
			$tt1\.nav.zoom.fcanvas.canvas itemconfigure "data && $point" -fill $col
		    }
		    
		} 
	    }
	}
    } 

    ## color all points below a brush
    foreach tt1 $ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
	foreach point $total_sel {
	    $tt1\.canvas itemconfigure "data && $point && !image" -fill $ng_data("$ngLinkedInstance\.$dataName\.brush_color")
	    $tt1\.nav.zoom.fcanvas.canvas itemconfigure "data && $point" -fill $ng_data("$ngLinkedInstance\.$dataName\.brush_color")
	}
    }
    set ng_data("$ngLinkedInstance\.$dataName\.total_brushed") $total_sel
}


## So far mostly for selection and brushing
proc modify_2d {ttID what ids} {
    global ng_data
    
    set dataName [$ttID\.dataName cget -text]
    set ngInstance [$ttID\.ngInstance cget -text]
    set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]

    switch -exact $what {
	select {
	    ## select/deselect a single data point
	    
	    ## data id (row number)
	    set tags [$ttID\.canvas gettags $ids]
	    
	   
	    if {[lsearch -exact $tags data] != -1} {
		set data_i [lindex $tags 1]
		## Check whether point gets deselected or selected
		if {[lindex $ng_data("$ngLinkedInstance\.$dataName\.selected") $data_i]} {

		    #puts stdout "deselect id=$data_i"
		    set col [lindex $ng_data("$ngLinkedInstance\.$dataName\.color") $data_i]
		    foreach tt $::ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
			
			$tt\.canvas itemconfigure "data && $data_i && !image" -fill $col
			$tt\.nav.zoom.fcanvas.canvas itemconfigure "data && $data_i" -fill $col
			
			## TODO: delete the following: 	$tt\.canvas dtag "data && $data_i" selected
		    }
		    lset ng_data("$ngLinkedInstance\.$dataName\.selected") $data_i 0
		} else {
		    #puts stdout "select id=$data_i"
		    foreach tt $::ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
#			set ngLinkedInstance [$tt\.ngLinkedInstance cget -text]
			$tt\.canvas itemconfigure "data && $data_i && !image" -fill $ng_data("$ngLinkedInstance\.$dataName\.brush_color")
			$tt\.nav.zoom.fcanvas.canvas itemconfigure "data && $data_i" -fill $ng_data("$ngLinkedInstance\.$dataName\.brush_color")

			## TODO: delete the following: $tt\.canvas addtag selected withtag "data && $data_i"
		    }
		    lset ng_data("$ngLinkedInstance\.$dataName\.selected") $data_i 1
		} 
	    }

	}
	permanentbrush {
	    ## select multiple data points
	    
	    foreach id $ids {
		set tags [$ttID\.canvas gettags $id]
		
		## check if a data point was selected
		if {[lindex $tags 0] eq "data"} {
		set data_i [lindex $tags 1]
		    foreach tt $::ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
#			set ngLinkedInstance [$tt\.ngLinkedInstance cget -text]
			$tt\.canvas itemconfigure "data && $data_i && !image"\
			    -fill $ng_data("$ngLinkedInstance\.$dataName\.brush_color")
			$tt\.nav.zoom.fcanvas.canvas itemconfigure "data && $data_i" -fill $ng_data("$ngLinkedInstance\.$dataName\.brush_color")

			## TODO delete: $tt\.canvas addtag selected withtag "data && $data_i"
		    }
		    lset ng_data("$ngLinkedInstance\.$dataName\.selected") $data_i 1
		}
	    }
	}
    }
}





proc display_shapes {ttID ngInstance ngLinkedInstance dataName viz} {
    global ng_data

    set w [winfo width  $ttID\.canvas]
    set h [winfo height $ttID\.canvas]
    set w2 [expr {$w/2.0}]
    set h2 [expr {$h/2.0}]

    set canvas $ttID\.canvas

    ## clear all data points
    $canvas delete data
    $canvas delete resize

    ## Zoom stuff
    set c_x $::ng_windowManager("$ngInstance\.$viz\.zoom_center_x")
    set c_y $::ng_windowManager("$ngInstance\.$viz\.zoom_center_y")
    set sq_zf [expr {sqrt($::ng_windowManager("$ngInstance\.$viz\.zoom_factor"))}]
    

    set i 0
    foreach x $ng_data("$ngInstance\.$dataName\.xcoord")\
	y $ng_data("$ngInstance\.$dataName\.ycoord")\
	size $ng_data("$ngLinkedInstance\.$dataName\.size")\
	col $ng_data("$ngLinkedInstance\.$dataName\.color")\
	sel $ng_data("$ngLinkedInstance\.$dataName\.selected") {
	    
	    set r [size_radius $size]
	    
	    #puts stdout "x=$x, y=$y, r=$r, col=$col"
	    set x_screen [expr {($x-$c_x)*$w2*$sq_zf+$w2}]
	    set y_screen [expr {(-$y-$c_y)*$h2*$sq_zf+$h2}]
	    
	    if {$x_screen+$r > 0 && $x_screen-$r <$w && $y_screen+$r>0 && $y_screen-$r <$h} {
     

	    if {$sel} {
		$canvas create oval [expr {$x_screen-$r}] [expr {$y_screen-$r}]\
		    [expr {$x_screen+$r}] [expr {$y_screen+$r}] -fill $ng_data("$ngLinkedInstance\.$dataName\.brush_color")\
		    -tag [list data $i shape] -width 0
	    } else {
		$canvas create oval [expr {$x_screen-$r}] [expr {$y_screen-$r}]\
		    [expr {$x_screen+$r}] [expr {$y_screen+$r}] -fill $col\
		    -tag [list data $i shape] -width 0
	    }
	}

	    incr i
	}
    
    $canvas lower data
}


proc display_zoombox {ttID ngInstance ngLinkedInstance dataName viz} {
    global ng_data
    
    set canvas_z $ttID\.nav.zoom.fcanvas.canvas
    
    $canvas_z delete all
    
    set zf  $::ng_windowManager("$ngInstance\.$viz\.zoom_factor")
    if {$zf <= 1} {
	set col $ng_data("$ngLinkedInstance\.$dataName\.bg")
    } else {
	set col darkgrey
    }
    
    ## zbox is meant the whole canvas > can_w, can_h
 
    set can_z_w $::ng_windowManager("zbox_width")
    set can_z_h $::ng_windowManager("zbox_height")   
    set can_w [winfo width  $ttID\.canvas]
    set can_h [winfo height $ttID\.canvas]
    
    set ratio_w [expr {double($can_w)/$can_z_w }]
    set ratio_h [expr {double($can_h)/$can_z_h}]
    
    ## local zbox_width is actually the dark grey area (representative for viewable area)
    if { $ratio_h > $ratio_w} {
	# fill out in y direction
	set zbox_height $can_z_h
	set zbox_width [expr {double($zbox_height)/$can_h*$can_w}]
	
	$canvas_z creat rect\
	    [expr {($can_z_w-$zbox_width)/2.0}]\
	    0\
	    [expr {($can_z_w+$zbox_width)/2.0}]\
	    $can_z_h\
	    -fill $col -tags zbox -width 0
    } else {
	# canvas gets filled out in y direction
	set zbox_width $can_z_w
	set zbox_height [expr {double($zbox_width)/$can_w*$can_h}]
	
	$canvas_z creat rect\
	    0\
	    [expr {($can_z_h-$zbox_height)/2.0}]\
	    $can_z_w\
	    [expr {($can_z_h+$zbox_height)/2.0}]\
	    -fill $col -tags zbox -width 0
    }

    set ::ng_windowManager("$ngInstance\.$viz\.zbox_area_width") $zbox_width
    set ::ng_windowManager("$ngInstance\.$viz\.zbox_area_height") $zbox_height 
    

    ## Zoom stuff
    set c_x $::ng_windowManager("$ngInstance\.$viz\.zoom_center_x")
    set c_y $::ng_windowManager("$ngInstance\.$viz\.zoom_center_y")
    set sq_zf [expr {sqrt($zf)}]
    

    # generate the zoom region
    if {$zf > 1} {
	set region_width\
	    [expr {$zbox_width/$sq_zf}]
	set region_height\
	    [expr {$zbox_height/$sq_zf}]
	
	
	set region_center_x\
	    [expr {($::ng_windowManager("zbox_width")\
			+$c_x*$zbox_width)/2}]
	set region_center_y\
	    [expr {($::ng_windowManager("zbox_height")\
			+$c_y*$zbox_height)/2}]
	
	$canvas_z create rect\
	    [expr {$region_center_x-$region_width/2}]\
	    [expr {$region_center_y-$region_height/2}]\
	    [expr {$region_center_x+$region_width/2}]\
	    [expr {$region_center_y+$region_height/2}]\
	    -fill $ng_data("$ngLinkedInstance\.$dataName\.bg")\
	    -outline $ng_data("$ngLinkedInstance\.$dataName\.bg")\
	    -width 0 -tag [list zoom zbox region]
	
    } 





    set w2 [expr {$zbox_width/2.0}]
    set h2 [expr {$zbox_height/2.0}]
    set can_z_w2 [expr {$can_z_w/2.0}]
    set can_z_h2 [expr {$can_z_h/2.0}]

    
    

    
    set i 0
    set r 1
    foreach x $ng_data("$ngInstance\.$dataName\.xcoord")\
	y $ng_data("$ngInstance\.$dataName\.ycoord")\
	col $ng_data("$ngLinkedInstance\.$dataName\.color")\
	sel $ng_data("$ngLinkedInstance\.$dataName\.selected") {
	    
	    #puts stdout "x=$x, y=$y, r=$r, col=$col"
	    set x_screen [expr {$x*$w2+$can_z_w2}]
	    set y_screen [expr {-$y*$h2+$can_z_h2}]
	    
	    if {$sel} {
		$canvas_z create oval [expr {$x_screen-$r}] [expr {$y_screen-$r}]\
		    [expr {$x_screen+$r}] [expr {$y_screen+$r}] -fill $ng_data("$ngLinkedInstance\.$dataName\.brush_color")\
		    -tag [list data $i] -width 0
	    } else {
		$canvas_z create oval [expr {$x_screen-$r}] [expr {$y_screen-$r}]\
		    [expr {$x_screen+$r}] [expr {$y_screen+$r}] -fill $col\
		    -tag [list data $i] -width 0
	    }
	    incr i
	}
    
    # generate the zoom region outline
    if {$zf > 1} {
		
	$canvas_z create rect\
	    [expr {$region_center_x-$region_width/2}]\
	    [expr {$region_center_y-$region_height/2}]\
	    [expr {$region_center_x+$region_width/2}]\
	    [expr {$region_center_y+$region_height/2}]\
	    -outline black -width 2 -tag [list zoom zbox region]
	
    } 

}



proc display_images {ttID ngInstance ngLinkedInstance dataName viz} {
    global ng_data
    global ng_windowManager
    
    set w [winfo width  $ttID\.canvas]
    set h [winfo height $ttID\.canvas]
    set w2 [expr {$w/2.0}]
    set h2 [expr {$h/2.0}]

    set canvas $ttID\.canvas

    ## clear all data points
    $canvas delete data
    $canvas delete resize

    ## Zoom stuff
    set c_x $ng_windowManager("$ngInstance\.$viz\.zoom_center_x")
    set c_y $ng_windowManager("$ngInstance\.$viz\.zoom_center_y")
    set sq_zf [expr {sqrt($ng_windowManager("$ngInstance\.$viz\.zoom_factor"))}]
    

    ## scale images 
    set i 0
    foreach image $ng_windowManager("$ngInstance\.$viz\.images")\
	size $ng_data("$ngLinkedInstance\.$dataName\.size")\
	diag_old $ng_windowManager("$ngInstance\.$viz\.image_diag_old") {
	  
	    set diag [size_diag $size]

	    
	    if {$diag ne $diag_old} {
		image_scale [lindex $ng_windowManager("$ngInstance\.$viz\.images_orig") $i] $diag\
		    [lindex $ng_windowManager("$ngInstance\.$viz\.images") $i]
		
		lset ng_windowManager("$ngInstance\.$viz\.image_diag_old") $i $diag
		lset ng_windowManager("$ngInstance\.$viz\.image_w2") $i\
		    [expr {[image width $image]/2}]
		lset ng_windowManager("$ngInstance\.$viz\.image_h2") $i\
		    [expr {[image height $image]/2}]
	    }
	    incr i
	}
    
    set i 0
    foreach x $ng_data("$ngInstance\.$dataName\.xcoord")\
	y $ng_data("$ngInstance\.$dataName\.ycoord")\
	image $ng_windowManager("$ngInstance\.$viz\.images")\
	imgw2 $ng_windowManager("$ngInstance\.$viz\.image_w2")\
	imgh2 $ng_windowManager("$ngInstance\.$viz\.image_h2")\
	halo $ng_windowManager("$ngInstance\.$viz\.image_halo")\
	col $ng_data("$ngLinkedInstance\.$dataName\.color")\
	sel $ng_data("$ngLinkedInstance\.$dataName\.selected") {
	    

            #puts stdout "image=$image, w2=$w2, h2=$h2"
	    #puts stdout "x=$x, y=$y, r=$r, col=$col"
	    set x_screen [expr {($x-$c_x)*$w2*$sq_zf+$w2}]
	    set y_screen [expr {(-$y-$c_y)*$h2*$sq_zf+$h2}]


	    if {$x_screen+$imgw2 > 0 && $x_screen-$imgw2 <$w && $y_screen+$imgh2>0 && $y_screen-$imgh2 <$h} {
		
		if {$sel} {
		    $canvas create rectangle\
			[expr {$x_screen -$imgw2-$halo}]\
			[expr {$y_screen -$imgh2-$halo}]\
			[expr {$x_screen +$imgw2+$halo}]\
			[expr {$y_screen +$imgh2+$halo}]\
			-fill $ng_data("$ngLinkedInstance\.$dataName\.brush_color")\
			-tag [list data $i halo]	
		} else {
		    $canvas create rectangle\
			[expr {$x_screen -$imgw2-$halo}]\
			[expr {$y_screen -$imgh2-$halo}]\
			[expr {$x_screen +$imgw2+$halo}]\
			[expr {$y_screen +$imgh2+$halo}]\
			-fill $col -tag [list data $i halo]
		}

		$canvas create image $x_screen $y_screen\
		    -anchor c -tag [list data $i image] -image $image
	    }
	    incr i
	}
    
    $canvas lower data
}



proc display_glyphs {ttID ngInstance ngLinkedInstance dataName viz} {
    global ng_data
    global ng_windowManager


    set w [winfo width  $ttID\.canvas]
    set h [winfo height $ttID\.canvas]
    set w2 [expr {$w/2.0}]
    set h2 [expr {$h/2.0}]

    set canvas $ttID\.canvas

    ## clear all data points
    $canvas delete data
    $canvas delete resize


    ## Zoom stuff
    set c_x $ng_windowManager("$ngInstance\.$viz\.zoom_center_x")
    set c_y $ng_windowManager("$ngInstance\.$viz\.zoom_center_y")
    set sq_zf [expr {sqrt($ng_windowManager("$ngInstance\.$viz\.zoom_factor"))}]


    set alphaL $ng_windowManager("$ngInstance\.$viz\.glyph_alpha")



    set i 0
    foreach x $ng_data("$ngInstance\.$dataName\.xcoord")\
	y $ng_data("$ngInstance\.$dataName\.ycoord")\
	glyph $ng_windowManager("$ngInstance\.$viz\.glyphs")\
	size $ng_data("$ngLinkedInstance\.$dataName\.size")\
	col $ng_data("$ngLinkedInstance\.$dataName\.color")\
	sel $ng_data("$ngLinkedInstance\.$dataName\.selected") {
	    #puts stdout "x=$x, y=$y, r=$r, col=$col"
	    set x_screen [expr {($x-$c_x)*$w2*$sq_zf+$w2}]
	    set y_screen [expr {(-$y-$c_y)*$h2*$sq_zf+$h2}]

	    
	    set r [size_glyph_radius $size]


	    if {$x_screen+$r > 0 && $x_screen-$r <$w && $y_screen+$r>0 && $y_screen-$r <$h} {
		
		set star {}
		
		foreach var $glyph alpha $alphaL {
		    #		puts stdout "x=$x, y=$y, glyph=$var, r=$r, alpha=$alpha"
		    
		    lappend star [expr {$x_screen + $r*$var*cos($alpha)}]
		    lappend star [expr {$y_screen + $r*$var*sin($alpha)}]
		    
		    # axis
		    # $canvas create line $x $y [expr {$x + $r*cos($alpha)}]\
			# 	[expr {$y + $r*sin($alpha)}]\
			# 	-tag [list data glyph$i glyphs axis] -fill black
		    
		}
		
		
		
		if {$sel} {
		    $canvas create polygon $star\
			-fill $ng_data("$ngLinkedInstance\.$dataName\.brush_color")\
			-tag [list data $i glyph polygon]	
		    
		} else {
		    $canvas create polygon $star -fill $col\
			-tag [list data $i glyph polygon]	
		}
	    }
	    incr i
	}
    
    $canvas lower data
    
}

proc display_text {ttID ngInstance ngLinkedInstance dataName viz} {
    global ng_data

    set w [winfo width  $ttID\.canvas]
    set h [winfo height $ttID\.canvas]
    set w2 [expr {$w/2.0}]
    set h2 [expr {$h/2.0}]

    set canvas $ttID\.canvas

    ## clear all data points
    $canvas delete data
    $canvas delete resize

    ## Zoom stuff
    set c_x $::ng_windowManager("$ngInstance\.$viz\.zoom_center_x")
    set c_y $::ng_windowManager("$ngInstance\.$viz\.zoom_center_y")
    set sq_zf [expr {sqrt($::ng_windowManager("$ngInstance\.$viz\.zoom_factor"))}]
    

    set i 0
    foreach x $ng_data("$ngInstance\.$dataName\.xcoord")\
	y $ng_data("$ngInstance\.$dataName\.ycoord")\
	txt $ng_data("$ngLinkedInstance\.$dataName\.text")\
	col $ng_data("$ngLinkedInstance\.$dataName\.color")\
	sel $ng_data("$ngLinkedInstance\.$dataName\.selected") {

	    #puts stdout "x=$x, y=$y, r=$r, col=$col"
	    set x_screen [expr {($x-$c_x)*$w2*$sq_zf+$w2}]
	    set y_screen [expr {(-$y-$c_y)*$h2*$sq_zf+$h2}]
	    
	    if {$x_screen>0 && $x_screen <$w && $y_screen>0 && $y_screen <$h} {
		 
	    
	    if {$sel} {
		$canvas create text $x_screen $y_screen -anchor c -text $txt\
		    -fill $ng_data("$ngLinkedInstance\.$dataName\.brush_color")\
		    -tag [list data $i text]
	    } else {
		$canvas create text $x_screen $y_screen -anchor c -text $txt\
		    -fill $col -tag [list data $i text]
	    }

	}
	    
	    incr i
	}
    
    $canvas lower data
}



proc display_data {ttID ngInstance ngLinkedInstance dataName viz} {
    switch -exact $::ng_windowManager("$ngInstance\.$viz.plotType") {
	shapes {
	    display_shapes $ttID $ngInstance $ngLinkedInstance $dataName $viz
	}
	text {
	    display_text $ttID $ngInstance $ngLinkedInstance $dataName $viz
	}
	glyphs {
	    display_glyphs $ttID $ngInstance $ngLinkedInstance $dataName $viz
	}
	images {
	    display_images $ttID $ngInstance $ngLinkedInstance $dataName $viz
	}
    }
}

proc update_displays {ttID ngInstance dataName viz} {
     set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]

    display_data $ttID $ngInstance $ngLinkedInstance $dataName $viz
    display_zoombox $ttID $ngInstance $ngLinkedInstance $dataName $viz
    brush $ttID 0 0
    update idletasks
}

proc change_color {ngLinkedInstance dataName col} {
    global ng_data
  
    set selected $ng_data("$ngLinkedInstance\.$dataName\.selected")
    foreach i $ng_data("$ngLinkedInstance\.$dataName\.total_brushed") {
	   lset selected $i 1
	} 

   set i 0
    foreach sel $selected {
	if {$sel} {
	    lset ng_data("$ngLinkedInstance\.$dataName\.color") $i $col
	}
	incr i
    }
}



proc size_radius {size} {
    
    if {$size > 0} {
	return $size
    } else {
	return 1
    }
}

proc size_glyph_radius {size} {
    if {$size > 0} {
	return [expr {$size*4}]
    } else {
	return 1
    }
}


proc size_diag {size} {
    if {$size > 0} {
	return [expr {$size *10}]
    } else {
	return 1
    }
}


proc change_size {ttID abs val} {
    global ng_data
    global ng_windowManager

    set ngInstance [$ttID\.ngInstance cget -text]
    set ngLinkedInstance [$ttID\.ngLinkedInstance cget -text]
    set dataName [$ttID\.dataName cget -text]
    set viz [$ttID\.viz cget -text]


   set selected $ng_data("$ngLinkedInstance\.$dataName\.selected")
    foreach i $ng_data("$ngLinkedInstance\.$dataName\.total_brushed") {
	   lset selected $i 1
	} 

    ## check first if any point is selected
    set k 0
    set ii 0
    foreach i $selected {
	if {$i} {
	    set k 1
	    break
	}
	incr ii
    }
    
    if {$k} {
	## some points selected	
	if {$abs} {
	    ## reset all sizes to min(size)+1
	    ## find min value
	    
	    set min [lindex $ng_data("$ngLinkedInstance\.$dataName\.size") $ii]
		    
	    foreach size $ng_data("$ngLinkedInstance\.$dataName\.size")\
		sel $selected  {
		    if {$sel} {
			if {$size < $min} {
			    set min $size
			}
		    }
	    }
	    set min [expr {$min + $val}]
	    
	    ## change size
	    set i 0
	    foreach sel $selected {
		if {$sel} {
		    lset ng_data("$ngLinkedInstance\.$dataName\.size") $i $min
		}
		incr i
	    }
	} else {
	    set i 0
	    foreach sel $selected\
		size  $ng_data("$ngLinkedInstance\.$dataName\.size") {
		    if {$sel} {
			lset ng_data("$ngLinkedInstance\.$dataName\.size") $i [expr {$size+$val}]
		    }
		    incr i
		}
	    
	    
	    
	}

	foreach tt $ng_windowManager("$ngLinkedInstance\.$dataName\.ttID") {
	    set tviz [$tt\.viz cget -text]
	    set ngInstance [$tt\.ngInstance cget -text]
	    display_data $tt $ngInstance $ngLinkedInstance $dataName $tviz
	}
	
	brush_highlight $ttID $ngInstance $ngLinkedInstance $dataName 0
    } else {

	## no points selected, 
    }
}
