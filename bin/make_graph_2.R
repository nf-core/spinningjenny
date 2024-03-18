#!/usr/bin/env Rscript

##Argument parser:
#Create parser object
library("argparse")
library(tidyverse)
library(readr)
library(dplyr)

parser <- ArgumentParser()

#Define desired outputs:
#GLOBAL FEATURES:
parser$add_argument("-input", "--Input_name", type="character", help="Input filenames.")
parser$add_argument("-output", "--Output_prefix", type="character", help="Output prefix for plots")
#parser$add_argument("-fasta", "--Fasta_file", type="character", help="Genome fasta file.")
#parser$add_argument("-ini_pos", "--Initial_position", type="integer", default=50, help="Initial position [default %(default)].")
#parser$add_argument("-fin_pos", "--Final_position", type="integer", help="Final position.")


######### OUTPUT ANALYSIS ##########

#Get command line options, if help option encountered - print help and exit:
args <- parser$parse_args()

input_file <- args$Input_name


output_plot1 <- paste(args$Output_prefix, "_1.pdf", sep="")
output_plot2 <- paste(args$Output_prefix, "_2.pdf", sep="")
output_plot3 <- paste(args$Output_prefix, "_3.pdf", sep="")


#varname for the different variables 

## importing data
#rm(list = ls())

outputs <- read_csv(input_file, 
                    #col_types = cols(X1 = col_number()), 
                    skip = 6,)



# rename [step] to avoid problems with [] in R
#outputs <- outputs %>%
#  rename(turn = 41,ID = 1)

#outputs

#exit

## comparison graphs, only for wealth and  prices 

## prices

bourgeoisiesprice <- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`mean price of bourgeoisie`),list(bourgeoisieprices = mean))

bourgeoisiespricessshades <- outputs %>%
  group_by(step) %>%
  summarize(highbourgpr = quantile(`mean price of bourgeoisie`, probs = 0.975),
            lowbourgpr = quantile(`mean price of bourgeoisie`, probs = 0.025))
bourgeoisiesprice <- merge(bourgeoisiesprice,bourgeoisiespricessshades, by = "step")

firmsprice <- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`mean price of firms`),list(firmsprices = mean))

firmspricesshades <- outputs %>%
  group_by(step) %>%
  summarize(highfirmpr = quantile(`mean price of firms`, probs = 0.975),
            lowfirmpr = quantile(`mean price of firms`, probs = 0.025))
firmsprice <- merge(firmsprice,firmspricesshades, by = "step")


farmsprice <- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`mean-farm-price`),list(farmsprices = mean))

farmspricesshades <- outputs %>%
  group_by(step) %>%
  summarize(highfarmpr = quantile(`mean-farm-price`, probs = 0.975),
            lowfarmpr = quantile(`mean-farm-price`, probs = 0.025))
farmsprice <- merge(farmsprice,farmspricesshades, by = "step")

salaries <- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`mean-salaries`),list(meansalaries=mean))
salarieshades <- outputs %>%
  group_by(step) %>%
  summarise(highsalary = quantile(`mean-salaries`, probs = 0.975),
            lowsalary = quantile(`mean-salaries`, probs = 0.025))
salaries <- merge(salaries,salarieshades,by="step")

forprices <- merge(bourgeoisiesprice,firmsprice,by="step")
forprices <- merge(forprices,farmsprice,by="step")
forprices <- merge(forprices,salaries,by="step")

prices <- ggplot(data = forprices, aes(x=step)) + ##produces the plot
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  geom_line(aes(y=bourgeoisieprices,color="Bourgeoisie")) +
  geom_line(aes(y=firmsprices, color="Firms")) +
  geom_line(aes(y=farmsprices, color="Farms")) +
  geom_line(aes(y=meansalaries, color="Salaries")) + 
  geom_ribbon(data = forprices,aes(x=step,y=firmsprices,ymin = lowfirmpr, ymax = highfirmpr), alpha=0.1) +
  geom_ribbon(data = forprices,aes(x=step,y=bourgeoisieprices,ymin = lowbourgpr, ymax = highbourgpr), alpha=0.1) +
  geom_ribbon(data = forprices,aes(x=step,y=farmsprices,ymin = lowfarmpr, ymax = highfarmpr), alpha=0.1) +
  geom_ribbon(data = forprices,aes(x=step,y=meansalaries,ymin=lowsalary,ymax=highsalary), alpha=0.1) +
  labs(x = 'Time', y = 'Value' ) + #changes the plot to a line
  ggtitle('Prices averages') +
  scale_color_manual(name = "Classes", values = c("Bourgeoisie" = "orange", "Firms" = "yellow", "Farms" = "green","Salaries"="blue"))+
  geom_vline(xintercept = 100) + #line for time change
  theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#prices

