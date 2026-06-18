# R code on Western Canadian English speakers' /ɹ/ production and labial articulation 
# developed by Youran Lin at the University of Alberta (youran.lin@ualberta.ca)


#### set up ####
library(ggplot2)
library(gridExtra)
library(gridGraphics) 
library(grid)
library(tidyverse)
library(lmerTest)
library(emmeans)
library(sjPlot)
library(mgcv)
library(itsadug)
library(dplyr)
source("gamm_hacks.r") # supplementary R script created by Márton Sóskuthy

data = read.csv("L2Lip2026_WordSelfPaced_normalizedData44.csv")
data = data[data$sound=="r"|data$sound=="w"|data$sound=="l",]
data = data[data$group=="E",]
data = data[!data$participant %in% c("E_019", "E_022", "E_029", "E_032"), ] # participants who did not report speaking Western Canadian English
data = data[data$position=="pre",]
data = data[data$error=="correct",]

data$sound = factor(data$sound, labels = c("/l/", "/ɹ/", "/w/"))
data$sound = factor(data$sound, levels = c("/ɹ/", "/w/", "/l/"))
table(data$sound)
data$vowel = factor(data$vowel, labels = c("/ɑ/","/æ/","/i/","/u/"))
data$vowel = factor(data$vowel, levels = c("/i/","/æ/","/ɑ/","/u/"))
table(data$vowel)
table(data$word)
data$list = factor(data$list)
table(data$list)


#### static measures ####

m.F3 = lmer(I(F3) ~ sound*vowel + (1|participant), data = data)
m.F3_list = lmer(I(F3) ~ sound*vowel * list + (1|participant), data = data)
anova(m.F3, m.F3_list) # list did not matter
summary(m.F3)
ranova(m.F3)

emmeans = emmeans(m.F3, pairwise ~ sound)
summary(emmeans, adjustment = "tukey")$contrast
emmeans = emmeans(m.F3, pairwise ~ sound|vowel)
summary(emmeans, adjustment = "tukey")$contrast
emmeans = emmeans(m.F3, pairwise ~ vowel|sound)
summary(emmeans, adjustment = "tukey")$contrast

m.opening_average = lmer(I(opening_average) ~ sound*vowel + (1|participant), data = data)
m.opening_average_list = lmer(I(opening_average) ~ sound*vowel * list + (1|participant), data = data)
anova(m.opening_average,m.opening_average_list) # list mattered
m.opening_average = m.opening_average_list
summary(m.opening_average)
ranova(m.opening_average)

emmeans = emmeans(m.opening_average, pairwise ~ sound)
summary(emmeans, adjustment = "tukey")$contrast
summary(emmeans, adjustment = "tukey")
emmeans = emmeans(m.opening_average, pairwise ~ sound|vowel)
summary(emmeans, adjustment = "tukey")$contrast
emmeans = emmeans(m.opening_average, pairwise ~ vowel|sound)
summary(emmeans, adjustment = "tukey")$contrast

m.spread_average = lmer(I(spread_average) ~ sound*vowel + (1|participant), data = data)
m.spread_average_list = lmer(I(spread_average) ~ sound*vowel*list + (1|participant) , data = data)
anova(m.spread_average,m.spread_average_list)
summary(m.spread_average)
ranova(m.spread_average)

emmeans = emmeans(m.spread_average, pairwise ~ sound)
summary(emmeans, adjustment = "tukey")$contrast
summary(emmeans, adjustment = "tukey")
emmeans = emmeans(m.spread_average, pairwise ~ sound|vowel)
summary(emmeans, adjustment = "tukey")$contrast
emmeans = emmeans(m.spread_average, pairwise ~ vowel|sound)
summary(emmeans, adjustment = "tukey")$contrast

m.protrusion_average = lmer(I(protrusion_average) ~ sound*vowel + (1|participant), data = data)
m.protrusion_average_list = lmer(I(protrusion_average) ~ sound*vowel*list + (1|participant), data = data)
anova(m.protrusion_average,m.protrusion_average_list) # list did not matter
summary(m.protrusion_average)
ranova(m.protrusion_average)

emmeans = emmeans(m.protrusion_average, pairwise ~ sound)
summary(emmeans, adjustment = "tukey")$contrast
summary(emmeans, adjustment = "tukey")
emmeans = emmeans(m.protrusion_average, pairwise ~ sound|vowel)
summary(emmeans, adjustment = "tukey")$contrast
emmeans = emmeans(m.protrusion_average, pairwise ~ vowel|sound)
summary(emmeans, adjustment = "tukey")$contrast


#### dynamic measures ####

long_F3 = data %>% 
  pivot_longer(
    cols = `F3_1`:`F3_10`, 
    names_to = "timestep",
    values_to = "F3_point")
long_F3$timestep = gsub("F3_","",long_F3$timestep)
long_F3$timestep = as.numeric(long_F3$timestep)
long_F3$sound = factor(long_F3$sound)
long_F3$vowel = factor(long_F3$vowel)
long_F3$participant = factor(long_F3$participant)
gam_model = gam(F3_point ~ s(timestep, by = sound:vowel, k = 5) + sound * vowel +
                  s(timestep, participant, bs = "fs", k = 5), data = long_F3)
summary(gam_model)

