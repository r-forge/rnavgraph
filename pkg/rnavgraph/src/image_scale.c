// run: gcc -shared -o imgscale.so -DUSE_TCL_STUBS -I/usr/include/tcl8.5/ imagescale_adrian_85.c -L/usr/lib/ -ltclstub8.5 -fPIC
//gcc -Wall -g -DUSE_TCL_STUBS -I/Library/Frameworks/Tcl.framework/Header -c imagescale_adrian_85.c
//gcc -dynamiclib -o imgscale.dylib imagescale_adrian_85.o -framework Tk -framework Tcl 


// windows:
// gcc -shared -o imgscale.dll -DUSE_TCL_STUBS -DUSE_TK_STUBS -I C:\Tcl\include -c imagescale_adrian_85.c -L C:\Tcl\lib -ltclstub85 -ltkstub85 -lm

int j = 0;

#if TEA
#include <tcl.h>
#include <tk.h>
#include <math.h>

// Copied from http://wiki.tcl.tk/25685

/*
 ** Scale an image using grid sampling
 ** Please note this implementation will crash if the
 ** destination image was not already created
 */
static int imgScale_Cmd(
		void *pArg,
		Tcl_Interp *interp,
		int objc,
		Tcl_Obj *CONST objv[]
){
	char *srcName, *destName;
	Tk_PhotoImageBlock srcBlock, destBlock;
	Tk_PhotoHandle srcImage, destImage;
	int di, dj;
	double scalex, scaley, sx2, sy2, newalpha;
	//int returnCode;
	int width, height, newwid, newhgt;
	double newdiag, ratio;

	if (objc != 4 && objc != 5) {
		Tcl_WrongNumArgs(interp, 1, objv, "srcimg newdiag destimg ?alpha?");
		return TCL_ERROR;
	}
	srcName = Tcl_GetString(objv[1]);
	if (Tcl_GetDoubleFromObj(interp, objv[2], &newdiag))
		return TCL_ERROR;

	destName=Tcl_GetString(objv[3]);
	if (objc == 6) {
		if (Tcl_GetDoubleFromObj(interp, objv[4], &newalpha))
			return TCL_ERROR;
	} else {
		newalpha=1.0;
	}
	if (newalpha>1.0) {
		newalpha=1.0;
	}

	srcImage = Tk_FindPhoto(interp, srcName);
	if (!srcImage)
		return TCL_ERROR;
	Tk_PhotoGetSize(srcImage, &width, &height);
	Tk_PhotoGetImage(srcImage, &srcBlock);
	if (srcBlock.pixelSize != 4 && srcBlock.pixelSize!=3) {
		Tcl_AppendResult(interp, "I can't make heads or tails from this image, the bitfield is neither 3 nor 4", NULL);
		return TCL_ERROR;
	}


	// calculated diag
	ratio = newdiag/sqrt((double)(pow(width,2)+pow(height,2)));

	newwid = (int) (ratio*width);
	newhgt = (int) (ratio*height);



	destImage = Tk_FindPhoto(interp, destName);
	if (!destImage)
		return TCL_ERROR;
	Tk_PhotoBlank(destImage);
	Tk_PhotoSetSize( interp, destImage, newwid, newhgt);




	destBlock.width = newwid;
	destBlock.height = newhgt;

	scalex = srcBlock.width / (double) newwid;
	scaley = srcBlock.height / (double) newhgt;
	sx2 = scalex / 2.0;
	sy2 = scaley / 2.0;

	destBlock.pixelSize = 4;
	destBlock.pitch = newwid * 4;
	destBlock.offset[0] = 0;
	destBlock.offset[1] = 1;
	destBlock.offset[2] = 2;
	destBlock.offset[3] = 3;
	destBlock.pixelPtr = (unsigned char *) Tcl_Alloc(destBlock.width * destBlock.height * 4);

	/* Loop through and scale */
	for (dj=0 ; dj<destBlock.height ; dj++) {
		for (di=0 ; di<destBlock.width ; di++) {
			int si, sj;
			int cx = (int)(di * scalex);
			int cy = (int)(dj * scaley);
			int points = 1;
			double red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
			int newoff = destBlock.pitch*dj + destBlock.pixelSize*di;
			int startoff = srcBlock.pitch*cy + srcBlock.pixelSize*cx;

			red = (double) srcBlock.pixelPtr[startoff + srcBlock.offset[0]];
			green = (double) srcBlock.pixelPtr[startoff + srcBlock.offset[1]];
			blue = (double) srcBlock.pixelPtr[startoff + srcBlock.offset[2]];
			if (srcBlock.pixelSize == 4) {
				alpha = (double) srcBlock.pixelPtr[startoff + srcBlock.offset[3]];
			} else {
				alpha += 255;
			}
			for (sj=(int)cy-sy2 ; sj<(int)cy+sy2 ; sj++) {
				if (sj < 0)
					continue;
				if (sj > srcBlock.height)
					continue;
				for (si=(int)cx-sx2 ; si<(int)cx+sx2 ; si++) {
					int offset = srcBlock.pitch*sj + srcBlock.pixelSize*si;
					if (si < 0)
						continue;
					if (si > srcBlock.width)
						continue;

					points++;
					red += (double) srcBlock.pixelPtr[offset + srcBlock.offset[0]];
					green += (double) srcBlock.pixelPtr[offset + srcBlock.offset[1]];
					blue += (double) srcBlock.pixelPtr[offset + srcBlock.offset[2]];
					if (srcBlock.pixelSize == 4) {
						alpha += (double) srcBlock.pixelPtr[offset + srcBlock.offset[3]];
					} else {
						alpha += 255;
					}
				}
			}
			destBlock.pixelPtr[newoff + destBlock.offset[0]] = (unsigned char)(red / points);
			destBlock.pixelPtr[newoff + destBlock.offset[1]] = (unsigned char)(green / points);
			destBlock.pixelPtr[newoff + destBlock.offset[2]] = (unsigned char)(blue / points);
			destBlock.pixelPtr[newoff + destBlock.offset[3]] = (unsigned char)(alpha*newalpha / points);
		}
	}

	Tcl_SetObjResult(interp, Tcl_NewStringObj("Hello, World Again!", -1));
	//    returnCode =
	Tk_PhotoPutBlock(interp, destImage, &destBlock, 0, 0,
			destBlock.width, destBlock.height, TK_PHOTO_COMPOSITE_SET);

	return TCL_OK;//   return returnCode;
}


/*
 ** The following is the only public symbol in this source file.  .
 */
int DLLEXPORT Imgscaletea_Init(Tcl_Interp *interp){
	Tcl_CreateObjCommand(interp, "image_scale", imgScale_Cmd, 0, 0);
	return TCL_OK;
}

#endif
