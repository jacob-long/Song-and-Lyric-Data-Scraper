bluesalbs <- read.csv("bluesalbs.csv")
bluesalbs$genre = "blues"

christian <- read.csv("christian.csv")
christian$genre = "christian"

christianalbs <- read.csv("christianalbs.csv")
christianalbs$genre = "christian"

country <- read.csv("country.csv")
country$genre = "country"

countryalbs <- read.csv("countryalbs.csv")
countryalbs$genre = "country"

dance <- read.csv("dance.csv")
dance$genre = "dance"

dancealbs <- read.csv("dancealbs.csv")
dancealbs$genre = "dance"

jazzalbs <- read.csv("jazzalbs.csv")
jazzalbs$genre = "jazz"

pop <- read.csv("pop.csv")
pop$genre = "pop"

rap <- read.csv("rap.csv")
rap$genre = "rap"

rapalbs <- read.csv("rapalbs.csv")
rapalbs$genre = "rap"

rbhiphop <- read.csv("rbhiphop.csv")
rbhiphop$genre = "rbhiphop"

rbhiphopalbs <- read.csv("rbhiphopalbs.csv")
rbhiphopalbs$genre = "rbhiphop"

reggaealbs <- read.csv("reggaealbs.csv")
reggaealbs$genre = "reggae"

rock <- read.csv("rock.csv")
rock$genre = "rock"

rockalbs <- read.csv("rockalbs.csv")
rockalbs$genre = "rock"

library(quanteda)

allsingles <- rbind(christian, country, dance, pop, rap, rbhiphop, rock)
ridof <- names(allsingles) %in% c("songtitle.1","song_id")
allsingles1 <- allsingles[!ridof]
allalbs <- rbind(christianalbs,countryalbs,dancealbs,rapalbs,rbhiphopalbs,rockalbs,reggaealbs,bluesalbs,jazzalbs)
ridof2 <- names(allalbs) %in% c("albumtitle","album_id.1")
allalbs <- allalbs[!ridof2]
all <- rbind(allsingles1,allalbs)

# Setting SQLite nulls to missing
all$lyrics_w[all$lyrics_w=="<null>"] <- NA
all$lyrics_ml[all$lyrics_ml=="<null>"] <- NA

all$lyrics_w <- as.character(all$lyrics_w)
all$lyrics_ml <- as.character(all$lyrics_ml)

# Setting up a single variable for lyrics, prioritizing ML over W
all$lyrics[!is.na(all$lyrics_ml)] <- all$lyrics_ml[!is.na(all$lyrics_ml)]
all$lyrics[is.na(all$lyrics_ml) && !is.na(all$lyrics_w)] <- all$lyrics_w[is.na(all$lyrics_ml) && !is.na(all$lyrics_w)]


# Import MFT dictionary from MoralFoundations.org (code is from Quanteda readme)
mftdict <- dictionary(file = "LIWCmodifiedic.dic", format = "LIWC")

# Create a Quanteda corpus
mycorpus <- corpus(all$lyrics)
# Adding existing variables to corpus
docvars(mycorpus, "genre") <- all$genre
docvars(mycorpus, "BBgenre") <- all$genre_bb
docvars(mycorpus, "artist") <- all$artist
docvars(mycorpus, "songtitle") <- all$songtitle
docvars(mycorpus, "song_ID") <- all$song_id
docvars(mycorpus, "album_ID") <- all$album_id
docvars(mycorpus, "valence") <- all$valence
docvars(mycorpus, "energy") <- all$energy
docvars(mycorpus, "loudness") <- all$loudness
docvars(mycorpus, "tempo") <- all$tempo
docvars(mycorpus, "week") <- all$week
docvars(mycorpus, "year") <- all$year
docvars(mycorpus, "date") <- all$date2

mydfm <- dfm(mycorpus, dictionary = mftdict, ignoredFeatures = stopwords("english"), groups= c("genre","year"))

test <- as.data.frame(mydfm)
write.csv(file="dfm.csv", x=test)

