#!/usr/bin/env Rscript

rflect <- function(m) {
  halfway <- floor(nrow(m)/2)

  for (i in 1:halfway) {
    k <- i+1
    if (identical(m[i,], m[k,])) {
      above <- k-1
      #print(sprintf("above is %d", above))
      for (j in i:1) {
        #print(sprintf("%d <> %d", j,k))
        if (! identical(m[j,], m[k,])) {
          #print(sprintf("rm(above)"))
          #print(sprintf("because m[%,d] '%s' != m[%,d] '%s'", j, m[j,], k, m[k,]))
          rm(above)
          break
        }
        k <- k+1
      }
    }
    if (exists("above")) break
  }

  if (!exists("above")) {
    for (i in nrow(m):halfway) {
      k <- i-1
      if (identical(m[i,], m[k,])) {
        above <- k
        #print(sprintf("above is %d", above))
        for (j in i:nrow(m)) {
          if (! identical(m[j,], m[k,])) {
            #print(sprintf("rm(above)"))
            #print(sprintf("because m[%,d] '%s' != m[%,d] '%s'", j, m[j,], k, m[k,]))
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

main <- function() {
  fstdin = file('stdin', "r")

  tot <- 0
  n <- 0
  repeat {
    line = readLines(fstdin, 1)
    if(length(line) == 0 || nchar(line) == 0) {
      n <- n + 1
      rowsAbove <- rflect(m)
      colsAbove <- rflect(t(m))
      cat(sprintf("%03d: %3d x %3d -> 100*%d+%d\t",
                  n, nrow(m), ncol(m), rowsAbove, colsAbove))
      if (n%%6 == 0) {
        cat("\n")
      }
      tot <- tot + 100 * rowsAbove + colsAbove
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