pdf(output_plot1)
print(prices)
dev.off()


##WEALTH

bourgeoisiesincomes <- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`mean wealth of bourgeoisie`),list(bourgeoisiewealth = mean))

bourgeoisiesincomesshades <- outputs %>%
  group_by(step) %>%
  summarize(highbourg = quantile(`mean wealth of bourgeoisie`, probs = 0.975),
            lowbourg = quantile(`mean wealth of bourgeoisie`, probs = 0.025))

bourgeoisiesincomes <- merge(bourgeoisiesincomes,bourgeoisiesincomesshades, by = "step")

workersincomes <- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`mean wealth of workers`), list(workerswealth = mean))
workersincomesshades <- outputs %>%
  group_by(step) %>%
  summarize(highwork = quantile(`mean wealth of workers`, probs = 0.975),
            lowwork = quantile(`mean wealth of workers`, probs = 0.025))
workersincomes <- merge(workersincomes,workersincomesshades, by = "step")

noblesincomes <- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`mean wealth of nobles`),list(nobleswealth = mean))
noblesincomeshades <- outputs %>%
  group_by(step) %>%
  summarize(highnobles = quantile(`mean wealth of nobles`, probs = 0.975),
            lownobles = quantile(`mean wealth of nobles`, probs = 0.025))

noblesincomes <- merge(noblesincomes,noblesincomeshades,by="step")

farmscapital <- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`average-capital-farms`),list(farmscapital = mean))

farmsshades <- outputs %>%
  group_by(step) %>%
  summarize(highfarms = quantile(`average-capital-farms`, probs = 0.975),
            lowfarms = quantile(`average-capital-farms`, probs = 0.025))

farmscap <- merge(farmscapital,farmsshades,by="step")


firmscapital <- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`average-capital-firms`),list(firmscapital = mean))

firmsshades <- outputs %>%
  group_by(step) %>%
  summarize(highfirms = quantile(`average-capital-firms`, probs = 0.975),
            lowfirms = quantile(`average-capital-firms`, probs = 0.025))

firmscap <- merge(firmscapital,firmsshades,by="step")

forcapital <- merge(firmscap,farmscap,by="step")

forincomes <- merge(bourgeoisiesincomes,workersincomes,by="step")
forincomes <- merge(forincomes,noblesincomes,by="step")
forincomes <- merge(forincomes,forcapital,by="step")

names<-c('bourgeoisies','workers','nobles','farms','firms')


wealth <- ggplot(data = forincomes, aes(x=step)) + ##produces the plot
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  geom_line(aes(y=bourgeoisiewealth,color='Bourgeoisies')) +
  geom_line(aes(y=workerswealth,color='Workers')) +
  geom_line(aes(y=nobleswealth,color='Nobles')) +
  geom_line(aes(y=farmscapital,color='Farms')) +
  geom_line(aes(y=firmscapital,color='Firms')) +
  geom_ribbon(data = forincomes,aes(x=step,y=bourgeoisiewealth,ymin = lowbourg, ymax = highbourg), alpha=0.1) +
  geom_ribbon(data = forincomes,aes(x=step,y=nobleswealth,ymin = lownobles, ymax = highnobles), alpha=0.1) +
  geom_ribbon(data = forincomes,aes(x=step,y=workerswealth,ymin = lowwork, ymax = highwork), alpha=0.1) +
  geom_ribbon(data = forincomes,aes(x=step,y=farmscapital,ymin = lowfarms, ymax = highfarms), alpha=0.1) +
  geom_ribbon(data = forincomes,aes(x=step,y=firmscapital,ymin = lowfirms, ymax = highfirms,), alpha=0.5) +
  labs(x = 'Time', y = 'Wealth' ) + #changes the plot to a line
  ggtitle('Wealth Averages') +
  scale_color_manual(name = "Classes", values = c("Bourgeoisies" = "orange", "Workers" = "red","Nobles" = "blue", "Farms" = "green", "Firms" = "yellow"))+
  geom_vline(xintercept = 100) + #line for time change
  theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#wealth

pdf(output_plot2)
print(wealth)
dev.off()

####GDP

gdp<- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`GDP-spending`),list(GDP= mean))

 gdpshades<- outputs %>%
  group_by(step) %>%
  summarize(highgdp = quantile(`GDP-spending`, probs = 0.975),
            lowgdp = quantile(`GDP-spending`, probs = 0.025))
 gdp <- merge(gdp,gdpshades,by="step")