three_opening = data %>% 
  pivot_longer(
    cols = `opening_starting`:`opening_ending`, 
    names_to = "timestep",
    values_to = "opening_point"
  )
three_opening$timestep = factor(three_opening$timestep, levels = c("opening_starting","opening_centroid","opening_ending"), labels = c(1,2,3))
three_opening$timestep = as.numeric(three_opening$timestep)
three_opening$sound = factor(three_opening$sound)
three_opening$vowel = factor(three_opening$vowel)
quad_model_opening = lmer(opening_point ~ (1 + timestep + I(timestep^2)) * sound * vowel + (1|participant), data = three_opening)
summary(quad_model_opening)
emm = emmeans(quad_model_opening, ~ sound, at = list(timestep = c(1,2,3)))
pairs(emm, adjust = "tukey")
pairs(emtrends(quad_model_opening, specs = ~ vowel, by = "sound", var = "timestep", max.degree = 2), degree = 2, adjust = "tukey")
pairs(emmeans(quad_model_opening, specs = ~ vowel, by = "sound", at = list(timestep = 1)), adjust = "tukey")
pairs(emmeans(quad_model_opening, specs = ~ vowel, by = "sound", at = list(timestep = 2)), adjust = "tukey")
pairs(emmeans(quad_model_opening, specs = ~ vowel, by = "sound", at = list(timestep = 3)), adjust = "tukey")

three_spreading = data %>% 
  pivot_longer(
    cols = `spread_starting`:`spread_ending`, 
    names_to = "timestep",
    values_to = "spread_point"
  )
three_spreading$timestep = factor(three_spreading$timestep, levels = c("spread_starting","spread_centroid","spread_ending"), labels = c(1,2,3))
three_spreading$timestep = as.numeric(three_spreading$timestep)
three_spreading$sound = factor(three_spreading$sound)
three_spreading$vowel = factor(three_spreading$vowel)
quad_model_spreading = lmer(spread_point ~ (1 + timestep + I(timestep^2)) * sound * vowel + (1|participant), data = three_spreading)
summary(quad_model_spreading)
emm = emmeans(quad_model_spreading, ~ sound, at = list(timestep = c(1,2,3)))
pairs(emm, adjust = "tukey")
emm = emmeans(quad_model_spreading, ~ sound||vowel, at = list(timestep = c(1,2,3)))
pairs(emm, adjust = "tukey")
pairs(emmeans(quad_model_spreading, specs = ~ vowel, by = "sound", at = list(timestep = 1)), adjust = "tukey")
pairs(emmeans(quad_model_spreading, specs = ~ vowel, by = "sound", at = list(timestep = 2)), adjust = "tukey")
pairs(emmeans(quad_model_spreading, specs = ~ vowel, by = "sound", at = list(timestep = 3)), adjust = "tukey")

three_protrusion = data %>% 
  pivot_longer(
    cols = `protrusion_starting`:`protrusion_ending`, 
    names_to = "timestep",
    values_to = "protrusion_point"
  )
three_protrusion$timestep = factor(three_protrusion$timestep, levels = c("protrusion_starting","protrusion_centroid","protrusion_ending"), labels = c(1,2,3))
three_protrusion$timestep = as.numeric(three_protrusion$timestep)
three_protrusion$sound = factor(three_protrusion$sound)
three_protrusion$vowel = factor(three_protrusion$vowel)
quad_model_protrusion = lmer(protrusion_point ~ (1 + timestep + I(timestep^2)) * sound * vowel + (1|participant), data = three_protrusion)
summary(quad_model_protrusion)
emm = emmeans(quad_model_protrusion, ~ sound, at = list(timestep = c(1,2,3)))
pairs(emm, adjust = "tukey")
pairs(emmeans(quad_model_protrusion, specs = ~ vowel, by = "sound", at = list(timestep = 1)), adjust = "tukey")
pairs(emmeans(quad_model_protrusion, specs = ~ vowel, by = "sound", at = list(timestep = 2)), adjust = "tukey")
pairs(emmeans(quad_model_protrusion, specs = ~ vowel, by = "sound", at = list(timestep = 3)), adjust = "tukey")


#### articulation-acoustic mapping ####

m.F3_opening = lmer(F3 ~ opening_average * sound * vowel + (1 + opening_average|participant), data = data)
summary(m.F3_opening)
anova(m.F3_opening)
contrast = emtrends(m.F3_opening, ~sound*vowel, var = "opening_average", method = "pairwise")
summary(contrast, infer=c(T,T), adjust = "BH")

m.F3_spreading = lmer(F3 ~ spread_average * sound * vowel + (1 + spread_average|participant), data = data)
summary(m.F3_spreading)
anova(m.F3_spreading)
contrast = emtrends(m.F3_spreading, ~sound*vowel, var = "spread_average", method = "pairwise")
summary(contrast, infer=c(T,T), adjust = "BH")

m.F3_protrusion = lmer(F3 ~ protrusion_average * sound * vowel + (1 + protrusion_average|participant), data = data)
summary(m.F3_protrusion)
anova(m.F3_protrusion)
contrast = emtrends(m.F3_protrusion, ~sound*vowel, var = "protrusion_average", method = "pairwise")
summary(contrast, infer=c(T,T), adjust = "BH")