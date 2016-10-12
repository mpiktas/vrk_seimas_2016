library(dplyr)
library(tidyr)
library(stringr)

apl_hf <- dir("html_data/apylinkes",full.names=TRUE)

get_apl_data <-  function(x, apytag = "h2", apltag = "h3") {
    ff <- read_html(x, encoding = "utf-8")
    nmapy <- ff %>% html_nodes(apytag)  %>% html_text %>% grep("apygarda",.,value=TRUE) 
    nmapl <- ff %>% html_nodes(apltag)  %>% html_text %>% grep("apyl",.,value=TRUE) 
    tbs <- ff %>% html_nodes("table") %>% html_table(fill=TRUE)
   
    list(apygarda = nmapy, apylinke = nmapl, balsai = tbs[[2]])
}

format_apl_table <- function(x) {
    hd <- x[1,]
    res<-x[-1,]
    colnames(res)<-hd
    res
}

combine_apl_info <- function(x) {
    format_apl_table(x$balsai) %>% mutate(Apygarda = str_trim(x[["apygarda"]]), Apylinke = str_trim(x[["apylinke"]]))
}

apyl_data <- apl_hf %>% lapply(function(x)try(get_apl_data(x)))

nera_apyl <- which(sapply(apyl_data,class) != "list")

apyl_data1 <- apyl_data[-c(nera_apyl)]



uzsienis <- which(lapply(apyl_data1,"[[","apygarda") %>% sapply(function(x)length(x)==0))

apyl_data2 <- apyl_data1[-uzsienis]

apyl_tb <-  apyl_data2 %>% lapply(combine_apl_info) %>% bind_rows

colnames(apyl_tb) <- c("kandidatas","partija", "balsadeze", "pastas", "balsai", "proc_galiojantis","proc_rinkejai","proc_apygarda","Apygarda","Apylinke")

apyl_tb1 <- apyl_tb %>% filter(kandidatas != "") %>% 
    separate(Apygarda, c("apygarda", "Numeris"),sep="[(]")  %>% 
    mutate(Numeris=gsub("Nr.","",Numeris)) %>% 
    mutate(Numeris=as.integer(gsub(").*","",Numeris))) %>% 
    arrange(Numeris) %>% rename(apygardos_no = Numeris) %>% 
    separate(Apylinke, c("apylinke", "Numeris"),sep="[(]")  %>% 
    mutate(Numeris=gsub("Nr.","",Numeris)) %>% 
    mutate(Numeris=as.integer(gsub(").*","",Numeris))) %>% 
    arrange(Numeris) %>% rename(apylinkes_no = Numeris) %>% 
    mutate(apygarda = str_trim(apygarda)) %>% 
    mutate(apylinke = str_trim(apylinke))

apyl_tb1 %>% write.csv2("csv_data/")
# apyl_tb2 <- apyl_tb1 %>% 
#     inner_join(pnames2 %>% select(partija,partija1), by = "partija") %>% 
#     rename(partija_full = partija) %>% rename(partija = partija1)


