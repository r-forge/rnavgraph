\name{updateViz}
\alias{updateViz}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
   Method that gets called when bullet state is changed on a graph that is connected with the particular visualization instructions
}
\description{
   See the vignette for more details.
}
\usage{
updateViz(viz,ngEnv)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{viz}{
	Object of class NG_Visualization
}
  \item{ngEnv}{
   Environment of navGraph session.
}
}
%\details{ }
\value{
  Object of NG_Visualization (viz from argument)
}

\author{
Adrian Waddell and Wayne Oldford
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{initializeViz}}, \code{\link{closeViz}}
}
\examples{
## See vignette
}