mydfm2 <- dfm(mycorpus, dictionary = mftdict, ignoredFeatures = stopwords("english"))

test6 <- as.data.frame(mydfm2)
write.csv(file="dfm2.csv", x=test6)
# ex post facto
test6 <- read.csv("dfm2.csv")

test2 <- summary(mycorpus, n=1275166)
test3 <- cbind(test6,test2)
test3[1:72] <- test3[1:72]/test3$Tokens
write.csv(file="test3.csv", x=test3)
# ex post facto
test3 <- read.csv("test3.csv")

library(psych)
library(Hmisc)
library(ggplot2)

test3$purity <- test3$PurityVice + test3$PurityVirtue
test3$authority <- test3$AuthorityVice + test3$AuthorityVirtue
test3$ingroup <- test3$IngroupVice + test3$IngroupVirtue
test3$fairness <- test3$FairnessVice + test3$FairnessVirtue
test3$harm <- test3$HarmVice + test3$HarmVirtue
test3$totmoral <- test3$purity + test3$authority + test3$ingroup + test3$fairness + test3$harm
test3$purityper <- test3$purity/test3$totmoral
test3$authorityper <- test3$authority/test3$totmoral
test3$ingroupper <- test3$ingroup/test3$totmoral
test3$fairnessper <- test3$fairness/test3$totmoral
test3$harmper <- test3$harm/test3$totmoral

# Getting rid of some extraneous variables
test4 <- subset(test3, select=c(genre,year,politic,HarmVice,HarmVirtue,FairnessVice,FairnessVirtue,IngroupVice,IngroupVirtue,AuthorityVice,AuthorityVirtue,PurityVice,PurityVirtue))
summary <- aggregate(test4, data=test4, by=list(genre1=test4$genre,year1=test4$year), FUN = "mean", na.rm=TRUE)
# Combining MFT vice/virtue
summary$purity <- summary$PurityVice + summary$PurityVirtue
summary$authority <- summary$AuthorityVice + summary$AuthorityVirtue
summary$ingroup <- summary$IngroupVice + summary$IngroupVirtue
summary$fairness <- summary$FairnessVice + summary$FairnessVirtue
summary$harm <- summary$HarmVice + summary$HarmVirtue
summary$totmoral <- summary$purity + summary$authority + summary$ingroup + summary$fairness + summary$harm
summary$purityper <- summary$purity/summary$totmoral
summary$authorityper <- summary$authority/summary$totmoral
summary$ingroupper <- summary$ingroup/summary$totmoral
summary$fairnessper <- summary$fairness/summary$totmoral
summary$harmper <- summary$harm/summary$totmoral
# Getting rid of the holdover vice/virtue variables
ridofme <- names(summary) %in% c("year", "genre","PurityVice","PurityVirtue","AuthorityVice","AuthorityVirtue","IngroupVice","IngroupVirtue","FairnessVice","FairnessVirtue","HarmVice","HarmVirtue")
summary1 <- summary[!ridofme]

summary1 <- transform(summary1, purity.rank = ave(purity, year1, FUN = function(x) rank(-x, ties.method = "first")))
summary1 <- transform(summary1, authority.rank = ave(authority, year1, FUN = function(x) rank(-x, ties.method = "first")))
summary1 <- transform(summary1, ingroup.rank = ave(ingroup, year1, FUN = function(x) rank(-x, ties.method = "first")))
summary1 <- transform(summary1, fairness.rank = ave(fairness, year1, FUN = function(x) rank(-x, ties.method = "first")))
summary1 <- transform(summary1, harm.rank = ave(harm, year1, FUN = function(x) rank(-x, ties.method = "first")))
summary1 <- transform(summary1, politic.rank = ave(politic, year1, FUN = function(x) rank(-x, ties.method = "first")))

