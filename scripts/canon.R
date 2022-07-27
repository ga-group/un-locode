#!/home/freundt/usr/bin/Rscript --vanilla

library(data.table)

args <- commandArgs(trailingOnly=TRUE)

rbindlist(lapply(args, fread, fill=TRUE)) -> x

if (!("Change" %in% names(x))) {
	names(x) <- c("Change","Country","Location","Name","NameWoDiacritics","Subdivision","Function","Status","Date","IATA","Coordinates","Remarks")

}

## attempt to expand Date
set(x, j="Date", value=substr(fcoalesce(as.IDate(paste0("0",x$Date,"-01"), format="%y%m-%d"), as.IDate(paste0(x$Date,"-01"), format="%y%m-%d")), 1L, 7L))

fwrite(x, "/dev/stdout", na="", sep="\t", quote=FALSE)