goods<- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`goods-income-value`),list(goodsvalue= mean))

goodsshape<- outputs %>%
  group_by(step) %>%
  summarize(highgoods = quantile(`goods-income-value`, probs = 0.975),
            lowgoods = quantile(`goods-income-value`, probs = 0.025))
 
 goods<- merge(goods,goodsshape,by="step")

land<- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`land-income-value`),list(landvalue= mean))

landshapes<- outputs %>%
  group_by(step) %>%
  summarize(highland = quantile(`land-income-value`, probs = 0.975),
            lowland = quantile(`land-income-value`, probs = 0.025))

land<- merge(land,landshapes,by="step")

labor<- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`labor-income-value`),list( laborvalue = mean))

laborshapes<- outputs %>%
  group_by(step) %>%
  summarize(highlabor = quantile(`labor-income-value`, probs = 0.975),
            lowlabor = quantile(`labor-income-value`, probs = 0.025))

labor<- merge(labor,laborshapes,by="step")


service<- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`service-income-value`),list(servicevalue = mean))

serviceshades<- outputs %>%
  group_by(step) %>%
  summarize(highservice = quantile(`service-income-value`, probs = 0.975),
            lowservice = quantile(`service-income-value`, probs = 0.025))

service<- merge(service,serviceshades,by="step")

profits<- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`profit-income-value`),list(profitvalue= mean))

profitsshades<- outputs %>%
  group_by(step) %>%
  summarize(highprofits = quantile(`profit-income-value`, probs = 0.975),
            lowprofits = quantile(`profit-income-value`, probs = 0.025))

profits<- merge(profits,profitsshades,by="step")


realgdp<- outputs %>%
  group_by(step) %>%
  summarise_at(vars(`real-GDP-spending`),list(real=mean))

realgdpshades<- outputs%>%
  group_by(step) %>%
  summarise(highreal = quantile(`real-GDP-spending`, probs = 0.975),
            lowreal = quantile(`real-GDP-spending`, probs = 0.025))

realgdp<- merge(realgdp,realgdpshades,by="step")



forgdp <- merge(gdp,goods,by="step")
forgdp <- merge(forgdp,land,by="step")
forgdp <- merge(forgdp,labor,by="step")
forgdp <- merge(forgdp,service,by="step")
forgdp <- merge(forgdp,profits,by="step")
forgdp <- merge(forgdp,realgdp,by="step")




forGDP <- ggplot(data = forgdp, aes(x=step)) + ##produces the plot
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  geom_line(aes(y=GDP,color='GDP')) +
  geom_line(aes(y=goodsvalue,color='Goods')) +
  geom_line(aes(y=landvalue,color='Food')) +
  geom_line(aes(y=servicevalue,color='Services')) +
  geom_line(aes(y=profitvalue,color='Profits')) +
  geom_line(aes(y=laborvalue,color='Labor')) +
  geom_line(aes(y=real,color='Real GDP')) +
  geom_ribbon(data = forgdp,aes(x=step,y=GDP,ymin = lowgdp, ymax = highgdp), alpha=0.1) +
  geom_ribbon(data = forgdp,aes(x=step,y=goodsvalue,ymin = lowgoods, ymax = highgoods), alpha=0.1) +
  geom_ribbon(data = forgdp,aes(x=step,y=landvalue,ymin = lowland, ymax = highland), alpha=0.1) +
  geom_ribbon(data = forgdp,aes(x=step,y=servicevalue,ymin = lowservice, ymax = highservice), alpha=0.1) +
  geom_ribbon(data = forgdp,aes(x=step,y=profitvalue,ymin = lowprofits, ymax = highprofits,), alpha=0.1) +
  geom_ribbon(data = forgdp,aes(x=step,y=laborvalue,ymin = lowlabor, ymax = highlabor,), alpha=0.1) +
  geom_ribbon(data = forgdp,aes(x=step,y=real,ymin = lowreal, ymax = highreal,), alpha=0.1) +
  labs(x = 'Time', y = 'Value' ) + #changes the plot to a line
  ggtitle('GDP and sectors contributions ') +
  scale_color_manual(name = "Classes", values = c("GDP"="black","Real GDP"="black","Services" = "orange", "Labor" = "red","Profits" = "blue", "Food" = "green", "Goods" = "yellow"))+
  geom_vline(xintercept = 100) + #line for time change
  theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
#forGDP


pdf(output_plot3)
print(forGDP)
dev.off()
