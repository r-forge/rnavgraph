int i = 0;

#if TEA
#include <tcl.h>
#include <tk.h>
#include <math.h>
#include <string.h>




int size_radius(int size) {
	if(size > 0) {
		return(size);
	}else {
		return(1);
	}
}


int size_glyph_radius(int size) {
	if(size > 0) {
		return(size*4);
	}else {
		return(1);
	}
}

int size_image_diag(int size) {
	if(size > 0) {
		return(size*10);
	}else {
		return(5);
	}
}




static int display_shapes_Cmd(
		ClientData clientData,
		Tcl_Interp *interp,
		int objc,
		Tcl_Obj *const objv[]
){
	// Check if the number of submitted arguments is correct
	if (objc != 6) {
		Tcl_WrongNumArgs(interp, 1, objv, "ttID ngInstance ngLinkedInstance dataName viz");
		return TCL_ERROR;
	}

	// initialize variables
	int canvas_width, canvas_height;
	Tk_Window wmain, canvas;
	char *ttID, *ngInstance, *ngLinkedInstance, *dataName, *viz;
	char tclCmd[2000];
	double x, y, w2, h2;

	Tcl_Obj **xcoord, **ycoord, **size, **color, **selected;
	Tcl_Obj *ptr_cx, *ptr_cy, *ptr_zf, *ptr_brcol, *ptr_x, *ptr_y, *ptr_size, *ptr_sel, *ptr_col;
	int nx,ny,ns,nc,nsel;
	char *brush_color, *obj_color;
	double c_x, c_y, sq_zf;
	Tcl_Obj *ng_windowManager, *ng_data;
	int i;
	int obj_selected, obj_size, r;
	double x_screen, y_screen;


	Tcl_Obj **deactivated, *ptr_deactivated;
	int ndeactivated, obj_deactive;

	// copy variables
	ttID = Tcl_GetString(objv[1]);
	ngInstance = Tcl_GetString(objv[2]);
	ngLinkedInstance = Tcl_GetString(objv[3]);
	dataName = Tcl_GetString(objv[4]);
	viz = Tcl_GetString(objv[5]);

	ng_windowManager = Tcl_NewStringObj("ng_windowManager",-1);
	ng_data = Tcl_NewStringObj("ng_data",-1);


	// Find the toplevel . window
	wmain = Tk_MainWindow(interp);  // get . toplevel widget

	// find canvas widget
	sprintf(tclCmd,"%s.canvas",ttID);
	canvas = Tk_NameToWindow(interp, tclCmd, wmain);
	if (canvas == NULL) {
		Tcl_SetResult (interp, "invalid window path", TCL_STATIC);
		return TCL_ERROR;
	}
	canvas_width = Tk_Width(canvas);
	canvas_height = Tk_Height(canvas);

	w2 = canvas_width/2.0;
	h2 = canvas_height/2.0;


	// delete all data objects
	sprintf(tclCmd,"%s.canvas delete data",ttID);
	Tcl_Eval(interp, tclCmd);
	sprintf(tclCmd,"%s.canvas delete resize", ttID);
	Tcl_Eval(interp, tclCmd);

	// Zoom stuff
	sprintf(tclCmd,"\"%s.%s.zoom_center_x\"",ngInstance,viz);
	ptr_cx = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_cx, &c_x)) {
		Tcl_SetResult (interp, "could not read center x tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.zoom_center_y\"",ngInstance,viz);
	ptr_cy = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_cy, &c_y)) {
		Tcl_SetResult (interp, "could not read center y tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.zoom_factor\"",ngInstance,viz);
	ptr_zf = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_zf, &sq_zf)) {
		Tcl_SetResult (interp, "could not read zoom factor tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}
	sq_zf = sqrt(sq_zf);


	// brush color
	sprintf(tclCmd,"\"%s.%s.brush_color\"",ngLinkedInstance,dataName);
	ptr_brcol = Tcl_ObjGetVar2(interp, ng_data , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	brush_color = Tcl_GetStringFromObj(ptr_brcol, NULL);



	// link data
	sprintf(tclCmd,"\"%s.%s.xcoord\"",ngInstance,dataName);
	ptr_x = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_x, &nx, &xcoord)) {
		Tcl_SetResult (interp, "could not read xcoord tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}
	//printf("Number of Observations %i\n",nObs);

	sprintf(tclCmd,"\"%s.%s.ycoord\"",ngInstance,dataName);
	ptr_y = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_y, &ny, &ycoord)){
		Tcl_SetResult (interp, "could not read ycoord tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.size\"",ngLinkedInstance,dataName);
	ptr_size = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_size, &ns, &size)) {
		Tcl_SetResult (interp, "could not read size tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.color\"",ngLinkedInstance,dataName);
	ptr_col = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_col, &nc, &color)) {
		Tcl_SetResult (interp, "could not read color tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.selected\"",ngLinkedInstance,dataName);
	ptr_sel = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_sel, &nsel, &selected)){
		Tcl_SetResult (interp, "could not read selected tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}


	sprintf(tclCmd,"\"%s.%s.deactivated\"",ngLinkedInstance,dataName);
	ptr_deactivated = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_deactivated, &ndeactivated, &deactivated)){
		Tcl_SetResult (interp, "could not read deactivated tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}





	if((nx == ny) && (ny == ns) && (ns == nc) && (nc == nsel) && (nsel == ndeactivated)) {
		for (i = 0; i < ns; i++) {

			if(Tcl_GetIntFromObj(interp, deactivated[i], &obj_deactive)) {
				obj_deactive = 0;
				puts("could not read deactive element.");
			}

			if(!obj_deactive) {
				if(Tcl_GetDoubleFromObj(interp, xcoord[i], &x)) {
					x = 0;
					puts("could not read x element.");
				}
				if(Tcl_GetDoubleFromObj(interp, ycoord[i], &y)) {
					y = 0;
					puts("could not read y element.");
				}

				if(Tcl_GetIntFromObj(interp, size[i], &obj_size)) {
					obj_size = 1;
					puts("could not read object size element.");
				}

				x_screen = (x-c_x)*w2*sq_zf+w2;
				y_screen = (-y-c_y)*h2*sq_zf+h2;

				r = size_radius(obj_size);

				if((x_screen+r > 0) && (x_screen-r < canvas_width) && (y_screen+r > 0) && (y_screen - r < canvas_height)) {
					obj_color = Tcl_GetStringFromObj(color[i], NULL);

					if(Tcl_GetIntFromObj(interp, selected[i], &obj_selected)) {
						puts("could not read whether point is selected or not");
						obj_selected = 0;
					}

					// printf("x:%f.3, y:%f.3, size:%d, col:%s, sel:%d\n",x,y,obj_size,obj_color,obj_selected);
					if(obj_selected) {
						sprintf(tclCmd,"%s.canvas create oval %.3f %.3f %.3f %.3f -fill %s -tag [list data %i shape] -width 0",ttID,x_screen-r,y_screen-r,x_screen+r,y_screen+r, brush_color, i);
					} else {
						sprintf(tclCmd,"%s.canvas create oval %.3f %.3f %.3f %.3f -fill %s -tag [list data %i shape] -width 0",ttID,x_screen-r,y_screen-r,x_screen+r,y_screen+r, obj_color, i);
					}
					Tcl_Eval(interp,tclCmd);
				}
				//    puts(tclCmd);

			}
		}
	} else {
		puts("update points: Data vectors are not of the same length.");
	}

	sprintf(tclCmd,"%s.canvas raise brush",ttID);
	Tcl_Eval(interp,tclCmd);
	return TCL_OK;
}


// ---------------------------------------------------------------------------------------

static int display_zoombox_Cmd(
		ClientData clientData,
		Tcl_Interp *interp,
		int objc,
		Tcl_Obj *const objv[]
){


	// Check if the number of submitted arguments is correct
	if (objc != 6) {
		Tcl_WrongNumArgs(interp, 1, objv, "ttID ngInstance ngLinkedInstance dataName viz");
		return TCL_ERROR;
	}


	// initialize variables
	int canvas_width, canvas_height;
	Tk_Window wmain, canvas;
	char *ttID, *ngInstance, *ngLinkedInstance, *dataName, *viz;
	char tclCmd[2000], tmpCmd[2000], tmpStr[2000];
	double x, y, w2, h2;

	Tcl_Obj **xcoord, **ycoord, **color, **selected;
	Tcl_Obj *ptr_cx, *ptr_cy, *ptr_zf, *ptr_brcol, *ptr_x, *ptr_y, *ptr_sel, *ptr_col, *ptr_bgcol;
	Tcl_Obj *ptr_zbw, *ptr_zbh;
	int nx,ny,nc,nsel;
	char *brush_color, *obj_color, *bg_color;
	double c_x, c_y, sq_zf;
	Tcl_Obj *ng_windowManager, *ng_data;
	int i;
	int obj_selected;
	double x_screen, y_screen;
	Tcl_Obj *key1, *key2, *ptr_zb_area_w, *ptr_zb_area_h;

	double ratio_width, ratio_height;
	double zbox_width, zbox_height;
	double zbox_width2, zbox_height2;
	double zbox_p_width, zbox_p_height;
	double region_width = 0, region_height = 0;
	double region_center_x = 0, region_center_y = 0;

	Tcl_Obj **deactivated, *ptr_deactivated;
	int ndeactivated, obj_deactive;


	// copy variables
	ttID = Tcl_GetString(objv[1]);
	ngInstance = Tcl_GetString(objv[2]);
	ngLinkedInstance = Tcl_GetString(objv[3]);
	dataName = Tcl_GetString(objv[4]);
	viz = Tcl_GetString(objv[5]);

	ng_windowManager = Tcl_NewStringObj("ng_windowManager",-1);
	ng_data = Tcl_NewStringObj("ng_data",-1);


	// Find the toplevel . window
	wmain = Tk_MainWindow(interp);  // get . toplevel widget

	// find canvas widget
	sprintf(tclCmd,"%s.canvas",ttID);
	canvas = Tk_NameToWindow(interp, tclCmd, wmain);
	if (canvas == NULL) {
		Tcl_SetResult (interp, "invalid window path", TCL_STATIC);
		return TCL_ERROR;
	}
	canvas_width = Tk_Width(canvas);
	canvas_height = Tk_Height(canvas);

	sprintf(tmpCmd,"%s.nav.zoom.fcanvas.canvas",ttID);

	// delete all data objects
	sprintf(tclCmd,"%s delete all",tmpCmd);
	Tcl_Eval(interp, tclCmd);


	sprintf(tclCmd,"\"%s.%s.zoom_factor\"",ngInstance,viz);
	ptr_zf = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_zf, &sq_zf)) {
		Tcl_SetResult (interp, "could not read zoom factor tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}
	sq_zf = sqrt(sq_zf);

	// Background color
	sprintf(tclCmd,"\"%s.%s.bg\"",ngLinkedInstance,dataName);
	ptr_bgcol = Tcl_ObjGetVar2(interp, ng_data , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	bg_color = Tcl_GetStringFromObj(ptr_bgcol, NULL);

	if (sq_zf <= 1) {
		strcpy(tmpStr, bg_color);
	} else {
		strcpy(tmpStr, "darkgrey");
	}


	// zoom box width and height
	ptr_zbw = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj("\"zbox_width\"",-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_zbw, &zbox_width)){
		Tcl_SetResult (interp, "could not read center zoom box width variable.", TCL_STATIC);
		return TCL_ERROR;
	}

	ptr_zbh = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj("\"zbox_height\"",-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_zbh, &zbox_height)){
		Tcl_SetResult (interp, "could not read center zoom box height variable.", TCL_STATIC);
		return TCL_ERROR;
	}

	ratio_width = canvas_width/zbox_width;
	ratio_height = canvas_height/zbox_height;

	if(ratio_height > ratio_width) {
		zbox_p_height = zbox_height;
		zbox_p_width = zbox_p_height/canvas_height * canvas_width;

		sprintf(tclCmd, "%s create rect %.3f 0 %.3f %.3f -fill %s -tags zbox -width 0",
				tmpCmd,
				(zbox_width-zbox_p_width)/2,
				(zbox_width+zbox_p_width)/2,
				zbox_height,
				tmpStr);
	} else {
		zbox_p_width = zbox_width;
		zbox_p_height = zbox_p_width/canvas_width * canvas_height;

		sprintf(tclCmd, "%s create rect 0 %.3f %.3f %.3f -fill %s -tags zbox -width 0",
				tmpCmd,(zbox_height-zbox_p_height)/2,
				zbox_width,
				(zbox_height+zbox_p_height)/2,
				tmpStr);
	}
	Tcl_Eval(interp,tclCmd);
	//printf("%s\nzw: %.3f, zh: %.3f\n", tclCmd,zbox_p_width, zbox_p_height);

	// save zbox_p width and height

	key1 = Tcl_NewDoubleObj(zbox_p_width);
	sprintf(tclCmd,"\"%s.%s.zbox_area_width\"",ngInstance,viz);
	ptr_zb_area_w = Tcl_ObjSetVar2(interp, ng_windowManager, Tcl_NewStringObj(tclCmd,-1) , key1 , TCL_GLOBAL_ONLY);

	key2 = Tcl_NewDoubleObj(zbox_p_height);
	sprintf(tclCmd,"\"%s.%s.zbox_area_height\"",ngInstance,viz);
	ptr_zb_area_h = Tcl_ObjSetVar2(interp, ng_windowManager, Tcl_NewStringObj(tclCmd,-1) , key2 , TCL_GLOBAL_ONLY);



	// Zoom stuff
	sprintf(tclCmd,"\"%s.%s.zoom_center_x\"",ngInstance,viz);
	ptr_cx = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_cx, &c_x)) {
		Tcl_SetResult (interp, "could not read center x tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.zoom_center_y\"",ngInstance,viz);
	ptr_cy = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_cy, &c_y)) {
		Tcl_SetResult (interp, "could not read center y tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}





	// generate zoom region
	if (sq_zf > 1) {
		region_width = zbox_p_width/sq_zf;
		region_height = zbox_p_height/sq_zf;

		region_center_x = (zbox_width + c_x*zbox_p_width)/2;
		region_center_y = (zbox_height + c_y*zbox_p_height)/2;

		sprintf(tclCmd,"%s create rect %.3f %.3f %.3f %.3f -fill %s -width 0 -tags [list zoom zbox region]",
				tmpCmd,
				region_center_x-region_width/2,
				region_center_y-region_height/2,
				region_center_x+region_width/2,
				region_center_y+region_height/2,
				bg_color);
		Tcl_Eval(interp,tclCmd);
	}



	w2 = zbox_p_width/2;
	h2 = zbox_p_height/2;
	zbox_width2 = zbox_width/2;
	zbox_height2 = zbox_height/2;





	// brush color
	sprintf(tclCmd,"\"%s.%s.brush_color\"",ngLinkedInstance,dataName);
	ptr_brcol = Tcl_ObjGetVar2(interp, ng_data , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	brush_color = Tcl_GetStringFromObj(ptr_brcol, NULL);



	// link data
	sprintf(tclCmd,"\"%s.%s.xcoord\"",ngInstance,dataName);
	ptr_x = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_x, &nx, &xcoord)) {
		Tcl_SetResult (interp, "could not read xcoord tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}
	//printf("Number of Observations %i\n",nObs);

	sprintf(tclCmd,"\"%s.%s.ycoord\"",ngInstance,dataName);
	ptr_y = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_y, &ny, &ycoord)){
		Tcl_SetResult (interp, "could not read ycoord tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.color\"",ngLinkedInstance,dataName);
	ptr_col = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_col, &nc, &color)) {
		Tcl_SetResult (interp, "could not read color tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.selected\"",ngLinkedInstance,dataName);
	ptr_sel = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_sel, &nsel, &selected)){
		Tcl_SetResult (interp, "could not read selected tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}



	sprintf(tclCmd,"\"%s.%s.deactivated\"",ngLinkedInstance,dataName);
	ptr_deactivated = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_deactivated, &ndeactivated, &deactivated)){
		Tcl_SetResult (interp, "could not read deactivated tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}


	if((nx == ny) && (ny == nc) && (nc == nsel) && (nsel == ndeactivated)) {

		for (i = 0; i < nx; i++) {



			if(Tcl_GetIntFromObj(interp, deactivated[i], &obj_deactive)) {
				obj_deactive = 0;
				puts("could not read deactive element.");
			}

			if(!obj_deactive) {

				if(Tcl_GetDoubleFromObj(interp, xcoord[i], &x)) {
					x = 0;
					puts("could not read x element.");
				}
				if(Tcl_GetDoubleFromObj(interp, ycoord[i], &y)) {
					y = 0;
					puts("could not read y element.");
				}
				if(Tcl_GetIntFromObj(interp, selected[i], &obj_selected)) {
					puts("could not read whether point is selected or not");
					obj_selected = 0;
				}

				x_screen = x*w2+zbox_width2;
				y_screen = -y*h2 +zbox_height2;

				obj_color = Tcl_GetStringFromObj(color[i], NULL);

				if(obj_selected) {
					sprintf(tclCmd,"%s create oval %.3f %.3f %.3f %.3f -fill %s -tag [list data %i] -width 0",tmpCmd,x_screen-1,y_screen-1,x_screen+1,y_screen+1, brush_color, i);
				} else {
					sprintf(tclCmd,"%s create oval %.3f %.3f %.3f %.3f -fill %s -tag [list data %i] -width 0",tmpCmd,x_screen-1,y_screen-1,x_screen+1,y_screen+1, obj_color, i);
				}
				Tcl_Eval(interp,tclCmd);
			}
		}

	}
	// generate the zoom region outline

	if(sq_zf > 1) {

		sprintf(tclCmd,"%s create rect %.3f %.3f %.3f %.3f -outline black -width 2 -tags [list zoom zbox region]",
				tmpCmd,
				region_center_x-region_width/2,
				region_center_y-region_height/2,
				region_center_x+region_width/2,
				region_center_y+region_height/2);
		Tcl_Eval(interp,tclCmd);
	}


	return TCL_OK;
}

// ---------------------------------------------------------------------------------------

static int display_images_Cmd(
		ClientData clientData,
		Tcl_Interp *interp,
		int objc,
		Tcl_Obj *const objv[]
){

	// Check if the number of submitted arguments is correct
	if (objc != 6) {
		Tcl_WrongNumArgs(interp, 1, objv, "ttID ngInstance ngLinkedInstance dataName viz");
		return TCL_ERROR;
	}

	// initialize variables
	int canvas_width, canvas_height;
	Tk_Window wmain, canvas;
	char *ttID, *ngInstance, *ngLinkedInstance, *dataName, *viz;
	char tclCmd[2000];
	double x, y, w2, h2;

	Tcl_Obj **xcoord, **ycoord, **color, **selected;
	Tcl_Obj *ptr_cx, *ptr_cy, *ptr_zf, *ptr_brcol, *ptr_x, *ptr_y, *ptr_halo, *ptr_imgw2, *ptr_sel, *ptr_col, *ptr_img; //, *ptr_imgh2
	int nx,ny,nc,nsel, nh, nw2,nh2,nimg;
	char *brush_color, *obj_color;
	double c_x, c_y, sq_zf;
	Tcl_Obj *ng_windowManager, *ng_data;
	int i;
	int obj_selected;
	double x_screen, y_screen;


	Tcl_Obj **images, **image_w2, **image_h2, **image_halo;//, **diag_old, **images_orig
	int obj_image_halo; //image_height, image_width, iobj_diag_old, iobj_diag
	double image_width2, image_height2;
	char *obj_image_name; //, *obj_image_name_orig;
	//Tk_PhotoHandle srcImage;


	Tcl_Obj **deactivated, *ptr_deactivated;
	int ndeactivated, obj_deactive;





	// copy variables
	ttID = Tcl_GetString(objv[1]);
	ngInstance = Tcl_GetString(objv[2]);
	ngLinkedInstance = Tcl_GetString(objv[3]);
	dataName = Tcl_GetString(objv[4]);
	viz = Tcl_GetString(objv[5]);

	ng_windowManager = Tcl_NewStringObj("ng_windowManager",-1);
	ng_data = Tcl_NewStringObj("ng_data",-1);


	// Find the toplevel . window
	wmain = Tk_MainWindow(interp);  // get . toplevel widget

	// find canvas widget
	sprintf(tclCmd,"%s.canvas",ttID);
	canvas = Tk_NameToWindow(interp, tclCmd, wmain);
	if (canvas == NULL) {
		Tcl_SetResult (interp, "invalid window path", TCL_STATIC);
		return TCL_ERROR;
	}
	canvas_width = Tk_Width(canvas);
	canvas_height = Tk_Height(canvas);

	w2 = canvas_width/2.0;
	h2 = canvas_height/2.0;


	// delete all data objects
	sprintf(tclCmd,"%s.canvas delete data",ttID);
	Tcl_Eval(interp, tclCmd);
	sprintf(tclCmd,"%s.canvas delete resize", ttID);
	Tcl_Eval(interp, tclCmd);

	// Zoom stuff
	sprintf(tclCmd,"\"%s.%s.zoom_center_x\"",ngInstance,viz);
	ptr_cx = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_cx, &c_x)) {
		Tcl_SetResult (interp, "could not read center x tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.zoom_center_y\"",ngInstance,viz);
	ptr_cy = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_cy, &c_y)) {
		Tcl_SetResult (interp, "could not read center y tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.zoom_factor\"",ngInstance,viz);
	ptr_zf = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_zf, &sq_zf)) {
		Tcl_SetResult (interp, "could not read zoom factor tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}
	sq_zf = sqrt(sq_zf);


	// For the moment let this be a part of tcl
	/*
  // scale images
  sprintf(tclCmd,"\"%s.%s.images\"",ngInstance,viz);
  var = Tcl_ObjGetVar2(interp, ng_windowManager, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY); 
  Tcl_ListObjGetElements(interp, var, &nObs, &images);

  sprintf(tclCmd,"\"%s.%s.images_orig\"",ngInstance,viz);
  var = Tcl_ObjGetVar2(interp, ng_windowManager, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY); 
  Tcl_ListObjGetElements(interp, var, &nObs, &images_orig);

  sprintf(tclCmd,"\"%s.%s.size\"",ngLinkedInstance,dataName);
  var = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY); 
  Tcl_ListObjGetElements(interp, var, &nObs, &size);

  sprintf(tclCmd,"\"%s.%s.image_diag_old\"",ngInstance,dataName);
  var = Tcl_ObjGetVar2(interp, ng_windowManager, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY); 
  Tcl_ListObjGetElements(interp, var, &nObs, &diag_old);



  for (i = 0; i < nObs; i++) {
    Tcl_GetIntFromObj(interp, diag_old[i], &iobj_diag_old);
    Tcl_GetIntFromObj(interp, size[i], &obj_size);

    iobj_diag = size_image_diag(obj_size);



    if(iobj_diag != iobj_diag_old) {
      printf("%i:%i ",iobj_diag,iobj_diag_old);
      // resize image
      obj_image_name = Tcl_GetStringFromObj(images[i], NULL);
      obj_image_name_orig = Tcl_GetStringFromObj(images_orig[i], NULL);


      sprintf(tclCmd,"image_scale %s %i %s", obj_image_name_orig, iobj_diag, obj_image_name);
      Tcl_Eval(interp, tclCmd);

      // save changes
      sprintf(tclCmd,"lset ::ng_windowManager(\"%s.%s.image_diag_old\") %i %i",ngInstance,dataName,i,iobj_diag);
      //printf("%s\n",tclCmd);
      Tcl_Eval(interp, tclCmd);

      srcImage = Tk_FindPhoto(interp, obj_image_name);
      if (!srcImage)
        return TCL_ERROR;

      Tk_PhotoGetSize(srcImage, &image_width, &image_height);
      //printf("Image: %ix%i\n", image_width, image_height);

      sprintf(tclCmd,"lset ::ng_windowManager(\"%s.%s.image_w2\") %i %i",ngInstance,viz,i,image_width/2);
      Tcl_Eval(interp, tclCmd);

      sprintf(tclCmd,"lset ::ng_windowManager(\"%s.%s.image_h2\") %i %i",ngInstance,viz,i,image_height/2);
      Tcl_Eval(interp, tclCmd);
    }
  }
      printf("\n\n");	

	 */

	// brush color
	sprintf(tclCmd,"\"%s.%s.brush_color\"",ngLinkedInstance,dataName);
	ptr_brcol = Tcl_ObjGetVar2(interp, ng_data , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	brush_color = Tcl_GetStringFromObj(ptr_brcol, NULL);



	// link data
	sprintf(tclCmd,"\"%s.%s.xcoord\"",ngInstance,dataName);
	ptr_x = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_x, &nx, &xcoord)) {
		Tcl_SetResult (interp, "could not read xcoord tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}
	//printf("Number of Observations %i\n",nObs);

	sprintf(tclCmd,"\"%s.%s.ycoord\"",ngInstance,dataName);
	ptr_y = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_y, &ny, &ycoord)){
		Tcl_SetResult (interp, "could not read ycoord tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}


	sprintf(tclCmd,"\"%s.%s.color\"",ngLinkedInstance,dataName);
	ptr_col = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_col, &nc, &color)) {
		Tcl_SetResult (interp, "could not read color tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.selected\"",ngLinkedInstance,dataName);
	ptr_sel = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_sel, &nsel, &selected)){
		Tcl_SetResult (interp, "could not read selected tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}


	sprintf(tclCmd,"\"%s.%s.deactivated\"",ngLinkedInstance,dataName);
	ptr_deactivated = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_deactivated, &ndeactivated, &deactivated)){
		Tcl_SetResult (interp, "could not read deactivated tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}


	sprintf(tclCmd,"\"%s.%s.image_w2\"",ngInstance,viz);
	ptr_imgw2 = Tcl_ObjGetVar2(interp, ng_windowManager, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_imgw2, &nw2, &image_w2)) {
		Tcl_SetResult (interp, "could not read image width/2 tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}


	sprintf(tclCmd,"\"%s.%s.image_h2\"",ngInstance,viz);
	ptr_imgw2 = Tcl_ObjGetVar2(interp, ng_windowManager, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_imgw2, &nh2, &image_h2)) {
		Tcl_SetResult (interp, "could not read image height/2 tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.image_halo\"",ngInstance,viz);
	ptr_halo = Tcl_ObjGetVar2(interp, ng_windowManager, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_halo, &nh, &image_halo)) {
		Tcl_SetResult (interp, "could not read halo width tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}


	sprintf(tclCmd,"\"%s.%s.images\"",ngInstance,viz);
	ptr_img = Tcl_ObjGetVar2(interp, ng_windowManager, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_img, &nimg, &images)) {
		Tcl_SetResult (interp, "could not read image tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}

	if((nx==ny) && (ny==nc) && (nc==nsel) && (nsel == nc) && (nc == nh) && (nh == nw2) && (nw2==nh2) && (nh2 == nimg) && (nimg == ndeactivated)) {
		for (i = 0; i < nx; i++) {

			if(Tcl_GetIntFromObj(interp, deactivated[i], &obj_deactive)) {
				obj_deactive = 0;
				puts("could not read deactive element.");
			}

			if(!obj_deactive) {
				//printf("p%i ",i);
				if(Tcl_GetDoubleFromObj(interp, xcoord[i], &x)) {
					x = 0;
					puts("could not read x element.");
				}
				//printf("x-");
				if(Tcl_GetDoubleFromObj(interp, ycoord[i], &y)) {
					y = 0;
					puts("could not read y element.");
				}
				//printf("y-");
				if(Tcl_GetDoubleFromObj(interp, image_w2[i], &image_width2)) {
					image_width2 = 5;
					puts("could not read w2 element.");
				}
				//printf("w2-");
				if(Tcl_GetDoubleFromObj(interp, image_h2[i], &image_height2)) {
					image_height2 = 5;
					puts("could not read h2 element.");
				}
				//printf("h2-");

				x_screen = (x-c_x)*w2*sq_zf+w2;
				y_screen = (-y-c_y)*h2*sq_zf+h2;


				if((x_screen+image_width2 > 0) && (x_screen -image_width2 < canvas_width) && (y_screen+image_height2 > 0) && (y_screen - image_height2 < canvas_height)) {
					obj_color = Tcl_GetStringFromObj(color[i], NULL);

					//printf("cond-");
					if(Tcl_GetIntFromObj(interp, selected[i], &obj_selected)) {
						puts("could not read whether point is selected or not");
						obj_selected = 0;
					}
					//printf("sel-");
					if(Tcl_GetIntFromObj(interp, image_halo[i], &obj_image_halo)) {
						puts("could not read halo tcl variable");
						obj_selected = 0;
					}
					//printf("halo-");

					if(obj_selected) {
						sprintf(tclCmd,"%s.canvas create rectangle %.3f %.3f %.3f %.3f -fill %s -tag [list data %i halo] -width 0",ttID,
								x_screen-image_width2 -  obj_image_halo,
								y_screen-image_height2 - obj_image_halo,
								x_screen+image_width2 +  obj_image_halo,
								y_screen+image_height2 + obj_image_halo,
								brush_color, i);
					} else {
						sprintf(tclCmd,"%s.canvas create rectangle %.3f %.3f %.3f %.3f -fill %s -tag [list data %i halo] -width 0",ttID,
								x_screen-image_width2 -  obj_image_halo,
								y_screen-image_height2 - obj_image_halo,
								x_screen+image_width2 +  obj_image_halo,
								y_screen+image_height2 + obj_image_halo,
								obj_color, i);
					}
					Tcl_Eval(interp,tclCmd);

					obj_image_name = Tcl_GetStringFromObj(images[i], NULL);
					sprintf(tclCmd,"%s.canvas create image %.3f %.3f -anchor c -tags [list data %i image] -image %s",
							ttID,
							x_screen, y_screen,
							i,obj_image_name);
					Tcl_Eval(interp,tclCmd);
					//printf("cmd");
				}
				//printf("\n");
			}
		}
	} else {
		puts("update images: Data vectors are not of the same length.");
	}


	sprintf(tclCmd,"%s.canvas raise brush",ttID);
	Tcl_Eval(interp,tclCmd);


	return TCL_OK;
}


// ------------------------------------------------------------------------------------------------------


static int display_glyphs_Cmd(
		ClientData clientData,
		Tcl_Interp *interp,
		int objc,
		Tcl_Obj *const objv[]
){

	// Check if the number of submitted arguments is correct
	if (objc != 6) {
		Tcl_WrongNumArgs(interp, 1, objv, "ttID ngInstance ngLinkedInstance dataName viz");
		return TCL_ERROR;
	}


	// initialize variables
	int canvas_width, canvas_height;
	Tk_Window wmain, canvas;
	char *ttID, *ngInstance, *ngLinkedInstance, *dataName, *viz;
	char tclCmd[2000],tmpCmd[5000],tmpStr[5000];
	double x, y, w2, h2;

	Tcl_Obj **xcoord, **ycoord, **size, **color, **selected;
	Tcl_Obj *ptr_cx, *ptr_cy, *ptr_zf, *ptr_brcol, *ptr_x, *ptr_y, *ptr_size, *ptr_sel, *ptr_col, *ptr_glyph, *ptr_gla;
	int nx,ny,ns,nc,nsel,ngl;
	char *brush_color, *obj_color;
	double c_x, c_y, sq_zf;
	Tcl_Obj *ng_windowManager, *ng_data;
	int i, ii;
	int obj_selected, obj_size, r;
	double x_screen, y_screen;


	double alpha;
	Tcl_Obj **glyphs_outer, **glyphs_inner, **glyph_alpha;
	int glyph_nvar;
	double glyph_polygon;

	Tcl_Obj **deactivated, *ptr_deactivated;
	int ndeactivated, obj_deactive;
	
	double inner_Radius = 5;
	double rtmp;


	// copy variables
	ttID = Tcl_GetString(objv[1]);
	ngInstance = Tcl_GetString(objv[2]);
	ngLinkedInstance = Tcl_GetString(objv[3]);
	dataName = Tcl_GetString(objv[4]);
	viz = Tcl_GetString(objv[5]);

	ng_windowManager = Tcl_NewStringObj("ng_windowManager",-1);
	ng_data = Tcl_NewStringObj("ng_data",-1);


	// Find the toplevel . window
	wmain = Tk_MainWindow(interp);  // get . toplevel widget

	// find canvas widget
	sprintf(tclCmd,"%s.canvas",ttID);
	canvas = Tk_NameToWindow(interp, tclCmd, wmain);
	if (canvas == NULL) {
		Tcl_SetResult (interp, "invalid window path", TCL_STATIC);
		return TCL_ERROR;
	}
	canvas_width = Tk_Width(canvas);
	canvas_height = Tk_Height(canvas);
	w2 = canvas_width/2.0;
	h2 = canvas_height/2.0;


	// delete all data objects
	sprintf(tclCmd,"%s.canvas delete data",ttID);
	Tcl_Eval(interp, tclCmd);
	sprintf(tclCmd,"%s.canvas delete resize", ttID);
	Tcl_Eval(interp, tclCmd);




	// Zoom stuff
	sprintf(tclCmd,"\"%s.%s.zoom_center_x\"",ngInstance,viz);
	ptr_cx = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_cx, &c_x)) {
		Tcl_SetResult (interp, "could not read center x tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.zoom_center_y\"",ngInstance,viz);
	ptr_cy = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_cy, &c_y)) {
		Tcl_SetResult (interp, "could not read center y tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.zoom_factor\"",ngInstance,viz);
	ptr_zf = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_zf, &sq_zf)) {
		Tcl_SetResult (interp, "could not read zoom factor tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}
	sq_zf = sqrt(sq_zf);


	// brush color
	sprintf(tclCmd,"\"%s.%s.brush_color\"",ngLinkedInstance,dataName);
	ptr_brcol = Tcl_ObjGetVar2(interp, ng_data , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	brush_color = Tcl_GetStringFromObj(ptr_brcol, NULL);


	// link data
	sprintf(tclCmd,"\"%s.%s.xcoord\"",ngInstance,dataName);
	ptr_x = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_x, &nx, &xcoord)) {
		Tcl_SetResult (interp, "could not read xcoord tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}
	//printf("Number of Observations %i\n",nObs);

	sprintf(tclCmd,"\"%s.%s.ycoord\"",ngInstance,dataName);
	ptr_y = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_y, &ny, &ycoord)){
		Tcl_SetResult (interp, "could not read ycoord tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.size\"",ngLinkedInstance,dataName);
	ptr_size = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_size, &ns, &size)) {
		Tcl_SetResult (interp, "could not read size tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.color\"",ngLinkedInstance,dataName);
	ptr_col = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_col, &nc, &color)) {
		Tcl_SetResult (interp, "could not read color tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.selected\"",ngLinkedInstance,dataName);
	ptr_sel = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_sel, &nsel, &selected)){
		Tcl_SetResult (interp, "could not read selected tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}


	sprintf(tclCmd,"\"%s.%s.glyphs\"",ngInstance,viz);
	ptr_glyph = Tcl_ObjGetVar2(interp, ng_windowManager, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_glyph, &ngl, &glyphs_outer)){
		Tcl_SetResult (interp, "could not read glyph outer tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}


	// glyph_alpha list
	sprintf(tclCmd,"\"%s.%s.glyph_alpha\"",ngInstance,viz);
	ptr_gla = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_gla, &glyph_nvar, &glyph_alpha)){
		Tcl_SetResult (interp, "could not read glyph alpha tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}


	sprintf(tclCmd,"\"%s.%s.deactivated\"",ngLinkedInstance,dataName);
	ptr_deactivated = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_deactivated, &ndeactivated, &deactivated)){
		Tcl_SetResult (interp, "could not read deactivated tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}





	if((nx == ny) && (ny == ns) && (ns == nc) && (nc == nsel) && (nsel == ngl) && (ngl == ndeactivated)) {
		for (i = 0; i < nx; i++) {
			if(Tcl_GetIntFromObj(interp, deactivated[i], &obj_deactive)) {
				obj_deactive = 0;
				puts("could not read deactive element.");
			}

			if(!obj_deactive) {
				if(Tcl_GetDoubleFromObj(interp, xcoord[i], &x)) {
					x = 0;
					puts("could not read x element.");
				}
				//printf("x-");
				if(Tcl_GetDoubleFromObj(interp, ycoord[i], &y)) {
					y = 0;
					puts("could not read y element.");
				}
				if(Tcl_GetIntFromObj(interp, size[i], &obj_size)) {
					obj_size = 1;
					puts("could not read object size element.");
				}


				x_screen = (x-c_x)*w2*sq_zf+w2;
				y_screen = (-y-c_y)*h2*sq_zf+h2;
				r = size_glyph_radius(obj_size);

				if((x_screen+r > 0) && (x_screen-r < canvas_width) && (y_screen+r > 0) && (y_screen - r < canvas_height)) {

					obj_color = Tcl_GetStringFromObj(color[i], NULL);

					if(Tcl_GetIntFromObj(interp, selected[i], &obj_selected)) {
						puts("could not read whether point is selected or not");
						obj_selected = 0;
					}

					if(Tcl_ListObjGetElements(interp, glyphs_outer[i], &glyph_nvar, &glyphs_inner)) {
						Tcl_SetResult (interp, "could not read glyph inner tcl list.", TCL_STATIC);
						return TCL_ERROR;
					}

					strcpy(tmpCmd,"");
					for (ii = 0; ii < glyph_nvar; ii++){
					  Tcl_GetDoubleFromObj(interp, glyphs_inner[ii], &glyph_polygon);
					  Tcl_GetDoubleFromObj(interp, glyph_alpha[ii], &alpha);
					  
					  rtmp = (inner_Radius + r*glyph_polygon);
					  
					  sprintf(tmpStr, "%.3f ", x_screen+rtmp*cos(alpha));
					  strcat(tmpCmd,tmpStr);
					  sprintf(tmpStr, "%.3f ", y_screen+rtmp*sin(alpha));
					  strcat(tmpCmd,tmpStr);
					}
					
					if(obj_selected) {
					  sprintf(tclCmd,"%s.canvas create polygon %s -fill %s -tag [list data %i glyph polygon] -width 0",ttID,tmpCmd,brush_color, i);
					} else {
					  sprintf(tclCmd,"%s.canvas create polygon %s -fill %s -tag [list data %i glyph polygon] -width 0",ttID,tmpCmd,obj_color, i);
					}
					Tcl_Eval(interp,tclCmd);

					// black dot
					strcpy(tmpCmd,"");
					sprintf(tclCmd,"%s.canvas create oval %.3f %.3f %.3f %.3f -fill black -tag [list data %i glyph sunflower] -width 0",ttID,x_screen-inner_Radius,y_screen-inner_Radius,x_screen+inner_Radius,y_screen+inner_Radius,i);
					//printf("%s\n",tclCmd);
					Tcl_Eval(interp,tclCmd);

				}
			}
		}
	}

	sprintf(tclCmd,"%s.canvas raise brush", ttID);
	Tcl_Eval(interp,tclCmd);


	return TCL_OK;
}


// -------------------------------------------------------------------------------------------


static int display_text_Cmd(
		ClientData clientData,
		Tcl_Interp *interp,
		int objc,
		Tcl_Obj *const objv[]
){
	// Check if the number of submitted arguments is correct
	if (objc != 6) {
		Tcl_WrongNumArgs(interp, 1, objv, "ttID ngInstance ngLinkedInstance dataName viz");
		return TCL_ERROR;
	}

	// initialize variables
	int canvas_width, canvas_height;
	Tk_Window wmain, canvas;
	char *ttID, *ngInstance, *ngLinkedInstance, *dataName, *viz;
	char tclCmd[2000];
	double x, y, w2, h2;

	Tcl_Obj **xcoord, **ycoord, **text, **color, **selected;
	Tcl_Obj *ptr_cx, *ptr_cy, *ptr_zf, *ptr_brcol, *ptr_x, *ptr_y, *ptr_sel, *ptr_col, *ptr_txt;
	int nx,ny,nc,nsel,ntxt;
	char *brush_color, *obj_color, *obj_text;
	double c_x, c_y, sq_zf;
	Tcl_Obj *ng_windowManager, *ng_data;
	int i;
	int obj_selected;
	double x_screen, y_screen;


	Tcl_Obj **deactivated, *ptr_deactivated;
	int ndeactivated, obj_deactive;


	// copy variables
	ttID = Tcl_GetString(objv[1]);
	ngInstance = Tcl_GetString(objv[2]);
	ngLinkedInstance = Tcl_GetString(objv[3]);
	dataName = Tcl_GetString(objv[4]);
	viz = Tcl_GetString(objv[5]);

	ng_windowManager = Tcl_NewStringObj("ng_windowManager",-1);
	ng_data = Tcl_NewStringObj("ng_data",-1);


	// Find the toplevel . window
	wmain = Tk_MainWindow(interp);  // get . toplevel widget

	// find canvas widget
	sprintf(tclCmd,"%s.canvas",ttID);
	canvas = Tk_NameToWindow(interp, tclCmd, wmain);
	if (canvas == NULL) {
		Tcl_SetResult (interp, "invalid window path", TCL_STATIC);
		return TCL_ERROR;
	}
	canvas_width = Tk_Width(canvas);
	canvas_height = Tk_Height(canvas);

	w2 = canvas_width/2.0;
	h2 = canvas_height/2.0;


	// delete all data objects
	sprintf(tclCmd,"%s.canvas delete data",ttID);
	Tcl_Eval(interp, tclCmd);
	sprintf(tclCmd,"%s.canvas delete resize", ttID);
	Tcl_Eval(interp, tclCmd);

	// Zoom stuff
	sprintf(tclCmd,"\"%s.%s.zoom_center_x\"",ngInstance,viz);
	ptr_cx = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_cx, &c_x)) {
		Tcl_SetResult (interp, "could not read center x tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.zoom_center_y\"",ngInstance,viz);
	ptr_cy = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_cy, &c_y)) {
		Tcl_SetResult (interp, "could not read center y tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.zoom_factor\"",ngInstance,viz);
	ptr_zf = Tcl_ObjGetVar2(interp, ng_windowManager , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_GetDoubleFromObj(interp, ptr_zf, &sq_zf)) {
		Tcl_SetResult (interp, "could not read zoom factor tcl variable.", TCL_STATIC);
		return TCL_ERROR;
	}
	sq_zf = sqrt(sq_zf);


	// brush color
	sprintf(tclCmd,"\"%s.%s.brush_color\"",ngLinkedInstance,dataName);
	ptr_brcol = Tcl_ObjGetVar2(interp, ng_data , Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	brush_color = Tcl_GetStringFromObj(ptr_brcol, NULL);



	// link data
	sprintf(tclCmd,"\"%s.%s.xcoord\"",ngInstance,dataName);
	ptr_x = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_x, &nx, &xcoord)) {
		Tcl_SetResult (interp, "could not read xcoord tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}
	//printf("Number of Observations %i\n",nObs);

	sprintf(tclCmd,"\"%s.%s.ycoord\"",ngInstance,dataName);
	ptr_y = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_y, &ny, &ycoord)){
		Tcl_SetResult (interp, "could not read ycoord tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.color\"",ngLinkedInstance,dataName);
	ptr_col = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_col, &nc, &color)) {
		Tcl_SetResult (interp, "could not read color tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}

	sprintf(tclCmd,"\"%s.%s.selected\"",ngLinkedInstance,dataName);
	ptr_sel = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_sel, &nsel, &selected)){
		Tcl_SetResult (interp, "could not read selected tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}


	sprintf(tclCmd,"\"%s.%s.deactivated\"",ngLinkedInstance,dataName);
	ptr_deactivated = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_deactivated, &ndeactivated, &deactivated)){
		Tcl_SetResult (interp, "could not read deactivated tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}


	sprintf(tclCmd,"\"%s.%s.text\"",ngLinkedInstance,dataName);
	ptr_txt = Tcl_ObjGetVar2(interp, ng_data, Tcl_NewStringObj(tclCmd,-1) ,TCL_GLOBAL_ONLY);
	if(Tcl_ListObjGetElements(interp, ptr_txt, &ntxt, &text)){
		Tcl_SetResult (interp, "could not read text tcl list.", TCL_STATIC);
		return TCL_ERROR;
	}


	if((nx == ny) && (ny == nc) && (nc == nsel) && (nsel == ntxt) && (ntxt == ndeactivated)) {

		for (i = 0; i < nx; i++) {

			if(Tcl_GetIntFromObj(interp, deactivated[i], &obj_deactive)) {
				obj_deactive = 0;
				puts("could not read deactive element.");
			}

			if(!obj_deactive) {

				if(Tcl_GetDoubleFromObj(interp, xcoord[i], &x)) {
					x = 0;
					puts("could not read x element.");
				}
				if(Tcl_GetDoubleFromObj(interp, ycoord[i], &y)) {
					y = 0;
					puts("could not read y element.");
				}
				if(Tcl_GetIntFromObj(interp, selected[i], &obj_selected)) {
					puts("could not read whether point is selected or not");
					obj_selected = 0;
				}

				obj_text = Tcl_GetStringFromObj(text[i], NULL);
				obj_color = Tcl_GetStringFromObj(color[i], NULL);

				x_screen = (x-c_x)*w2*sq_zf+w2;
				y_screen = (-y-c_y)*h2*sq_zf+h2;


				if(obj_selected) {
					sprintf(tclCmd,"%s.canvas create text %.3f %.3f -anchor c -text %s -fill %s -tag [list data %i text] ",ttID,x_screen,y_screen, obj_text, brush_color, i);
				} else {
					sprintf(tclCmd,"%s.canvas create text %.3f %.3f -anchor c -text %s -fill %s -tag [list data %i text] ",ttID,x_screen,y_screen, obj_text, obj_color, i);
				}
				Tcl_Eval(interp,tclCmd);
			}

			sprintf(tclCmd,"%s.canvas raise brush",ttID);
			Tcl_Eval(interp,tclCmd);
		}
	} else {
		puts("update points: Data vectors are not of the same length.");
	}



	return TCL_OK;
}



/*
 ** The following is the only public symbol in this source file.  .
 */
int DLLEXPORT Displaystufftea_Init(Tcl_Interp *interp){
	Tcl_CreateObjCommand(interp, "display_shapes", display_shapes_Cmd, 0, 0);
	Tcl_CreateObjCommand(interp, "display_zoombox", display_zoombox_Cmd, 0, 0);
	Tcl_CreateObjCommand(interp, "display_images_C", display_images_Cmd, 0, 0);
	Tcl_CreateObjCommand(interp, "display_glyphs", display_glyphs_Cmd, 0, 0);
	Tcl_CreateObjCommand(interp, "display_text", display_text_Cmd, 0, 0);
	return TCL_OK;
}

#endif
