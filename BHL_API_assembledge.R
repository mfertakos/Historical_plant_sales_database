#Upload files generated by API
#Authors: B. Lopez and M. Fertakos
#NOTE: replace � in this script with the hybrid x symbol
#library(svMisc) for progress function
library(jsonlite)

#Construct API results from Python script
setwd("C:/Users/mfert/OneDrive - University of Massachusetts/Year1/api_cache_BHL_tocomplete") #location of API results
files<-list.files() # this will tell you the names of the species that were searched for (both accepted names and synonyms)
setwd("C:/Users/mfert/OneDrive - University of Massachusetts/Year1/")
existing_files<-read.csv('existingfiles.csv',header=T)
existing_files$filename<-str_replace(existing_files$filename,"�-","�")
existing_files<-as.character(existing_files$filename)
files<-c(files,existing_files)
files<-as.character(files)
# I only want ones with a genus and species (genus too broad)
## so use "grep" to find ones with a space (2 words)

setwd("C:/Users/mfert/OneDrive - University of Massachusetts/Year1/api_cache_BHL")
output1<-matrix(nrow = 3000000, ncol = 16, dimnames = list( c(), # row names (none) #make sure number of rows exceeds your output
                                                            c("Status","SearchText" ,"BaseURL","ResultCount",
                                                              "Result.BHLType","Result.ItemID" ,"Result.TitleID","Result.Volume",
                                                              "Result.ItemUrl","Result.TitleUrl" ,"Result.MaterialType",
                                                              "Result.PublisherPlace","Result.PublicationDate","Result.Authors",
                                                              "Result.Genre","Result.Title" ))) # column names

row<-1 # this is going to be used later to say which row to start filling in on (for the first sp.)

for(i in 1:length(files)){ 
  
  json_file <- fromJSON(files[i], flatten = TRUE)
  
  if(json_file$ResultCount>0){ # only go through this if there are some results
    json_tbl <- as.data.frame(json_file, stringsAsFactors = FALSE)
    json_tbl$Result.Authors <- as.character(lapply(json_tbl$Result.Authors, function(x) toString(unlist(x, use.names = FALSE))))
    # above is the way I figured out of making one column out of the list that was giving us trouble: unlisting and then converting to a character
    nrow <- as.numeric(nrow(json_tbl)) # how many rows in the json file?
    lastrow <- row+nrow-1 # this is the last row to fill in
    
    # I broke this up by column (messy) so I could add "if" statements
    ##  for those that were only in some files-- I figured this out through trial and error
    output1[row:lastrow,1]<-json_tbl$Status
    output1[row:lastrow,2]<-json_tbl$SearchText
    output1[row:lastrow,3]<-json_tbl$BaseURL
    output1[row:lastrow,4]<-json_tbl$ResultCount
    output1[row:lastrow,5]<-json_tbl$Result.BHLType
    output1[row:lastrow,6]<-json_tbl$Result.ItemID
    output1[row:lastrow,7]<-json_tbl$Result.TitleID
    if("Result.Volume"%in%names(json_tbl)){   # missing from some files
      output1[row:lastrow,8]<-json_tbl$Result.Volume}
    output1[row:lastrow,9]<-json_tbl$Result.ItemUrl
    output1[row:lastrow,10]<-json_tbl$Result.TitleUrl
    output1[row:lastrow,11]<-json_tbl$Result.MaterialType
    if("Result.PublisherPlace"%in%names(json_tbl)){   # missing from some files
      output1[row:lastrow,12]<-json_tbl$Result.PublisherPlace}
    if("Result.PublicationDate"%in%names(json_tbl)){   # missing from some files
      output1[row:lastrow,13]<-json_tbl$Result.PublicationDate}
    output1[row:lastrow,14]<-json_tbl$Result.Authors
    output1[row:lastrow,15]<-json_tbl$Result.Genre
    output1[row:lastrow,16]<-json_tbl$Result.Title
    
    row <- lastrow+1  # this updates the row to start filling in on for the next file
  }
  
}
output1<-output1[1:lastrow,]  # clip to the rows that are actually filled in
write.csv(output1, "BHL_results_ofc.csv", row.names = FALSE)
