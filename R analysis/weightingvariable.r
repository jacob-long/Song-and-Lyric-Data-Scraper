# Added polvec on 2/29/16

surveydata$id <- row.names(surveydata);

for (x in 1:nrow(surveydata)) {
  
  harmvec <- c();
  fairvec <- c();
  ingvec <- c();
  authvec <- c();
  purityvec <- c();
  progvec <- c();
  negvec <- c();
  posvec <- c();
  religvec <- c();
  polvec <- c();
  
  weightvec <- c();
  
  if (surveydata$like_Pop[surveydata$id==x] > 3 & surveydata$like_Pop[surveydata$id==x] < 6) {
    harmvec <- c(harmvec, genremeans$HarmZ2[genremeans$genre=="pop"]);
    fairvec <- c(fairvec, genremeans$FairZ2[genremeans$genre=="pop"]);
    ingvec <- c(ingvec, genremeans$IngZ2[genremeans$genre=="pop"]);
    authvec <- c(authvec, genremeans$AuthZ2[genremeans$genre=="pop"]);
    purityvec <- c(purityvec, genremeans$PurityZ2[genremeans$genre=="pop"]);
    negvec <- c(negvec, genremeans$negemo[genremeans$genre=="pop"]);
    posvec <- c(posvec, genremeans$posemo[genremeans$genre=="pop"]);
    religvec <- c(religvec, genremeans$relig[genremeans$genre=="pop"]);
    progvec <- c(progvec, genremeans$ProgressivismTotal[genremeans$genre=="pop"]);
    polvec <- c(polvec, joinedmeans$politic[joinedmeans$genre=="pop"]);
    
    if (surveydata$listen_Pop[surveydata$id==x] == 3) weightvec <- c(weightvec, 1);
    if (surveydata$listen_Pop[surveydata$id==x] == 4) weightvec <- c(weightvec, 2);
    if (surveydata$listen_Pop[surveydata$id==x] == 5) weightvec <- c(weightvec, 4);
    if (surveydata$listen_Pop[surveydata$id==x] < 3 | surveydata$listen_Pop[surveydata$id==x] > 5) weightvec <- c(weightvec, 0);
    
    if (surveydata$listen_Pop[surveydata$id==x] < 3 | surveydata$listen_Pop[surveydata$id==x] > 5) surveydata$Popfan[surveydata$id==x] <- 0
    else surveydata$Popfan[surveydata$id==x] <- 1;
    
  };
  
  if (surveydata$like_Country[surveydata$id==x] > 3 & surveydata$like_Country[surveydata$id==x] < 6) {
    harmvec <- c(harmvec, genremeans$HarmZ2[genremeans$genre=="country"]);
    fairvec <- c(fairvec, genremeans$FairZ2[genremeans$genre=="country"]);
    ingvec <- c(ingvec, genremeans$IngZ2[genremeans$genre=="country"]);
    authvec <- c(authvec, genremeans$AuthZ2[genremeans$genre=="country"]);
    purityvec <- c(purityvec, genremeans$PurityZ2[genremeans$genre=="country"]);
    negvec <- c(negvec, genremeans$negemo[genremeans$genre=="country"]);
    posvec <- c(posvec, genremeans$posemo[genremeans$genre=="country"]);
    religvec <- c(religvec, genremeans$relig[genremeans$genre=="country"]);
    progvec <- c(progvec, genremeans$ProgressivismTotal[genremeans$genre=="country"]);
    polvec <- c(polvec, joinedmeans$politic[joinedmeans$genre=="country"]);
    
    if (surveydata$listen_Country[surveydata$id==x] == 3) weightvec <- c(weightvec, 1);
    if (surveydata$listen_Country[surveydata$id==x] == 4) weightvec <- c(weightvec, 2);
    if (surveydata$listen_Country[surveydata$id==x] == 5) weightvec <- c(weightvec, 4);
    if (surveydata$listen_Country[surveydata$id==x] < 3 | surveydata$listen_Country[surveydata$id==x] > 5) weightvec <- c(weightvec, 0);
    
    if (surveydata$listen_Country[surveydata$id==x] < 3 | surveydata$listen_Country[surveydata$id==x] > 5) surveydata$Countryfan[surveydata$id==x] <- 0
    else surveydata$Countryfan[surveydata$id==x] <- 1;
  };
  
  if (surveydata$like_Rock[surveydata$id==x] > 3 & surveydata$like_Rock[surveydata$id==x] < 6) {
    harmvec <- c(harmvec, genremeans$HarmZ2[genremeans$genre=="rock"]);
    fairvec <- c(fairvec, genremeans$FairZ2[genremeans$genre=="rock"]);
    ingvec <- c(ingvec, genremeans$IngZ2[genremeans$genre=="rock"]);
    authvec <- c(authvec, genremeans$AuthZ2[genremeans$genre=="rock"]);
    purityvec <- c(purityvec, genremeans$PurityZ2[genremeans$genre=="rock"]);
    negvec <- c(negvec, genremeans$negemo[genremeans$genre=="rock"]);
    posvec <- c(posvec, genremeans$posemo[genremeans$genre=="rock"]);
    religvec <- c(religvec, genremeans$relig[genremeans$genre=="rock"]);
    progvec <- c(progvec, genremeans$ProgressivismTotal[genremeans$genre=="rock"]);
    polvec <- c(polvec, joinedmeans$politic[joinedmeans$genre=="rock"]);
    
    if (surveydata$listen_Rock[surveydata$id==x] == 3) weightvec <- c(weightvec, 1);
    if (surveydata$listen_Rock[surveydata$id==x] == 4) weightvec <- c(weightvec, 2);
    if (surveydata$listen_Rock[surveydata$id==x] == 5) weightvec <- c(weightvec, 4);
    if (surveydata$listen_Rock[surveydata$id==x] < 3 | surveydata$listen_Rock[surveydata$id==x] > 5) weightvec <- c(weightvec, 0);
    if (surveydata$listen_Rock[surveydata$id==x] < 3 | surveydata$listen_Rock[surveydata$id==x] > 5) surveydata$Rockfan[surveydata$id==x] <- 0
    else surveydata$Rockfan[surveydata$id==x] <- 1;
  };
  
  
  if (surveydata$like_R_n_B[surveydata$id==x] > 3 & surveydata$like_R_n_B[surveydata$id==x] < 6) {
    harmvec <- c(harmvec, genremeans$HarmZ2[genremeans$genre=="rbhiphop"]);
    fairvec <- c(fairvec, genremeans$FairZ2[genremeans$genre=="rbhiphop"]);
    ingvec <- c(ingvec, genremeans$IngZ2[genremeans$genre=="rbhiphop"]);
    authvec <- c(authvec, genremeans$AuthZ2[genremeans$genre=="rbhiphop"]);
    purityvec <- c(purityvec, genremeans$PurityZ2[genremeans$genre=="rbhiphop"]);
    negvec <- c(negvec, genremeans$negemo[genremeans$genre=="rbhiphop"]);
    posvec <- c(posvec, genremeans$posemo[genremeans$genre=="rbhiphop"]);
    religvec <- c(religvec, genremeans$relig[genremeans$genre=="rbhiphop"]);
    progvec <- c(progvec, genremeans$ProgressivismTotal[genremeans$genre=="rbhiphop"]);
    polvec <- c(polvec, joinedmeans$politic[joinedmeans$genre=="rbhiphop"]);
    
    if (surveydata$listen_R_n_B[surveydata$id==x] == 3) weightvec <- c(weightvec, 1);
    if (surveydata$listen_R_n_B[surveydata$id==x] == 4) weightvec <- c(weightvec, 2);
    if (surveydata$listen_R_n_B[surveydata$id==x] == 5) weightvec <- c(weightvec, 4);
    if (surveydata$listen_R_n_B[surveydata$id==x] < 3 | surveydata$listen_R_n_B[surveydata$id==x] > 5) weightvec <- c(weightvec, 0);
    if (surveydata$listen_R_n_B[surveydata$id==x] < 3 | surveydata$listen_R_n_B[surveydata$id==x] > 5) surveydata$Rbfan[surveydata$id==x] <- 0
    else surveydata$Rbfan[surveydata$id==x] <- 1;
  };
  
  if (surveydata$like_Rap[surveydata$id==x] > 3 & surveydata$like_Rap[surveydata$id==x] < 6) {
    harmvec <- c(harmvec, genremeans$HarmZ2[genremeans$genre=="rap"]);
    fairvec <- c(fairvec, genremeans$FairZ2[genremeans$genre=="rap"]);
    ingvec <- c(ingvec, genremeans$IngZ2[genremeans$genre=="rap"]);
    authvec <- c(authvec, genremeans$AuthZ2[genremeans$genre=="rap"]);
    purityvec <- c(purityvec, genremeans$PurityZ2[genremeans$genre=="rap"]);
    negvec <- c(negvec, genremeans$negemo[genremeans$genre=="rap"]);
    posvec <- c(posvec, genremeans$posemo[genremeans$genre=="rap"]);
    religvec <- c(religvec, genremeans$relig[genremeans$genre=="rap"]);
    progvec <- c(progvec, genremeans$ProgressivismTotal[genremeans$genre=="rap"]);
    polvec <- c(polvec, joinedmeans$politic[joinedmeans$genre=="rap"]);
    
    if (surveydata$listen_Rap[surveydata$id==x] == 3) weightvec <- c(weightvec, 1);
    if (surveydata$listen_Rap[surveydata$id==x] == 4) weightvec <- c(weightvec, 2);
    if (surveydata$listen_Rap[surveydata$id==x] == 5) weightvec <- c(weightvec, 4);
    if (surveydata$listen_Rap[surveydata$id==x] < 3 | surveydata$listen_Rap[surveydata$id==x] > 5) weightvec <- c(weightvec, 0);
    if (surveydata$listen_Rap[surveydata$id==x] < 3 | surveydata$listen_Rap[surveydata$id==x] > 5) surveydata$Rapfan[surveydata$id==x] <- 0
    else surveydata$Rapfan[surveydata$id==x] <- 1;
  };
  
  if (surveydata$like_Dance[surveydata$id==x] > 3 & surveydata$like_Dance[surveydata$id==x] < 6) {
    harmvec <- c(harmvec, genremeans$HarmZ2[genremeans$genre=="dance"]);
    fairvec <- c(fairvec, genremeans$FairZ2[genremeans$genre=="dance"]);
    ingvec <- c(ingvec, genremeans$IngZ2[genremeans$genre=="dance"]);
    authvec <- c(authvec, genremeans$AuthZ2[genremeans$genre=="dance"]);
    purityvec <- c(purityvec, genremeans$PurityZ2[genremeans$genre=="dance"]);
    negvec <- c(negvec, genremeans$negemo[genremeans$genre=="dance"]);
    posvec <- c(posvec, genremeans$posemo[genremeans$genre=="dance"]);
    religvec <- c(religvec, genremeans$relig[genremeans$genre=="dance"]);
    progvec <- c(progvec, genremeans$ProgressivismTotal[genremeans$genre=="dance"]);
    polvec <- c(polvec, joinedmeans$politic[joinedmeans$genre=="dance"]);
    
    if (surveydata$listen_Dance[surveydata$id==x] == 3) weightvec <- c(weightvec, 1);
    if (surveydata$listen_Dance[surveydata$id==x] == 4) weightvec <- c(weightvec, 2);
    if (surveydata$listen_Dance[surveydata$id==x] == 5) weightvec <- c(weightvec, 4);
    if (surveydata$listen_Dance[surveydata$id==x] < 3 | surveydata$listen_Dance[surveydata$id==x] > 5) weightvec <- c(weightvec, 0);
    if (surveydata$listen_Dance[surveydata$id==x] < 3 | surveydata$listen_Dance[surveydata$id==x] > 5) surveydata$Dancefan[surveydata$id==x] <- 0
    else surveydata$Dancefan[surveydata$id==x] <- 1;
  };
  
  if (surveydata$like_Christian[surveydata$id==x] > 3 & surveydata$like_Christian[surveydata$id==x] < 6) {
    harmvec <- c(harmvec, genremeans$HarmZ2[genremeans$genre=="christian"]);
    fairvec <- c(fairvec, genremeans$FairZ2[genremeans$genre=="christian"]);
    ingvec <- c(ingvec, genremeans$IngZ2[genremeans$genre=="christian"]);
    authvec <- c(authvec, genremeans$AuthZ2[genremeans$genre=="christian"]);
    purityvec <- c(purityvec, genremeans$PurityZ2[genremeans$genre=="christian"]);
    negvec <- c(negvec, genremeans$negemo[genremeans$genre=="christian"]);
    posvec <- c(posvec, genremeans$posemo[genremeans$genre=="christian"]);
    religvec <- c(religvec, genremeans$relig[genremeans$genre=="christian"]);
    progvec <- c(progvec, genremeans$ProgressivismTotal[genremeans$genre=="christian"]);
    polvec <- c(polvec, joinedmeans$politic[joinedmeans$genre=="christian"]);
    
    if (surveydata$listen_Christian[surveydata$id==x] == 3) weightvec <- c(weightvec, 1);
    if (surveydata$listen_Christian[surveydata$id==x] == 4) weightvec <- c(weightvec, 2);
    if (surveydata$listen_Christian[surveydata$id==x] == 5) weightvec <- c(weightvec, 4);
    if (surveydata$listen_Christian[surveydata$id==x] < 3 | surveydata$listen_Christian[surveydata$id==x] > 5) weightvec <- c(weightvec, 0);
    if (surveydata$listen_Christian[surveydata$id==x] < 3 | surveydata$listen_Christian[surveydata$id==x] > 5) surveydata$Christianfan[surveydata$id==x] <- 0
    else surveydata$Christianfan[surveydata$id==x] <- 1;
  };
  
  if (surveydata$like_Jazz[surveydata$id==x] > 3 & surveydata$like_Jazz[surveydata$id==x] < 6) {
    harmvec <- c(harmvec, genremeans$HarmZ2[genremeans$genre=="jazz"]);
    fairvec <- c(fairvec, genremeans$FairZ2[genremeans$genre=="jazz"]);
    ingvec <- c(ingvec, genremeans$IngZ2[genremeans$genre=="jazz"]);
    authvec <- c(authvec, genremeans$AuthZ2[genremeans$genre=="jazz"]);
    purityvec <- c(purityvec, genremeans$PurityZ2[genremeans$genre=="jazz"]);
    negvec <- c(negvec, genremeans$negemo[genremeans$genre=="jazz"]);
    posvec <- c(posvec, genremeans$posemo[genremeans$genre=="jazz"]);
    religvec <- c(religvec, genremeans$relig[genremeans$genre=="jazz"]);
    progvec <- c(progvec, genremeans$ProgressivismTotal[genremeans$genre=="jazz"]);
    polvec <- c(polvec, joinedmeans$politic[joinedmeans$genre=="jazz"]);
    
    if (surveydata$listen_Jazz[surveydata$id==x] == 3) weightvec <- c(weightvec, 1);
    if (surveydata$listen_Jazz[surveydata$id==x] == 4) weightvec <- c(weightvec, 2);
    if (surveydata$listen_Jazz[surveydata$id==x] == 5) weightvec <- c(weightvec, 4);
    if (surveydata$listen_Jazz[surveydata$id==x] < 3 | surveydata$listen_Jazz[surveydata$id==x] > 5) weightvec <- c(weightvec, 0);
    if (surveydata$listen_Jazz[surveydata$id==x] < 3 | surveydata$listen_Jazz[surveydata$id==x] > 5) surveydata$Jazzfan[surveydata$id==x] <- 0
    else surveydata$Jazzfan[surveydata$id==x] <- 1;
  };
  
  if (surveydata$like_Reggae[surveydata$id==x] > 3 & surveydata$like_Reggae[surveydata$id==x] < 6) {
    harmvec <- c(harmvec, genremeans$HarmZ2[genremeans$genre=="reggae"]);
    fairvec <- c(fairvec, genremeans$FairZ2[genremeans$genre=="reggae"]);
    ingvec <- c(ingvec, genremeans$IngZ2[genremeans$genre=="reggae"]);
    authvec <- c(authvec, genremeans$AuthZ2[genremeans$genre=="reggae"]);
    purityvec <- c(purityvec, genremeans$PurityZ2[genremeans$genre=="reggae"]);
    negvec <- c(negvec, genremeans$negemo[genremeans$genre=="reggae"]);
    posvec <- c(posvec, genremeans$posemo[genremeans$genre=="reggae"]);
    religvec <- c(religvec, genremeans$relig[genremeans$genre=="reggae"]);
    progvec <- c(progvec, genremeans$ProgressivismTotal[genremeans$genre=="reggae"]);
    polvec <- c(polvec, joinedmeans$politic[joinedmeans$genre=="reggae"]);
    
    if (surveydata$listen_Reggae[surveydata$id==x] == 3) weightvec <- c(weightvec, 1);
    if (surveydata$listen_Reggae[surveydata$id==x] == 4) weightvec <- c(weightvec, 2);
    if (surveydata$listen_Reggae[surveydata$id==x] == 5) weightvec <- c(weightvec, 4);
    if (surveydata$listen_Reggae[surveydata$id==x] < 3 | surveydata$listen_Reggae[surveydata$id==x] > 5) weightvec <- c(weightvec, 0);
    if (surveydata$listen_Reggae[surveydata$id==x] < 3 | surveydata$listen_Reggae[surveydata$id==x] > 5) surveydata$Reggaefan[surveydata$id==x] <- 0
    else surveydata$Reggaefan[surveydata$id==x] <- 1;
  };
  
  if (surveydata$like_Blues[surveydata$id==x] > 3 & surveydata$like_Pop[surveydata$id==x] < 6) {
    harmvec <- c(harmvec, genremeans$HarmZ2[genremeans$genre=="blues"]);
    fairvec <- c(fairvec, genremeans$FairZ2[genremeans$genre=="blues"]);
    ingvec <- c(ingvec, genremeans$IngZ2[genremeans$genre=="blues"]);
    authvec <- c(authvec, genremeans$AuthZ2[genremeans$genre=="blues"]);
    purityvec <- c(purityvec, genremeans$PurityZ2[genremeans$genre=="blues"]);
    negvec <- c(negvec, genremeans$negemo[genremeans$genre=="blues"]);
    posvec <- c(posvec, genremeans$posemo[genremeans$genre=="blues"]);
    religvec <- c(religvec, genremeans$relig[genremeans$genre=="blues"]);
    progvec <- c(progvec, genremeans$ProgressivismTotal[genremeans$genre=="blues"]);
    polvec <- c(polvec, joinedmeans$politic[joinedmeans$genre=="blues"]);
    
    if (surveydata$listen_Blues[surveydata$id==x] == 3) weightvec <- c(weightvec, 1);
    if (surveydata$listen_Blues[surveydata$id==x] == 4) weightvec <- c(weightvec, 2);
    if (surveydata$listen_Blues[surveydata$id==x] == 5) weightvec <- c(weightvec, 4);
    if (surveydata$listen_Blues[surveydata$id==x] < 3 | surveydata$listen_Blues[surveydata$id==x] > 5) weightvec <- c(weightvec, 0);
    if (surveydata$listen_Blues[surveydata$id==x] < 3 | surveydata$listen_Blues[surveydata$id==x] > 5) surveydata$Bluesfan[surveydata$id==x] <- 0
    else surveydata$Bluesfan[surveydata$id==x] <- 1;
  };
  
  surveydata$lyricharmZ[surveydata$id==x] <- weighted.mean(harmvec, weightvec);
  surveydata$lyricfairZ[surveydata$id==x] <- weighted.mean(fairvec, weightvec);
  surveydata$lyricingZ[surveydata$id==x] <- weighted.mean(ingvec, weightvec);
  surveydata$lyricauthZ[surveydata$id==x] <- weighted.mean(authvec, weightvec);
  surveydata$lyricpurityZ[surveydata$id==x] <- weighted.mean(purityvec, weightvec);
  surveydata$lyricprogZ[surveydata$id==x] <- weighted.mean(progvec, weightvec);
  surveydata$lyricnegZ[surveydata$id==x] <- weighted.mean(negvec, weightvec);
  surveydata$lyricposZ[surveydata$id==x] <- weighted.mean(posvec, weightvec);
  surveydata$lyricreligZ[surveydata$id==x] <- weighted.mean(religvec, weightvec);
}

surveydata$genresfanned <- surveydata$Popfan+surveydata$Rockfan+surveydata$Christianfan+surveydata$Countryfan+surveydata$Rapfan+surveydata$Dancefan+surveydata$Rbfan+surveydata$Reggaefan+surveydata$Bluesfan+surveydata$Jazzfan;

surveydata4 <- subset(surveydata, genresfanned >= 3);
surveydata2$ideo5[surveydata2$ideo5==6] <- NA;
surveydata2$pid3[surveydata2$pid3>2] <- NA;
surveydata2$respondent_race_2[surveydata2$respondent_race_2==2] <- 0;

surveydata3 <- subset(surveydata2, is.na(ideo5)==FALSE)