summary1 <- transform(summary1, purityper.rank = ave(purityper, year1, FUN = function(x) rank(-x, ties.method = "first")))
summary1 <- transform(summary1, authorityper.rank = ave(authorityper, year1, FUN = function(x) rank(-x, ties.method = "first")))
summary1 <- transform(summary1, ingroupper.rank = ave(ingroupper, year1, FUN = function(x) rank(-x, ties.method = "first")))
summary1 <- transform(summary1, fairnessper.rank = ave(fairnessper, year1, FUN = function(x) rank(-x, ties.method = "first")))
summary1 <- transform(summary1, harmper.rank = ave(harmper, year1, FUN = function(x) rank(-x, ties.method = "first")))

write.csv(file="summary1.csv", summary)

statsBy(summary1, c("genre1"), cors=TRUE, method="spearman", na.rm=TRUE)
ggplot(summary1, aes(summary1$year1,summary1$purity.rank, group=summary1$genre1, color=summary1$genre1)) + geom_line() + geom_point()

summary2 <- subset(summary1[names(summary1) %in% c("genre1", "year1", "harm.rank","purity.rank","authority.rank","ingroup.rank","fairness.rank", "politic.rank")],summary1$year1>1999)

statsBy(summary2, c("genre1"), method="pearson", na.rm=TRUE)
ICC(summary2)

ggplot(summary2, aes(summary2$year1,summary2$authority, group=summary2$genre1, color=summary2$genre1)) + geom_line() + geom_point(aes(shape=summary2$genre1))

ggplot(summary2, aes(summary2$year1,summary2$harmper, group=summary2$genre1, color=summary2$genre1)) + geom_line() + geom_point(aes(shape=summary2$genre1))

library(dplyr)
library(tidyr)

summary3 <- subset(summary1[names(summary1) %in% c("genre1", "year1", "harm.rank","purity.rank","authority.rank","ingroup.rank","fairness.rank", "politic.rank")], summary1$year>2009)
summary4 <- subset(summary1[names(summary1) %in% c("genre1", "year1", "harm.rank","purity.rank","authority.rank","ingroup.rank","fairness.rank", "politic.rank", "politic")], summary1$year>2009)
fivesum <- aggregate(summary3, by=list(summary3$genre1), FUN=mean)
fivesum$id <- fivesum$Group.1
tensum <- aggregate(summary2, by=list(summary2$genre1), FUN=mean)
tensum$id <- tensum$Group.1

summary3.grouped <- group_by(summary3, genre1) 
summary2.grouped <- group_by(summary2, genre1) 

puritysumfive <- summarise(summary3.grouped, purrank = mean(purity.rank))
arrange(puritysumfive, desc(purrank),genre1)
puritysumten <- summarise(summary2.grouped, purrank = mean(purity.rank))
arrange(puritysumten, desc(purrank),genre1)

authoritysumfive <- summarise(summary3.grouped, purrank = mean(authority.rank))
arrange(authoritysumfive, desc(purrank),genre1)
authoritysumten <- summarise(summary2.grouped, purrank = mean(authority.rank))
arrange(authoritysumten, desc(purrank),genre1)

ingroupsumfive <- summarise(summary3.grouped, purrank = mean(ingroup.rank))
arrange(ingroupsumfive, desc(purrank),genre1)
ingroupsumten <- summarise(summary2.grouped, purrank = mean(ingroup.rank))
arrange(ingroupsumten, desc(purrank),genre1)

harmsumfive <- summarise(summary3.grouped, purrank = mean(harm.rank))
arrange(harmsumfive, desc(purrank),genre1)
harmsumten <- summarise(summary2.grouped, purrank = mean(harm.rank))
arrange(harmsumten, desc(purrank),genre1)

library(reshape)
summary2m <- melt(summary2, id = c("genre1","year1"))
summary2m2 <- cast(summary2m, ... ~ year1)

