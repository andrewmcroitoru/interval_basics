.libPaths(c("~/R/x86_64-pc-linux-gnu-library/4.4/"));
library(GenomicRanges)

###############################################################################################################
# Generates a random GRanges object
#
# You can use this function to get a random interval list for testing.
# Don't change this function, it's just for you to use while
# you work on the other functions
#' @examples
# gr1 = randomGRanges()
randomGRanges = function(n = 500, max_size = 1e4){
	starts = sample(1:1e7, n)
	sizes = sample(1:max_size, n)
	ends = starts + sizes
	ret = GenomicRanges::GRanges(seqnames="chrX", ranges=IRanges::IRanges(starts,ends))
	return(GenomicRanges::reduce(ret))
}
###############################################################################################################

###############################################################################################################
# Counts overlaps between query and database
#
# This function counts the number of intervals from a 
# database set of intervals that overlap with a single
# query interval. 
#
#' @param query  
#'   Interval to check for overlaps. Should be a list 
#'   object with 'start' and 'end' values.
#' @param database
#'   A data.frame, with rows corresponding to intervals,
#'   with 'starts' and 'ends' as columns.
#' @return
#'   Number of overlaps counted (as a numeric)
#' @examples
#'   query = list(start=50, end=60)
#'   database = data.frame(starts=c(35, 45, 55), ends=c(45, 65, 85))
#'   countOverlapsSimple(query, database)  # returns 2
countOverlapsSimple = function(query, database) {
  # Assumes valid inputs
  # Do we count overlaps with < and >, or with <= and >=???
  database$overlaps_query <- with(database, (
                                    ((query$start >= starts & query$start <= ends) | (query$end >= starts & query$end <= ends)) | 
                                      (query$start <= starts & query$end >= starts)
                                  )) # 2nd condition handles case where query completely encloses the 
  
  return(sum(database$overlaps_query))
}
###############################################################################################################

###############################################################################################################
# Measure the Jaccard similarity between two interval sets
#
# This function calculates the Jaccard Score between two
# given interval sets, provided as GenomicRanges::GRanges 
# objects. The Jaccard score is computed as the intersection
# between the two sets divided by the union of the two sets.
# @param gr1  First GRanges object
# @param gr2  Second GRanges object
# @return The Jaccard score (as numeric)
calculateJaccardScore = function(gr1, gr2){
  return(length(intersect(gr1, gr2)) / length(union(gr1, gr2)))
}
###############################################################################################################

###############################################################################################################
# Calculate pairwise Jaccard similarity among several interval sets
#
# This function makes use of \code{calculateJaccardScore}. It simply
# loops through each pairwise comparison and calculates.
#' Round the result to 3 significant figures using \code{signif}
#' @param lst A base R list of GRanges objects to compare
#' @return
#'   A matrix of size n-by-n, where n is the number of elements in lst.
#' @examples
#' lst = replicate(10, randomGRanges())
#' pairwiseJaccard(lst)
pairwiseJaccard = function(lst) {
	# Implement this function
	# Compute the pairwise Jaccard Score and return in matrix form
	# Return only 3 significant figures
  N <- length(lst)
  Mat <- matrix(NA, nrow = N, ncol = N) # initialize matrix
  # For each pair i, j in the list of ranges, compute the jaccard similarity and save these to Mat[i, j] and Mat[j, i] (symmetrical matrix)
  for(i in 1:N){
    for(j in 1:N){
      if(i == j){
        Mat[i, j] <- 1 # jaccard similarity w/ self if always 1
      } else {
        score <- round(calculateJaccardScore(lst[i][[1]], lst[j][[1]]), 3)
        Mat[i, j] <- score; Mat[j, i] <- score
      }
    }
  }
  
  # For interpretability, set the column and row names of the matrix to the list elt names
  rownames(Mat) <- names(lst); colnames(Mat) <- names(lst)
  return(Mat)
}
###############################################################################################################