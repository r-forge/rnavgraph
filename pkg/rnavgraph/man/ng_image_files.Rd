\name{ng_image_files}
\alias{ng_image_files}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
  Import color image files (png, jpg, bmp, etc...) into a NG_image object
}
\description{
  NG_image objects are needed to plot images in the tk2d device.

  Supported file types are those supported by the tcl Img extension. If
  your R can not access the Img extension (currently under Windows) you
  can not import such files. However if you know tcl and R well enough,
  you might create your own NG_image object as shown in the images_iris
  demo.
  
  See the "files_aloi" and "images_iris" demos
  (\code{demo(package="RnavGraph")}) for examples.
}
\usage{
ng_image_files(name, paths)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{name}{
        Character string.
}
  \item{paths}{
    A vector of image paths.
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
  NG_image object.
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
  Adrian Waddell and R. Wayne Oldford.
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
    \code{\link{navGraph}}, \code{\link{ng_image_array_gray}}, \code{\link{ng_2d}}
}
\examples{
## See demos and vignette
}
