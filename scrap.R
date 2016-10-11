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

