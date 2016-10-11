library(dplyr)
library(rvest)

ap <- read_html("html_data/apygardos.html",encoding="utf-8")
apl <- ap %>% html_nodes("table") %>% html_nodes("a") %>% html_attrs()

link_pref <- "http://www.vrk.lt/2016-seimo/rezultatai"

apl1 <- apl %>% lapply(function(x) {
    names(x) <-NULL
    paste0(link_pref,x)
}) %>% do.call("c",.)

fn <- apl1 %>% gsub(".*_rpgId-","",.)

writeLines(apl1,"link_data/apygardu_linkai.txt")


dap <- read_html("html_data/dm_apygardos.html", encoding="utf-8")

dapl <- dap %>% html_nodes("table")

dapl1 <- dapl[[3]] %>% html_nodes("a") %>% html_attrs() %>% 
    lapply(function(x) {
    names(x) <-NULL
    paste0(link_pref,x)
}) %>% do.call("c",.)

writeLines(dapl1,"link_data/dm_apygardu_linkai.txt")
