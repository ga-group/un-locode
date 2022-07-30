#!/home/freundt/usr/bin/Rscript --vanilla

library(data.table)

args <- commandArgs(trailingOnly=TRUE)
if (!is.na(tmp <- match("--newpred", args))) {
	args <- args[-tmp]
	newp <- args[tmp]
	args <- args[-tmp]
} else {
	newp <- NULL
}

fread(args[[1L]], header=FALSE, sep="\t", quote=FALSE, col.names=c("s",if (is.null(newp)) {"newp"} else {"oldp"},"from")) -> x
fread(args[[2L]], header=FALSE, quote=FALSE, col.names=c("s","ps","news")) -> y

## possibly massage the " ." away in y
y[grepl(" \\.$", news), news:=substr(news, 1L, nchar(news)-2L)]

if (y[, .N]) {
	fwrite(merge(x, y, by="s")[, .(news, newp, from)], "", col.names=FALSE, sep="\t", quote=FALSE, na="")
}
