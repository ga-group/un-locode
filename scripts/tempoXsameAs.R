#!/home/freundt/usr/bin/Rscript --vanilla

library(data.table)

args <- commandArgs(trailingOnly=TRUE)

fread(args[[1L]], header=FALSE, sep="\t", quote=FALSE, col.names=c("s","pf","from")) -> x
fread(args[[2L]], header=FALSE, quote=FALSE, col.names=c("s","ps","news","igno")) -> y

if (y[, .N]) {
	fwrite(merge(x, y, by="s")[, .(news, pf, from)], "", col.names=FALSE, sep="\t", quote=FALSE, na="")
}
