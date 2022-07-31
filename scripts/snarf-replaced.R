#!/home/freundt/usr/bin/Rscript --vanilla

library(data.table)

args <- commandArgs(trailingOnly=TRUE)

fread(args[[1L]]) -> x

x[, regexpr(" [A-Z]{2}[- ]{0,1}[ ]{0,1}[A-Z]{3}", rem)] -> y
x[, by:=substr(rem, y, y + attr(y, "match.length"))]
x[, by:=gsub("[^A-Z0-9]", "", by)]

fwrite(x, "", col.names=TRUE, sep="\t", quote=FALSE, na="")
