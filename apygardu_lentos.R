library(dplyr)
library(tidyr)
library(stringr)

apygf <- dir("html_data/apygardos",full.names=TRUE)



get_main_table <- function(x) {
    tb <- x %>% html_nodes("table") %>% html_table(fill = TRUE) 
    tb[[2]]
}

format_main_table <- function(x) {
    hd <- x[1,1:7]
    res<-x[-1,1:7]
    colnames(res)<-hd
    res
}


get_data <- function(x, atag = "h3") {
    ff <- read_html(x, encoding = "utf-8")
    nm <- ff %>% html_nodes(atag)  %>% html_text %>% grep("apygarda",.,value=TRUE) 
    tbs <- ff %>% html_nodes("table") %>% html_table(fill=TRUE)
    names(tbs) <- c("Header","Balsai","Apylinkes")
    c(list(apygarda = nm),tbs)
}

combine_info <- function(x) {
    format_main_table(x$Balsai) %>% mutate(Apygarda = x[["apygarda"]])
}

vapy <- apygf %>% lapply(get_data) 

dtapy <- vapy %>% lapply(combine_info) %>% bind_rows

dt1 <- dtapy %>% filter(Kandidatas != "")

dt2 <- dt1 %>% separate(Apygarda, c("Apygarda", "Numeris"),sep="[(]")  %>% 
    mutate(Numeris=gsub("Nr.","",Numeris)) %>% 
    mutate(Numeris=as.integer(gsub(").*","",Numeris))) %>% 
    arrange(Numeris) %>% rename(Apygardos_numeris = Numeris) %>% 
    mutate(Apygarda = str_trim(Apygarda))

dt2 %>% write.csv2(file="csv_data/Apygardu_rinkimu_rezultatai.csv", row.names= FALSE)


get_apyl_link <- function(x) {
    tbs <- x %>% html_nodes("table")
    tbs[[3]] %>% html_nodes("a") %>% html_attrs() %>%  
        lapply(function(x) {
        names(x) <-NULL
        paste0(link_pref,x)
    }) %>% do.call("c",.)
}

apyll <- apygf %>% lapply(function(x)get_apyl_link(read_html(x, encoding="utf-8"))) %>% 
    do.call("c",.)

writeLines(apyll,"link_data/apylinkiu_linkai.txt")

dmapygf <- dir("html_data/dm_apygardos",full.names=TRUE)

ff <- read_html(dmapygf[1], encoding = "utf-8")

dmvapy <- dmapygf %>% lapply(get_data, atag="h2") 

format_dm_main_table <- function(x,rem=3) {
    hd <- x[1,-rem]
    res<-x[-1,-rem]
    colnames(res)<-hd
    res
}
combine_dm_info <- function(x) {
    format_dm_main_table(x$Balsai) %>% mutate(Apygarda = x[["apygarda"]])
}

dtdmapy <- dmvapy %>% lapply(combine_dm_info) %>% bind_rows

colnames(dtdmapy) <- c("partijos_no","partija","apylinkes","pastas","balsai","proc_rinkejai","proc_rinkejai_lt","apygarda")

dm1 <- dtdmapy %>% filter(partijos_no != "")
pnames2 <- read.csv2("csv_data/partiju_santrumpos2.csv", stringsAsFactors = FALSE)

dm2 <- dm1 %>% separate(apygarda, c("apygarda", "Numeris"),sep="[(]")  %>% 
    mutate(Numeris=gsub("Nr.","",Numeris)) %>% 
    mutate(Numeris=as.integer(gsub(").*","",Numeris))) %>% 
    arrange(Numeris) %>% rename(apygardos_no = Numeris) %>% 
    mutate(apygarda = str_trim(apygarda)) %>% mutate(partijos_no=as.integer(partijos_no)) %>% 
    inner_join(pnames2 %>% select(partijos_no,partija1), by = "partijos_no") %>% 
    rename(partija_full = partija) %>% rename(partija = partija1)

    

dm2 %>% write.csv2(file="csv_data/daugiamandaciu_apygardu_rinkimu_rezultatai.csv", row.names= FALSE)

