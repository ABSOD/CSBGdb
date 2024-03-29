#'  incomePRO Income Distribution Graph
#'
#'  Modified from ms_income in codemogProfile AB 12/2017
#'
#'  This function pulls data and generates a graph of the income distribution
#'  for the areas selected based on the ACS
#'
#' @param listID the list containing place id and Place names
#' @param ACS  Data set id, eg: for 2015 ACS: "acs1115"
#' @return ggplot2 graphic and data file
#' @export
#'
incomePRO=function(listID, ACS){
# Collecting place ids from  idList, setting default values
 
   ctyfips <- listID$ctyNum
   ctyname <- listID$ctyName
   placefips <- listID$plNum
   placename <- listID$plName
  # if(listID$PlFilter == "T") {
  #   placefips <- ""
  #   placename <- ""
  # }
   
  
   state="08"
  base=12

  hhinc1VAL <- codemog_api(data="b19001",db=ACS, geonum=paste0("1", state, ctyfips), meta="no") %>%
    select(-b19001001)%>%
    gather(var, value, b19001002:b19001017, -geoname, -state, -county, -place,-tract,-bg,-geonum)%>%
    mutate(geoname=str_trim(geoname, side="both"),
           var2=str_sub(var, -2,-1),
           var3=as.numeric(as.character(var2)),
           group=car::recode(var3, "2=1; 3:4=2; 5:6=3;7:8=4;9:10=5; 11=6;12=7;13=8;14=9;
                             15=10;16=11;17=12"))%>%
    group_by(geoname,group)%>%
    summarise(value=sum(as.numeric(value)))%>%
    mutate(cat=ordered(group, levels=1:12))
  
  
  # Place MOE
  hhinc1MOE=codemog_api(data="b19001_moe",db=ACS, geonum=paste0("1", state, ctyfips), meta="no")%>%
    select(-b19001_moe001)%>%
    gather(var, value, b19001_moe002:b19001_moe017, -geoname, -state, -county, -place,-tract,-bg,-geonum)%>%
    mutate(geoname=str_trim(geoname, side="both"),
           var2=str_sub(var, -2,-1),
           var3=as.numeric(as.character(var2)),
           group=car::recode(var3, "2=1; 3:4=2; 5:6=3;7:8=4;9:10=5; 11=6;12=7;13=8;14=9;
                             15=10;16=11;17=12"))%>%
    group_by(geoname,group)%>%
    summarise(value=sum(as.numeric(value)))%>%
    mutate(cat=ordered(group, levels=1:12))
  
  names(hhinc1MOE)[3] <- "MOE"
  # Combining Place Level Data File; Calculating percentages
  f.hh1VAL <- hhinc1VAL[, c(4,1,3)]
  f.hh1MOE <- hhinc1MOE[,c(4,3)]
  hhinc1 <- left_join(f.hh1VAL, f.hh1MOE, by="cat")
  # Calculating Confidence intervale and Percentage valuse
  f.hhinc1 <- hhinc1 %>%
    mutate(c_propVAL = value/sum(value),
           c_propMOE = MOE/sum(value))
  f.hhinc1$geoname <- ctyname
  f.hhinc1$c_ciLOW  <- f.hhinc1$c_propVAL - f.hhinc1$c_propMOE
  f.hhinc1$c_ciHIGH <- f.hhinc1$c_propVAL + f.hhinc1$c_propMOE
  f.hhinc1$c_pctVAL <- percent(f.hhinc1$c_propVAL *100)
  f.hhinc1$c_pctMOE <- percent(f.hhinc1$c_propMOE *100)
  f.hhinc1$c_pctLOW <- percent(f.hhinc1$c_ciLOW *100)
  f.hhinc1$c_pctHIGH <- percent(f.hhinc1$c_ciHIGH *100)
  
  
  #State Value
  hhinc2VAL=codemog_api(data="b19001",db=ACS, geonum=paste0("1", state), meta="no")%>%
    select(-b19001001)%>%
    gather(var, value, b19001002:b19001017, -geoname, -state, -county, -place,-tract,-bg,-geonum)%>%
    mutate(geoname=str_trim(geoname, side="both"),
           var2=str_sub(var, -2,-1),
           var3=as.numeric(as.character(var2)),
           group=car::recode(var3, "2=1; 3:4=2; 5:6=3;7:8=4;9:10=5; 11=6;12=7;13=8;14=9;
                             15=10;16=11;17=12"))%>%
    group_by(geoname,group)%>%
    summarise(value=sum(as.numeric(value)))%>%
    mutate(cat=ordered(group, levels=1:12))
  
  #State MOE
  hhinc2MOE=codemog_api(data="b19001_moe",db=ACS, geonum=paste0("1", state), meta="no")%>%
    select(-b19001_moe001)%>%
    gather(var, value, b19001_moe002:b19001_moe017, -geoname, -state, -county, -place,-tract,-bg,-geonum)%>%
    mutate(geoname=str_trim(geoname, side="both"),
           var2=str_sub(var, -2,-1),
           var3=as.numeric(as.character(var2)),
           group=car::recode(var3, "2=1; 3:4=2; 5:6=3;7:8=4;9:10=5; 11=6;12=7;13=8;14=9;
                             15=10;16=11;17=12"))%>%
    group_by(geoname,group)%>%
    summarise(value=sum(as.numeric(value)))%>%
    mutate(cat=ordered(group, levels=1:12))
  
  names(hhinc2MOE)[3] <- "MOE"
  # Combining Place Level Data File; Calculating percentages
  f.hh2VAL <- hhinc2VAL[, c(4,1,3)]
  f.hh2MOE <- hhinc2MOE[,c(4,3)]
  hhinc2 <- left_join(f.hh2VAL, f.hh2MOE, by="cat")
  # Calculating Confidence intervale and Percentage valuse
  f.hhinc2 <- hhinc2 %>%
    mutate(s_propVAL = value/sum(value),
           s_propMOE = MOE/sum(value))
  
  f.hhinc2$s_ciLOW  <- f.hhinc2$s_propVAL - f.hhinc2$s_propMOE
  f.hhinc2$s_ciHIGH <- f.hhinc2$s_propVAL + f.hhinc2$s_propMOE
  f.hhinc2$s_pctVAL <- percent(f.hhinc2$s_propVAL *100)
  f.hhinc2$s_pctMOE <- percent(f.hhinc2$s_propMOE *100)
  f.hhinc2$s_pctLOW <- percent(f.hhinc2$s_ciLOW *100)
  f.hhinc2$s_pctHIGH <- percent(f.hhinc2$s_ciHIGH *100)
  
  
  #Municipality
  if(nchar(placefips) !=0) {
    hhinc3VAL=codemog_api(data="b19001",db=ACS, geonum=paste0("1", state, placefips), meta="no")%>%
      select(-b19001001)%>%
      gather(var, value, b19001002:b19001017, -geoname, -state, -county, -place,-tract,-bg,-geonum)%>%
      mutate(geoname=str_trim(geoname, side="both"),
             var2=str_sub(var, -2,-1),
             var3=as.numeric(as.character(var2)),
             group=car::recode(var3, "2=1; 3:4=2; 5:6=3;7:8=4;9:10=5; 11=6;12=7;13=8;14=9;
                               15=10;16=11;17=12"))%>%
      group_by(geoname,group)%>%
      summarise(value=sum(as.numeric(value)))%>%
      mutate(cat=ordered(group, levels=1:12))    
    
    # Place MOE
    hhinc3MOE=codemog_api(data="b19001_moe",db=ACS, geonum=paste0("1", state, placefips), meta="no")%>%
      select(-b19001_moe001)%>%
      gather(var, value, b19001_moe002:b19001_moe017, -geoname, -state, -county, -place,-tract,-bg,-geonum)%>%
      mutate(geoname=str_trim(geoname, side="both"),
             var2=str_sub(var, -2,-1),
             var3=as.numeric(as.character(var2)),
             group=car::recode(var3, "2=1; 3:4=2; 5:6=3;7:8=4;9:10=5; 11=6;12=7;13=8;14=9;
                               15=10;16=11;17=12"))%>%
      group_by(geoname,group)%>%
      summarise(value=sum(as.numeric(value)))%>%
      mutate(cat=ordered(group, levels=1:12))
    
    names(hhinc3MOE)[3] <- "MOE"
    # Combining Place Level Data File; Calculating percentages
    f.hh1VAL <- hhinc3VAL[, c(4,1,3)]
    f.hh1MOE <- hhinc3MOE[,c(4,3)]
    hhinc3 <- left_join(f.hh1VAL, f.hh1MOE, by="cat")
    # Calculating Confidence intervale and Percentage valuse
    f.hhinc3 <- hhinc3 %>%
      mutate(p_propVAL = value/sum(value),
             p_propMOE = MOE/sum(value))
    f.hhinc3$geoname <- placename
    f.hhinc3$p_ciLOW  <- f.hhinc3$p_propVAL - f.hhinc3$p_propMOE
    f.hhinc3$p_ciHIGH <- f.hhinc3$p_propVAL + f.hhinc3$p_propMOE
    f.hhinc3$p_pctVAL <- percent(f.hhinc3$p_propVAL *100)
    f.hhinc3$p_pctMOE <- percent(f.hhinc3$p_propMOE *100)
    f.hhinc3$p_pctLOW <- percent(f.hhinc3$p_ciLOW *100)
    f.hhinc3$p_pctHIGH <- percent(f.hhinc3$p_ciHIGH *100)
  }
  
  #Preparing Chart
  if(nchar(placefips) == 0) {
    f.hhinc1p <- f.hhinc1[, c(1,2,5,7,8)]
    names(f.hhinc1p) <- c("Income_Cat","geoname","prop","propLOW","propHIGH")
    f.hhinc2p <- f.hhinc2[, c(1,2,5,7,8)]
    names(f.hhinc2p) <- c("Income_Cat","geoname","prop","propLOW","propHIGH")
    hhinc <- rbind( f.hhinc1p,  f.hhinc2p)
    subTitle <- ctyname
  } else {
    f.hhinc1p <- f.hhinc1[, c(1,2,5,7,8)]
    names(f.hhinc1p) <- c("Income_Cat","geoname","prop","propLOW","propHIGH")
    f.hhinc3p <- f.hhinc3[, c(1,2,5,7,8)]
    names(f.hhinc3p) <- c("Income_Cat","geoname","prop","propLOW","propHIGH")
    hhinc <- rbind( f.hhinc3p,  f.hhinc1p)
    subTitle <- placename
  }
  
  
  hhinc$prop <- hhinc$prop *100
  hhinc$propLOW <- hhinc$propLOW * 100
  hhinc$propHIGH <- hhinc$propHIGH * 100
  
  hhinc$Income_Cat <- factor(hhinc$Income_Cat, levels = 1:12,
                               labels=c("Less\nthan\n$10,000","$10,000\nto\n$19,999 ","$20,000\nto\n$29,999 ",
                                                        "$30,000\nto\n$39,999 ", "$40,000\nto\n$49,999 ", "$50,000\nto\n$59,999 ",
                                                        "$60,000\nto\n$74,999 ","$75,000\nto\n$99,999 ","$100,000\nto\n$124,999 ",
                                                        "$125,000\nto\n$149,999 ","$150,000\nto\n$199,999 ","$200,000\nor\nmore "))
  
  if(nchar(placefips) == 0) {
    hhinc$geoname <- factor(hhinc$geoname, levels=c(ctyname, "Colorado"))
  } else {
    hhinc$geoname <- factor(hhinc$geoname, levels=c(placename, ctyname))
  }
  
  
  pltTitle <- "Household Income Distribution"
  xTitle <- paste0("Income (in 20",substr(ACS,6,8)," Dollars)")

  maxAxs  <- round(max(hhinc$propHIGH),digits=0) + 2
  minAxs <- round(min(hhinc$propLOW),digits=0)
  minAxs <- ifelse(as.numeric(minAxs) > 0, 0,-10)
  
  p=hhinc%>%ggplot(aes(x=Income_Cat, y=prop, fill=geoname))+
    geom_bar(stat="identity", position="dodge")+
    geom_errorbar(aes(ymin=propLOW, ymax=propHIGH),
                  width=.2,                    # Width of the error bars
                  position=position_dodge(.9)) +
    geom_hline(yintercept=0, size=1.05) +
    scale_y_continuous(limits=c(minAxs,maxAxs), label=percent, expand = c(0, 0))+
    scale_fill_manual(values=c("#6EC4E8","#00953A"),
                      name="Geography")+
    theme_codemog(base_size=base)+
    labs(title = pltTitle,
         subtitle = subTitle,
         caption = captionSrc("ACS",ACS),
         x = xTitle,
         y= "Percentage") +
    theme(plot.title = element_text(hjust = 0.5, size=16),
          panel.background = element_rect(fill = "white", colour = "gray50"),
          panel.grid.major = element_line(colour = "gray80"),
          axis.text.x = element_text(size=9),
          axis.text.y = element_text(size=12),
          legend.position= "bottom",
           plot.margin = margin(0,0,0,0, "cm"))
  
  # Building Output dataset
  if(nchar(placefips) == 0) {
    hh_place <- f.hhinc1[,c(1,5,6,9:12)]
    hh_state <- f.hhinc2[,c(1,5,6,9:12)]
    f.dWide <- left_join(hh_place,hh_state,by="cat")
    
    #calcualting Statistical Test
    #Calculating the statistical test
    f.dWide$ZScore <- (abs(f.dWide$c_propVAL - f.dWide$s_propVAL)/
                         sqrt((f.dWide$c_propMOE^2) + (f.dWide$s_propMOE^2)))
    f.dWide$Sig_Diff <- ifelse(f.dWide$ZScore < 1,"No","Yes")
    f.dWide$Sig_Diff <- ifelse(is.na(f.dWide$Sig_Diff)," ",f.dWide$Sig_Diff)
    
    f.dwideo <-  f.dWide[,c(1,4:7,10:13,15)]
    
    names(f.dwideo) <- c("Income_Cat",paste0("Percentage: ",ctyname), paste0("Margin of Error: ",ctyname),
                         paste0("Lower 90% Conf Int: ",ctyname),paste0("Upper 90% Conf Int: ",ctyname),
                         "Percentage: Colorado", "Margin of Error: Colorado",
                         "Lower 90% Conf Int: Colorado","Upper 90% Conf Int: Colorado","Significant Difference")
  }  else {
    hh_place <- f.hhinc3[,c(1,5,6,9:12)]
    hh_state <- f.hhinc1[,c(1,5,6,9:12)]
    f.dWide <- left_join(hh_place,hh_state,by="cat")
    
    #calcualting Statistical Test
    #Calculating the statistical test
    f.dWide$ZScore <- (abs(f.dWide$p_propVAL - f.dWide$c_propVAL)/
                         sqrt((f.dWide$p_propMOE^2) + (f.dWide$c_propMOE^2)))
    f.dWide$Sig_Diff <- ifelse(f.dWide$ZScore < 1,"No","Yes")
    f.dWide$Sig_Diff <- ifelse(is.na(f.dWide$Sig_Diff)," ",f.dWide$Sig_Diff)
    
    f.dwideo <-  f.dWide[,c(1,4:7,10:13,15)]
    
    names(f.dwideo) <- c("Income_Cat",paste0("Percentage: ",placename), 
                         paste0("Margin of Error: ",placename),
                         paste0("Lower 90% Conf Int: ",placename),
                         paste0("Upper 90% Conf Int: ",placename),
                         paste0("Percentage: ",ctyname), 
                         paste0("Margin of Error: ",ctyname),
                         paste0("Lower 90% Conf Int: ",ctyname),
                         paste0("Upper 90% Conf Int: ",ctyname),
                         "Significant Difference")
  }  
  
  
  f.dwideo$Income_Cat <- factor(f.dwideo$Income_Cat, levels = 1:12, 
                                labels =c("Less than $10,000","$10,000 to $19,999","$20,000 to $29,999",
                                                              "$30,000 to $39,999", "$40,000 to $49,999", "$50,000 to $59,999",
                                                              "$60,000 to $74,999","$75,000 to $99,999","$100,000 to $124,999",
                                                              "$125,000 to $149,999","$150,000 to $199,999","$200,000 or more"))
  
  
  if(nchar(placefips) != 0)  {
      OutText <- paste0("The household income distribution plot compares ",placename," to household incomes for ",ctyname,".")  
      OutText <- paste0(OutText,"  Household income comes primarily from earnings at work, but government transfer payments")
      OutText <- paste0(OutText,"  such as Social Security and TANF and unearned income from dividends, interest and rent")
      OutText <- paste0(OutText,"  are also included. Income and education levels are highly correlated; areas that have lower")
      OutText <- paste0(OutText,"  educational attainment than the state will typically have lower household incomes.") 
    } else {
      OutText <- paste0("The household income distribution plot compares ",ctyname," to the statewide household incomes.")  
      OutText <- paste0(OutText,"  Household income comes primarily from earnings at work, but government transfer payments")
      OutText <- paste0(OutText,"  such as Social Security and TANF and unearned income from dividends, interest and rent")
      OutText <- paste0(OutText,"  are also included. Income and education levels are highly correlated; areas that have lower")
      OutText <- paste0(OutText,"  educational attainment than the state will typically have lower household incomes.") 
    }
    

  #bind list
  outList <- list("plot"= p, "data" =  f.dwideo,"text" = OutText)
  return(outList)
}