t.test(test3$authority[test3$BBgenre=="christian-songs"],test3$authority[test3$BBgenre=="christian-albums"])
t.test(test3$authority[test3$BBgenre=="rock-songs"],test3$authority[test3$BBgenre=="rock-albums"])
t.test(test3$authority[test3$BBgenre=="country-songs"],test3$authority[test3$BBgenre=="country-albums"])
t.test(test3$authority[test3$BBgenre=="dance-electronic-songs"],test3$authority[test3$BBgenre=="dance-electronic-albums"])
t.test(test3$authority[test3$BBgenre=="rap-song"],test3$authority[test3$BBgenre=="rap-albums"])
t.test(test3$authority[test3$BBgenre=="r-b-hip-hop-songs"],test3$authority[test3$BBgenre=="r-b-hip-hop-albums"])

t.test(test3$purity[test3$BBgenre=="christian-songs"],test3$purity[test3$BBgenre=="christian-albums"])
t.test(test3$purity[test3$BBgenre=="rock-songs"],test3$purity[test3$BBgenre=="rock-albums"])
t.test(test3$purity[test3$BBgenre=="country-songs"],test3$purity[test3$BBgenre=="country-albums"])
t.test(test3$purity[test3$BBgenre=="dance-electronic-songs"],test3$purity[test3$BBgenre=="dance-electronic-albums"])
t.test(test3$purity[test3$BBgenre=="rap-song"],test3$purity[test3$BBgenre=="rap-albums"])
t.test(test3$purity[test3$BBgenre=="r-b-hip-hop-songs"],test3$purity[test3$BBgenre=="r-b-hip-hop-albums"])

t.test(test3$ingroup[test3$BBgenre=="christian-songs"],test3$ingroup[test3$BBgenre=="christian-albums"])
t.test(test3$ingroup[test3$BBgenre=="rock-songs"],test3$ingroup[test3$BBgenre=="rock-albums"])
t.test(test3$ingroup[test3$BBgenre=="country-songs"],test3$ingroup[test3$BBgenre=="country-albums"])
t.test(test3$ingroup[test3$BBgenre=="dance-electronic-songs"],test3$ingroup[test3$BBgenre=="dance-electronic-albums"])
t.test(test3$ingroup[test3$BBgenre=="rap-song"],test3$ingroup[test3$BBgenre=="rap-albums"])
t.test(test3$ingroup[test3$BBgenre=="r-b-hip-hop-songs"],test3$ingroup[test3$BBgenre=="r-b-hip-hop-albums"])

t.test(test3$harm[test3$BBgenre=="christian-songs"],test3$harm[test3$BBgenre=="christian-albums"])
t.test(test3$harm[test3$BBgenre=="rock-songs"],test3$harm[test3$BBgenre=="rock-albums"])
t.test(test3$harm[test3$BBgenre=="country-songs"],test3$harm[test3$BBgenre=="country-albums"])
t.test(test3$harm[test3$BBgenre=="dance-electronic-songs"],test3$harm[test3$BBgenre=="dance-electronic-albums"])
t.test(test3$harm[test3$BBgenre=="rap-song"],test3$harm[test3$BBgenre=="rap-albums"])
t.test(test3$harm[test3$BBgenre=="r-b-hip-hop-songs"],test3$harm[test3$BBgenre=="r-b-hip-hop-albums"])

t.test(test3$politic[test3$BBgenre=="christian-songs"],test3$politic[test3$BBgenre=="christian-albums"])
t.test(test3$politic[test3$BBgenre=="rock-songs"],test3$politic[test3$BBgenre=="rock-albums"])
t.test(test3$politic[test3$BBgenre=="country-songs"],test3$politic[test3$BBgenre=="country-albums"])
t.test(test3$politic[test3$BBgenre=="dance-electronic-songs"],test3$politic[test3$BBgenre=="dance-electronic-albums"])
t.test(test3$politic[test3$BBgenre=="rap-song"],test3$politic[test3$BBgenre=="rap-albums"])
t.test(test3$politic[test3$BBgenre=="r-b-hip-hop-songs"],test3$politic[test3$BBgenre=="r-b-hip-hop-albums"])

