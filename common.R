if (! exists("mread.table")) {mread.table = memoise::memoise(read.table)}
if (! exists("mread.tablegz")) {
  mread.tablegz = memoise::memoise(function(matrix_file, ...) {
    read.table(gzfile(matrix_file), ...)
  })  
}
