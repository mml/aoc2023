#!/usr/bin/env Rscript

rflect <- function(m,skip=NULL) {
  halfway <- floor(nrow(m)/2)

  # Starting from the top, go down halfway looking for a reflected neighbor line.
  for (i in 1:halfway) {
    k <- i+1
    # If a reflection of this line appears...
    if (identical(m[i,], m[k,])) {
      above <- k-1
      if (!is.null(skip) && skip == above) {
        # Skip this line if necessary (needed for part2).
        rm(above)
        next
      }
      # ...back out from that point until the edge of the image is reached
      # or we find a non-matching line.
      for (j in i:1) {
        if (! identical(m[j,], m[k,])) {
          rm(above)
          break
        }
        k <- k+1
      }
    }
    if (exists("above")) break
  }

  # This is cut/paste of the above, only marching upward from the bottom.
  # It would be possible to write this using a general function with a
  # "direction" flag, but tweaking any possible off by 1 errors was a lot
  # easier when each one's layed out separately.
  if (!exists("above")) {
    for (i in nrow(m):halfway) {
      k <- i-1
      if (identical(m[i,], m[k,])) {
        above <- k
        if (!is.null(skip) && skip == above) {
          rm(above)
          next
        }
        for (j in i:nrow(m)) {
          if (! identical(m[j,], m[k,])) {
            rm(above)
            break
          }
          k <- k-1
        }
      }
      if (exists("above")) break
    }
  }

  if (exists("above")) {
    above
  } else {
    0 # This works in our case
  }
}

# Return a copy of m with bit i,j flipped.
flip <- function(m,i,j) {
  # 35 is # and 46 is .
  if (m[i,j] == 35) {
    m[i,j] <- 46
  } else {
    m[i,j] <- 35
  }
  m
}

main <- function() {
  # Note that R's file('stdin') acts differently than stdin()
  fstdin = file('stdin', "r")

  tot <- 0
  n <- 0
  repeat {
    line = readLines(fstdin, 1)
    if(length(line) == 0 || nchar(line) == 0) {
      n <- n + 1
      row_score <- rflect(m)
      col_score <- rflect(t(m))
      
      # Hunt through all single bit-flips of m until we find one that produces
      # a new line of reflection.
      for (i in 1:nrow(m)) {
        for (j in 1:ncol(m)) {
          fm = flip(m,i,j)
          score <- rflect(fm, skip=row_score)
          if (score != 0) {
            score <- score * 100
            break
          }
          score <- rflect(t(fm), skip=col_score)
          if (score != 0)
            break
          rm(score)
        }
        if (exists("score")) break
      }
      if (!exists("score")) {
        print(m)
        cat("BUG", n, row_score, col_score, "\n", sep="\t")
      }
      tot <- tot + score
      rm(m)
      if (length(line) == 0) break
      next
    }
    line <- utf8ToInt(line)
    if (exists("m")) {
      m <- rbind(m, line)
    } else {
      m <- rbind(line)
    }
  }
  cat("\n")
  cat(tot, "\n")
}

main()
