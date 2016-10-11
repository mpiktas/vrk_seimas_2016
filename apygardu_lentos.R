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

get_data <- function(x) {
    ff <- read_html(x, encoding = "utf-8")
    nm <- ff %>% html_nodes("h3")  %>% html_text %>% grep("apygarda",.,value=TRUE) 
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