t.test(test3$totmoral[test3$BBgenre=="christian-songs"],test3$totmoral[test3$BBgenre=="christian-albums"])
t.test(test3$totmoral[test3$BBgenre=="rock-songs"],test3$totmoral[test3$BBgenre=="rock-albums"])
t.test(test3$totmoral[test3$BBgenre=="country-songs"],test3$totmoral[test3$BBgenre=="country-albums"])
t.test(test3$totmoral[test3$BBgenre=="dance-electronic-songs"],test3$totmoral[test3$BBgenre=="dance-electronic-albums"])
t.test(test3$totmoral[test3$BBgenre=="rap-song"],test3$totmoral[test3$BBgenre=="rap-albums"])
t.test(test3$totmoral[test3$BBgenre=="r-b-hip-hop-songs"],test3$totmoral[test3$BBgenre=="r-b-hip-hop-albums"])

t.test(test3$totmoral[test3$BBgenre %in% c("christian-songs","rock-songs","country-songs","dance-electronic-songs","rap-song","r-b-hip-hop-songs")],test3$totmoral[test3$BBgenre %in% c("christian-albums","rock-albums","country-albums","dance-electronic-albums","rap-albums","r-b-hip-hop-albums")])
t.test(test3$purity[test3$BBgenre %in% c("christian-songs","rock-songs","country-songs","dance-electronic-songs","rap-song","r-b-hip-hop-songs")],test3$purity[test3$BBgenre %in% c("christian-albums","rock-albums","country-albums","dance-electronic-albums","rap-albums","r-b-hip-hop-albums")])
ct.test(test3$authority[test3$BBgenre %in% c("christian-songs","rock-songs","country-songs","dance-electronic-songs","rap-song","r-b-hip-hop-songs")],test3$authority[test3$BBgenre %in% c("christian-albums","rock-albums","country-albums","dance-electronic-albums","rap-albums","r-b-hip-hop-albums")])
t.test(test3$ingroup[test3$BBgenre %in% c("christian-songs","rock-songs","country-songs","dance-electronic-songs","rap-song","r-b-hip-hop-songs")],test3$ingroup[test3$BBgenre %in% c("christian-albums","rock-albums","country-albums","dance-electronic-albums","rap-albums","r-b-hip-hop-albums")])
t.test(test3$harm[test3$BBgenre %in% c("christian-songs","rock-songs","country-songs","dance-electronic-songs","rap-song","r-b-hip-hop-songs")],test3$harm[test3$BBgenre %in% c("christian-albums","rock-albums","country-albums","dance-electronic-albums","rap-albums","r-b-hip-hop-albums")])
t.test(test3$politic[test3$BBgenre %in% c("christian-songs","rock-songs","country-songs","dance-electronic-songs","rap-song","r-b-hip-hop-songs")],test3$politic[test3$BBgenre %in% c("christian-albums","rock-albums","country-albums","dance-electronic-albums","rap-albums","r-b-hip-hop-albums")])

bluespmean <- mean(summary4$politic[summary4$genre=="blues"])
christianpmean <- mean(summary4$politic[summary4$genre=="christian"])
countrypmean <- mean(summary4$politic[summary4$genre=="country"])
dancepmean <- mean(summary4$politic[summary4$genre=="dance"])
jazzpmean <- mean(summary4$politic[summary4$genre=="jazz"])
poppmean <- mean(summary4$politic[summary4$genre=="pop"])
reggaepmean <- mean(summary4$politic[summary4$genre=="reggae"])
rbhiphoppmean <- mean(summary4$politic[summary4$genre=="rbhiphop"])
rappmean <- mean(summary4$politic[summary4$genre=="rap"])
rockpmean <- mean(summary4$politic[summary4$genre=="rock"])

cor.test(surveydata3$lyricpolZ, surveydata3$lyricauthZ)
cor.test(test3$politic, test3$authority)

cor.test(surveydata3$lyricpolZ, surveydata3$lyricpurityZ)
cor.test(test3$politic, test3$purity)

cor.test(surveydata3$lyricpolZ, surveydata3$lyricharmZ)
cor.test(test3$politic, test3$harm)

cor.test(surveydata3$lyricpolZ, surveydata3$lyricingZ)
cor.test(test3$politic, test3$ingroup)



