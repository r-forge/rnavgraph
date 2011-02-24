\name{ng_image_array_gray}
\alias{ng_image_array_gray}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  Convert a matrix or data.frame of image data into a NG_image object.
}
\description{
  NG_image objects are needed to plot images in the tk2d device.

  \code{ng_image_array_gray} imports gray scale images that are saved in
  a matrix structure, that is every row or column contains the pixel
  data of an image.

  See the "alpha_letter", "digits", "faces", "frey" and "umist_faces"
  demos (\code{demo(package="RnavGraph")}) for examples.
}
\usage{
ng_image_array_gray(name, imageData,
                    width, height,
                    img_in_row = TRUE, invert = FALSE,
                    rotate = 0)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{name}{
    Character string.
}
  \item{imageData}{
    data.frame of matrix with image data. Image information must be
    stored as a gray scale value (0-255) within a single row or column.
}
  \item{width}{
    Pixel width of image.
}
  \item{height}{
        Pixel height of image.
}
  \item{img_in_row}{
    Logical. Single image stored in a row or column in \code{imageData}.
}
  \item{invert}{
    For \code{invert=FALSE} 0 = whit, for \code{invert=TRUE} 0=black.
}
  \item{rotate}{
    Rotate the image: 0, 90, 180 or 270 degree.
  }
}
\details{
  %%  ~~ If necessary, more details than the description above ~~
}
\value{
  NG_image object
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
  Adrian Waddell and R. Wayne oldford
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
  \code{\link{navGraph}}, \code{\link{ng_image_files}}, \code{\link{ng_2d}}
}
\examples{
Img <- matrix(c(0,0,0,255,255,255,
                0,0,0,255,255,255,
                0,0,0,255,255,255,
                255,255,255,0,0,0,
                255,255,255,0,0,0,
                255,255,255,0,0,0),
              byrow = TRUE, ncol=6)

ng.img <- ng_image_array_gray("Test",
                cbind(as.vector(Img),as.vector(Img)),6,6,FALSE)
\donttest{ng.img}

## See demos and vignette
}

