\name{ng_data}
\alias{ng_data}

\title{
  Create an NG_data object to be used by a navGraph session
}

\description{
  NG_data objects wrap the data to be explored and some meta data such
  as the data name, variable short names, the group identifier and
  text labels for each observation.
}
\usage{
ng_data(name, data, shortnames = character(0), group = numeric(0), labels = character(0))
}
%- maybe also 'usage' for other objects documented here.  \arguments{
\arguments{
  \item{name}{
    Character string containing no spaces. Note that for a
    single navGraph session, the names of all the NG_data objects passed by
    to \code{navGraph} must be unique.
  }
  
  \item{data}{
    \code{data.frame} with only numeric variables.
  }
  
  \item{shortnames}{
    If the variable names of the data argument are too long or contain
    spaces, shortnames can be specified.
  }
  
  \item{group}{
    Vector of group identifiers for each observation.

    For the tk2d display, one can use color names (see
    \code{\link{colors}}) to map a certain color directly to the objects.
  }
  
  \item{labels}{
    Factor- or character sting vector with labels for each observation.
  }
}

%\details{}
\value{
  NG_data object.
}
%\references{%% ~put references to the literature/web site here ~}
\author{
  Adrian Waddell and R. Wayne Oldford
}
%\note{%%  ~~further notes~~}

\seealso{
  \code{\link{navGraph}}, \code{\link{shortnames-methods}},
  \code{\link{ng_get-methods}}, \code{\link{ng_set-methods}}
}

\examples{
## minimal example
ng.iris <- ng_data(name = "iris", data = iris[,1:4])
ng.iris ## see output


## full specification
ng.iris <- ng_data(name = "iris", data = iris[,1:4],
		shortnames = c('s.L', 's.W', 'p.L', 'p.W'),
		group = iris$Species,
		labels = substr(iris$Species,1,2))

## see shortnames
shortnames(ng.iris)
## change shortnames
shortnames(ng.iris) <- c("a","b","c","d")
## see variable names
names(ng.iris)
## change variable names
names(ng.iris) <- LETTERS[1:4]

## ng_get
ng_get(ng.iris)
ng_get(ng.iris,"group")

## ng_set
ng_set(ng.iris)
ng_set(ng.iris,"group") <- iris$Species
}

