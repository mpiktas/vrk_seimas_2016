import dryscrape
session = dryscrape.Session()

fln=open("../link_data/apygardu_linkai.txt","r")
lns=fln.readlines()
fln.close()

for ll in lns: 
    session.visit(ll)
    f=file("apygardos/"+re.sub(".*_rpgId-","",ll).strip(),"w")
    f.write(session.body().encode("utf-8"))
    f.close()
