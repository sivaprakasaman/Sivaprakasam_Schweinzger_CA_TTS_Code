# data_dir <- "data";
cwd <- getwd();

# setwd(data_dir);

## Installing Dependencies & Importing Libraries
list.of.packages <- c('ggplot2', 'dplyr','corrplot','PerformanceAnalytics','nloptr','lme4','tidyr','car','ggpubr','emmeans','gridExtra','grid','cowplot')
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

lapply(list.of.packages,library, character.only=TRUE)

#Color definitions
base_c = "gray20"
CA_c="#D95319"
TTS_c="#0072BD"


#Plotting Theme Defn
# mean_std_theme_chin <- function(base = base_c, TTS = TTS_c, CA = CA_c, legend_on=FALSE) {
#   # Define the original levels and their corresponding colors/shapes
#   lvl <- c("0.CA", "0.TTS", "0.PTS", "2.CA", "2.TTS")
#   val_col <- c("0.CA"=base, "0.TTS"=base, "0.PTS"=base, "2.CA"=CA, "2.TTS"=TTS)
#   val_shp <- c("0.CA"=16, "0.TTS"=16, "0.PTS"=16, "2.CA"=17, "2.TTS"=17)
#   
#   list(
#     #geom_boxplot(position = position_identity(),outlier.shape=NA,alpha=0.3,show.legend = FALSE),
#     geom_point(position = position_jitterdodge(), size=1.75, alpha = 0.3,show.legend = TRUE),
#     theme_pubclean(),
#     scale_color_manual(values = c(
#       "0.CA" = base,
#       "0.TTS" = base,
#       "2.CA" = CA,
#       "2.TTS" = TTS),
#       breaks = c("0.CA", "2.CA", "2.TTS"), # Only show ONE baseline level
#       labels = c("Baseline", "CA", "TTS")), 
#     
#     scale_fill_manual(values = c(
#       "0.CA" = base,
#       "0.TTS" = base,
#       "2.CA" = CA,
#       "2.TTS" = TTS),
#       breaks = c("0.CA", "2.CA", "2.TTS"), # Only show ONE baseline level
#       labels = c("Baseline", "CA", "TTS")),   # Map them to these names),
#     
#     guides(
#       color = guide_legend(override.aes = list(linetype = 0, shape = c(16, 17, 17))),
#       fill = guide_legend(override.aes = list(linetype = 0)),
#       shape = guide_legend(override.aes = list(linetype = 0))
#     ),
#     
#     if(legend_on)
#       theme(
#         legend.position = "bottom",
#         text = element_text(size = 15), 
#         plot.margin = margin(t = .55, r = .55, b = .55, l = .55, unit = "cm")
#       )
#     else
#       theme(
#         legend.position = "none",
#         plot.margin = margin(t = .55, r = .55, b = .55, l = .55, unit = "cm")
#       )
#     
#   )
# }

mean_std_theme_chin <- function(base = base_c, TTS = TTS_c, CA = CA_c, legend_on = FALSE) {
  
  d_width <- 0.75
  plot_breaks <- c("0.CA", "2.CA", "2.TTS")
  plot_labels <- c("Baseline", "CA", "TTS")
  
  list(
    # 1. Individual Data Points
    geom_point(
      # We map shape here to ensure points on the plot match the treatment
      aes(shape = interaction(Exposed, Group)), 
      position = position_jitterdodge(jitter.width = 0.1, dodge.width = d_width),
      size = 1.75, 
      alpha = 0.5, 
      show.legend = FALSE
    ),
    
    # 2. Mean Point
    stat_summary(
      # Mapping shape here ensures the mean icons are correct
      aes(shape = interaction(Exposed, Group)),
      fun = mean,
      geom = "point",
      size = 4,
      alpha = .8,
      position = position_dodge(width = d_width),
      show.legend = TRUE 
    ),
    
    # 3. Standard Error Bars (SEM)
    stat_summary(
      fun.min = function(x) mean(x) - (sd(x) / sqrt(length(x))),
      fun.max = function(x) mean(x) + (sd(x) / sqrt(length(x))),
      geom = "errorbar",
      width = 0.2,
      linewidth = 1,
      alpha = .8,
      position = position_dodge(width = d_width),
      show.legend = FALSE
    ),
    
    theme_pubclean(),
    
    # Map interaction levels to colors
    scale_color_manual(
      values = c("0.CA" = base, "0.TTS" = base, "0.PTS" = base, "2.CA" = CA, "2.TTS" = TTS),
      breaks = plot_breaks,
      labels = plot_labels
    ),
    
    # Custom shapes for each group: 16=Circle, 17=Triangle, 18=Diamond
    scale_shape_manual(
      values = c("0.CA" = 16, "0.TTS" = 16, "0.PTS" = 16, "2.CA" = 17, "2.TTS" = 18),
      breaks = plot_breaks,
      labels = plot_labels
    ),
    
    guides(
      color = guide_legend(
        override.aes = list(
          alpha = 1, 
          size = 4, 
          # Ensure legend reflects different shapes: Baseline, CA, TTS
          shape = c(16, 17, 18) 
        )
      ),
      shape = "none", # Hide the redundant shape legend
      fill = "none"
    ),
    
    if(legend_on)
      theme(
        legend.position = "bottom",
        legend.title = element_blank(),
        text = element_text(size = 15), 
        plot.margin = margin(t = .55, r = .55, b = .55, l = .55, unit = "cm")
      )
    else
      theme(
        legend.position = "none",
        plot.margin = margin(t = .55, r = .55, b = .55, l = .55, unit = "cm")
      )
  )
}

summary_theme_chin <- function(base = base_c, TTS = TTS_c, CA = CA_c, legend_on = FALSE, error_type = "sd") {
  
  # Standardize dodge width for alignment
  d_width <- 0.75
  
  # Determine error bar function based on choice
  # "mean_sdl" with mult=1 is Mean +/- 1 SD
  # "mean_se" is Mean +/- 1 SE
  err_fun <- if(error_type == "sd") "mean_sdl" else "mean_se"
  fun_args <- if(error_type == "sd") list(mult = 1) else list()
  
  list(
    # 1. Individual Data Points (Jittered)
    geom_point(
      aes(color = Group, shape = Group),
      position = position_jitterdodge(jitter.width = 0.1, dodge.width = d_width),
      size = 1.75, 
      alpha = 0.3, 
      show.legend = FALSE # Points don't need their own legend entries
    ),
    
    # 2. Mean Point (Central tendency)
    stat_summary(
      aes(color = Group, group = Group),
      fun = "mean", 
      geom = "point", 
      size = 4, 
      position = position_dodge(width = d_width),
      show.legend = TRUE # Legend is driven by these central points
    ),
    
    # 3. Error Bars (SD or SEM)
    stat_summary(
      aes(color = Group, group = Group),
      fun.data = err_fun, 
      fun.args = fun_args,
      geom = "errorbar", 
      width = 0.2, 
      linewidth = 1,
      position = position_dodge(width = d_width)
    ),
    
    theme_pubclean(),
    
    # Color mapping: Collapses 0.CA and 0.TTS into "Baseline"
    scale_color_manual(
      values = c("0.CA" = base, "0.TTS" = base, "0.PTS" = base, "2.CA" = CA, "2.TTS" = TTS),
      breaks = c("0.CA", "2.CA", "2.TTS"), 
      labels = c("Baseline", "CA", "TTS")
    ),
    
    # Shape mapping: Matches your original shapes
    scale_shape_manual(
      values = c("0.CA" = 16, "0.TTS" = 16, "0.PTS" = 16, "2.CA" = 17, "2.TTS" = 17),
      breaks = c("0.CA", "2.CA", "2.TTS"),
      labels = c("Baseline", "CA", "TTS")
    ),
    
    guides(
      color = guide_legend(override.aes = list(size = 4, alpha = 1)),
      shape = guide_legend(override.aes = list(size = 4, alpha = 1))
    ),
    
    theme(
      legend.position = if(legend_on) "bottom" else "none",
      text = element_text(size = 15),
      legend.title = element_blank(),
      plot.margin = margin(t = .55, r = .55, b = .55, l = .55, unit = "cm")
    )
  )
}
scatter_theme_chin <- function(label.x = Inf, label.y = Inf, vjust = 1, hjust = 1, base = base_c, TTS = TTS_c, CA = CA_c, legend_on = TRUE) {
  
  # Define the original levels and their corresponding colors/shapes
  lvl <- c("0.CA", "0.TTS", "0.PTS", "2.CA", "2.TTS")
  val_col <- c("0.CA"=base, "0.TTS"=base, "0.PTS"=base, "2.CA"=CA, "2.TTS"=TTS)
  val_shp <- c("0.CA"=16, "0.TTS"=16, "0.PTS"=16, "2.CA"=17, "2.TTS"=18)
  
  list(
    geom_point(size=4, alpha = 0.9),
    theme_pubclean(),
    geom_smooth(aes(group = 1), method='lm', se = TRUE,show.legend = FALSE),
    ggpubr::stat_cor(aes(group = 1), label.x = label.x, label.y = label.y, size=6, vjust = vjust, hjust = hjust, show.legend=FALSE),
    
    # Color Scale: Notice the 'breaks' and 'labels' match lengths
    scale_color_manual(
      name = "",
      values = val_col,
      breaks = c("0.CA", "2.CA", "2.TTS"), # Only show ONE baseline level
      labels = c("Baseline", "CA", "TTS")   # Map them to these names
    ),
    
    scale_fill_manual(
      name = "",
      values = val_col,
      breaks = c("0.CA", "2.CA", "2.TTS"),
      labels = c("Baseline", "CA", "TTS")
    ),
    
    scale_shape_manual(
      name = "",
      values = val_shp,
      breaks = c("0.CA", "2.CA", "2.TTS"),
      labels = c("Baseline", "CA", "TTS")
    ),
    
    # This removes the horizontal line through the legend points
    guides(
      color = guide_legend(override.aes = list(linetype = 0, shape = c(16, 17, 18))),
      fill = guide_legend(override.aes = list(linetype = 0)),
      shape = guide_legend(override.aes = list(linetype = 0))
    ),
    
    if(legend_on)
      theme(
        legend.position = "bottom",
        text = element_text(size = 15), 
        plot.margin = margin(t = .55, r = .55, b = .55, l = .55, unit = "cm")
      )
    else
      theme(
        legend.position = "none",
        plot.margin = margin(t = .55, r = .55, b = .55, l = .55, unit = "cm")
      )
    
  )
}


save_fig <- function(fig_title,fig_handle, width = 10, height = 5, units = "in"){
  fname <- paste("figures/",fig_title,sep='')
  ggsave(fname,plot = fig_handle, width = width, height = height, units = units, bg="white",dpi=330)
}  

#loading data
all_data <- read.csv("all_ca_tts_data_updatedThreshold_Peaks.csv");
all_data$Chin <- as.factor(all_data$Chin);
all_data$Group <- as.factor(all_data$Group);
all_data$Sex <- as.factor(all_data$Sex);
all_data$Exposed <- as.factor(all_data$Exposed)


#binning dpoae into HF and LF 

all_data <- all_data %>%
  mutate(DP_LF = rowMeans(across(c("F2_921","F2_1041","F2_1176","F2_1329","F2_1502","F2_1698","F2_1918")), na.rm = T)) %>%
  mutate(DP_MF = rowMeans(across(c("F2_2168","F2_2449","F2_2768","F2_3128","F2_3535","F2_3994")), na.rm = T)) %>%
  mutate(DP_HF = rowMeans(across(c("F2_2449","F2_2768","F2_3128","F2_3535","F2_3994","F2_4513","F2_5100","F2_5763","F2_6513","F2_7359","F2_8316","F2_9397","F2_10619","F2_12000")), na.rm = T))
  
  
#Removing the 24 hr time point for TTS
all_data_pre_post = all_data[all_data$Exposed!=1,]

#---- ABR ----

dat_text <- data.frame(
  label = c("*"),
  Group = "TTS",
  x     = c(1),
  y     = c(60)
)

#Threshold
abr_thresh_click <- ggplot(all_data_pre_post,aes(x=1, y=Click_Threshold, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  ylab("ABR Threshold (dB SPL)")+
  xlab("Click")+
  labs(color="Group")+
  ylim(0,100)+
  geom_text(
    data    = dat_text,
    mapping = aes(x = x, y = y, label = label),
    size = 10,
    inherit.aes = FALSE, # Prevents it from looking for 'Exposed' or 'color'
  )
  
abr_thresh_click
m_abr_click_thresh <- lmer(Click_Threshold~ Group*Exposed + (1|Chin), data = all_data_pre_post)
Anova(m_abr_click_thresh,test.statistic = 'F')

emm_model_click_thresh <- emmeans(m_abr_click_thresh, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_click_thresh)
summary(pairwise_results,adjust = "Tukey")

#Summary-- Threshold decrease (lol) after TTS exposure (significant on contrasts, p = 0.035)-- drives the model's group*exposure interaction
# CA doesn't result in any threshold shift. 

abr_thresh_4k <- ggplot(all_data_pre_post,aes(x=1, y=X4k_Threshold, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  ylab("ABR Threshold (dB SPL)")+
  xlab("4k")+
  ylim(0,100)

abr_thresh_4k


abr_thresh <- ggarrange(abr_thresh_click, abr_thresh_4k, nrow=1);
save_fig('ABR_thresh_CA_v_TTS.png',abr_thresh, width = 10, height = 6, units = "in")

m_abr_4k_thresh <- lmer(X4k_Threshold~ Group*Exposed + (1|Chin), data = all_data_pre_post)
Anova(m_abr_4k_thresh,test.statistic = 'F')

emm_model_4k_thresh <- emmeans(m_abr_4k_thresh, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_4k_thresh)
summary(pairwise_results,adjust = "Tukey")

## Summary-- No significant changes due to exposure/group (either model or contrasts) 

# Wave I (Check Amp AND Latency)

#4k
#Amplitude
#Quick Plot

abr_W1_amp_4k <- ggplot(all_data_pre_post,aes(x=1, y=X4k_P1, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")
# ylim(0,100)

abr_W1_amp_4k

m_abr_W1_amp_4k <- lmer(X4k_P1~ Group*Exposed + (1|Chin), data = all_data_pre_post)
Anova(m_abr_W1_amp_4k,test.statistic = 'F')

emm_model_4k_amp <- emmeans(m_abr_W1_amp_4k, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_4k_amp)
summary(pairwise_results,adjust = "Tukey")

#Latency
abr_W1_lat_4k <- ggplot(all_data_pre_post,aes(x=1, y=X4k_P1_Latency, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")
  # ylim(0,100)

abr_W1_lat_4k

m_abr_W1_lat_4k <- lmer(X4k_P1_Latency~ Group*Exposed + (1|Chin), data = all_data_pre_post)
Anova(m_abr_W1_lat_4k,test.statistic = 'F')

emm_model_4k_lat <- emmeans(m_abr_W1_lat_4k, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_4k_lat)
summary(pairwise_results,adjust = "Tukey")

#Summary - 4k Amplitude reduced (CA), but non-significantly (no effect of group*exposure). 
#Contrast shows it's close maybe (p=0.1). No significant change in latency. Keep in mind this is at the individual level.

#Click
#Amplitude
#Quick Plot

abr_W1_amp_c <- ggplot(all_data_pre_post,aes(x=1, y=Click_P1, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")
# ylim(0,100)
abr_W1_amp_c

m_abr_W1_amp_c <- lmer(Click_P1~ Group*Exposed + (1|Chin), data = all_data_pre_post)
Anova(m_abr_W1_amp_c,test.statistic = 'F')

emm_model_c_amp <- emmeans(m_abr_W1_amp_c, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_c_amp)
summary(pairwise_results,adjust = "Tukey")

#Latency

abr_W1_lat_c <- ggplot(all_data_pre_post,aes(x=1, y=Click_P1_Latency, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")
# ylim(0,100)
abr_W1_lat_c

m_abr_W1_lat_c <- lmer(Click_P1_Latency~ Group*Exposed + (1|Chin), data = all_data_pre_post)
Anova(m_abr_W1_lat_c, test.statistic = 'F')

emm_model_c_lat <- emmeans(m_abr_W1_lat_c, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_c_lat)
summary(pairwise_results,adjust = "Tukey")

#Summary -- Nothing significant here. Though again, same trend. Reduced ABR amplitude, particularly for CA. 
# Just not significant

# Wave V (Check Amp AND Latency)
#Amplitude
#Quick Plot

abr_W5_amp_c <- ggplot(all_data_pre_post,aes(x=1, y=Click_P5, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")
# ylim(0,100)
abr_W5_amp_c

# m_abr_W5_amp_c <- lmer(Click_P5~ Group*Exposed + (1|Chin), data = all_data_pre_post)
# Anova(m_abr_W5_amp_c,test.statistic = 'F')
# 
# emm_model_c_amp_5 <- emmeans(m_abr_W5_amp_c, ~ Group*Exposed)
# pairwise_results <- pairs(emm_model_c_amp_5)
# summary(pairwise_results,adjust = "Tukey")
# 
# #Summary, nothing significant. Click W5 no changes for both

#Latency

abr_W5_lat_c <- ggplot(all_data_pre_post,aes(x=1, y=Click_P5_Latency, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")
# ylim(0,100)
abr_W5_lat_c

# m_abr_W5_lat_c <- lmer(Click_P5_Latency~ Group*Exposed + (1|Chin), data = all_data_pre_post)
# Anova(m_abr_W5_lat_c, test.statistic = 'F')
# 
# emm_model_c_lat_5 <- emmeans(m_abr_W5_lat_c, ~ Group*Exposed)
# pairwise_results <- pairs(emm_model_c_lat_5)
# summary(pairwise_results,adjust = "Tukey")

#Summary: Longer wave V latencies for both. Just not significant...but approaching significance.

#4k

#Amplitude
abr_W5_amp_4k <- ggplot(all_data_pre_post,aes(x=1, y=X4k_P5, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")
# ylim(0,100)
abr_W5_amp_4k

# m_abr_W5_amp_4k <- lmer(X4k_P5~ Group*Exposed + (1|Chin), data = all_data_pre_post)
# Anova(m_abr_W5_amp_4k, test.statistic = 'F')
# 
# emm_model_4k_amp_5 <- emmeans(m_abr_W5_amp_4k, ~ Group*Exposed)
# pairwise_results <- pairs(emm_model_4k_amp_5)
# summary(pairwise_results,adjust = "Tukey")

#Summary -- No statistically significant changes pre/post/group/exposure. Amplitude remains roughly the same.

#Latency
abr_W5_lat_4k <- ggplot(all_data_pre_post,aes(x=1, y=X4k_P5_Latency, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")
# ylim(0,100)
abr_W5_lat_4k

m_abr_W5_lat_4k <- lmer(X4k_P5_Latency~ Group*Exposed + (1|Chin), data = all_data_pre_post)
Anova(m_abr_W5_lat_4k, test.statistic = 'F')

emm_model_4k_lat_5 <- emmeans(m_abr_W5_lat_4k, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_4k_lat_5)
summary(pairwise_results,adjust = "Tukey")

#Summary -- 4k ABR Wave 5 significantly different based on exposure main effect. Driven mostly by CA. 
# Contrasts reveal almost significant (p=0.064) for CA pre vs post

# Wave V/1 Ratio

all_data_pre_post$w51rat_c <- abs(all_data_pre_post$Click_P5)/abs(all_data_pre_post$Click_P1);
all_data_pre_post$w51rat_4k <- abs(all_data_pre_post$X4k_P5)/abs(all_data_pre_post$X4k_P1);

#Click
#Significance Star
dat_text <- data.frame(
  label = c("*"),
  Group = "CA",
  x     = c(1),
  y     = c(4)
)

abr_rat_c <- ggplot(all_data_pre_post,aes(x=1, y=w51rat_c, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Click")+
  ylab("Wave V/I Ratio")+
  ylim(0,5)

abr_rat_c = abr_rat_c+geom_text(
  data    = dat_text,
  mapping = aes(x = x, y = y, label = label),
  size = 10,
  inherit.aes = FALSE, # Prevents it from looking for 'Exposed' or 'color'
)


m_abr_rat_c <- lmer(w51rat_c~ Group*Exposed + (1|Chin), data = all_data_pre_post)
Anova(m_abr_rat_c, test.statistic = 'F')

emm_model_abr_rat_c <- emmeans(m_abr_rat_c, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_abr_rat_c)
summary(pairwise_results,adjust = "Tukey")

#Summary Wave V/1 Ratio significant exposure and group*exposure interaction, 
# driven by CA being significantly elevated after exposure (contrast also significant, p=0.029)

#4k
abr_rat_4k <- ggplot(all_data_pre_post,aes(x=1, y=w51rat_4k, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("4k")+
  ylab("Wave V/I Ratio")+
  ylim(0,5)

m_abr_rat_4k <- lmer(w51rat_4k~ Group*Exposed + (1|Chin), data = all_data_pre_post)
Anova(m_abr_rat_4k, test.statistic = 'F')

emm_model_abr_rat_4k <- emmeans(m_abr_rat_4k, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_abr_rat_4k)
summary(pairwise_results,adjust = "Tukey")

#Summary: Not significant for 4k...looks like a CA outlier being negative is the issue. 


## Summative ABR Plot for Publication

abr_summative <- ggarrange(abr_thresh_click, abr_thresh_4k, abr_rat_c, abr_rat_4k, nrow=2, ncol=2,labels = c("A","B","C","D"),common.legend = TRUE,legend="bottom")
final_plot <- ggdraw(abr_summative) +
  draw_label("*", x = 0.77, y = 0.4, size = 25, fontface = "bold")+
  draw_line(
    x = c(0.65, 0.88), y = c(0.39, 0.39), 
    color = "black", size = 0.8
  )

# View the result
final_plot

save_fig("abr_summative.png", abr_summative, width = 8, height = 8, units = "in")


## DPOAE Plots & Stats
dp_reshaped <- all_data_pre_post %>%
  pivot_longer(cols = F2_500:F2_12000, 
               names_to = c(".value","Freq"),
               names_pattern = "(F2)_(\\d+)")


dp_reshaped$FreqRange <- factor(dp_reshaped$Freq, 
                                 levels = c(500,565,638,721,815,921,1041,1176,1329,1502,1698,1918,2168,2449,2768,3128,3535,3994,4513,4100,5100,5763,6513,7359,8316,9397,10619,12000));

dp_oae_plot <- ggplot(dp_reshaped,aes(x=FreqRange, y=F2, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin(legend_on=TRUE)+
  ylab("F2 Frequency Amplitude (dB SPL)")+
  xlab("Frequency (Hz)")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  ylim(0,55)
dp_oae_plot

save_fig("DPOAE_CA_v_TTS.png", dp_oae_plot, width = 10, height = 6, units = "in")


#F2 here is just the DPOAE amplitude...after reshaped
m_dp <- lmer(F2 ~ Group*Freq*Exposed + (1|Chin), data = dp_reshaped)
Anova(m_dp,test.statistic = 'F')

emm_model_m_dp <- emmeans(m_dp, ~ Group*Exposed*Freq)
pairwise_results <- pairs(emm_model_m_dp)
summary(pairwise_results,adjust = "Tukey")

#Mean difference

summary_df <- dp_reshaped %>%
  group_by(Group, Freq, Exposed) %>%
  summarise(mean_response = mean(F2)) %>%
  ungroup()

difference_df <- summary_df %>%
  pivot_wider(names_from = Exposed, values_from = mean_response) %>%
  rename(`Exposure_0` = `0`, `Exposure_2` = `2`) %>% # Rename columns for clarity
  mutate(difference = Exposure_2 - Exposure_0)

mean_both_diff = mean(abs(difference_df$difference), na.rm=T);

ca_diff_only = difference_df[difference_df$Group == 'CA',];
tts_diff_only = difference_df[difference_df$Group == 'TTS',];

mean_ca_diff = mean(ca_diff_only$difference, na.rm=T);
mean_tts_diff = mean(tts_diff_only$difference, na.rm=T);


#Checking TTS pre vs 24 hours post
all_data_tts = all_data[all_data$Group=='TTS',]
all_tts_pre_24hr = all_data_tts[all_data_tts$Exposed!=2,];

dp_reshaped_tts24 <- all_tts_pre_24hr %>%
  pivot_longer(cols = F2_500:F2_12000, 
               names_to = c(".value","Freq"),
               names_pattern = "(F2)_(\\d+)")


dp_reshaped_tts24$FreqRange <- factor(dp_reshaped_tts24$Freq, 
                                levels = c(500,565,638,721,815,921,1041,1176,1329,1501,1698,1918,2168,2449,2768,3128,3535,3994,4513,4100,5763,6513,7359,8316,9397,10619,12000));

summary_df <- dp_reshaped_tts24 %>%
  group_by(Group, Freq, Exposed) %>%
  summarise(mean_response = mean(F2)) %>%
  ungroup()

difference_df_tts24 <- summary_df %>%
  pivot_wider(names_from = Exposed, values_from = mean_response) %>%
  rename(`Exposure_0` = `0`, `Exposure_1` = `1`) %>% # Rename columns for clarity
  mutate(difference = Exposure_1 - Exposure_0)

mean_tts24_diff = mean(difference_df_tts24$difference, na.rm=T);


#checking plot
dp_oae_plot_tts24 <- ggplot(dp_reshaped_tts24,aes(x=FreqRange, y=F2, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")+
  ylim(0,55)
dp_oae_plot_tts24

m_dp_tts24 <- lmer(F2 ~ Freq*Exposed + (1|Chin), data = dp_reshaped_tts24)
Anova(m_dp_tts24,test.statistic = 'F')

#Averaged into smaller bands
dp_LF_plot <- ggplot(all_data,aes(x=1, y=DP_LF, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")+
  ylim(0,75)
dp_LF_plot

m_dp_lf <- lmer(DP_LF ~ Group*Exposed + (1|Chin), data = all_data_pre_post)
Anova(m_dp_lf,test.statistic = 'F')

emm_model_m_dp_lf <- emmeans(m_dp_lf, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_m_dp_lf)
summary(pairwise_results,adjust = "Tukey")


dp_MF_plot <- ggplot(all_data,aes(x=1, y=DP_MF, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")+
  ylim(0,75)
dp_MF_plot

m_dp_mf <- lmer(DP_MF ~ Group*Exposed + (1|Chin), data = all_data_pre_post)
Anova(m_dp_mf,test.statistic = 'F')

emm_model_m_dp_mf <- emmeans(m_dp_mf, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_m_dp_mf)
summary(pairwise_results,adjust = "Tukey")

dp_HF_plot <- ggplot(all_data,aes(x=1, y=DP_HF, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")+
  ylim(0,75)
dp_HF_plot

m_dp_hf <- lmer(DP_HF ~ Group*Exposed + (1|Chin), data = all_data_pre_post)
Anova(m_dp_hf,test.statistic = 'F')

emm_model_m_dp_hf <- emmeans(m_dp_hf, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_m_dp_hf)
summary(pairwise_results,adjust = "Tukey")

#Summary-- Exposure effect isn't significant. But the Group*exposed interaction is significant, suggesting the trends are in opposite direction, cancelling out the main effect.
# It can be seen from the plots that the changes are quite marginal, just slight 

#MEMR Plots & Stats
mem_reshaped <- all_data_pre_post %>%
  pivot_longer(cols = elicit_dbspl_34:elicit_dbspl_94, 
               names_to = c(".value","Level"),
               names_pattern = "(elicit_dbspl)_(\\d+)")

mem_reshaped$Level <- factor(mem_reshaped$Level, 
                                levels = c(34,40,46,52,58,64,70,76,82,88,94))
mem_plot <- ggplot(mem_reshaped,aes(x=Level, y=elicit_dbspl, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  ylab("MEMR Strength (dB ΔAbsorbed Power)")+
  xlab("Elicitor Level (dB SPL)")+
  ylim(0,4)
mem_plot
save_fig("MEMR_CA_v_TTS.png", mem_plot, width = 10, height = 6, units = "in")

m_mem <- lmer(elicit_dbspl ~ Group*Level*Exposed + (1|Chin), data = mem_reshaped)
Anova(m_mem,test.statistic = 'F')
#Model Summary -- Level, Exposure, Group*Exposure, Level*Exposure, three-way interaction all significant...

MEMR_amp_plt <- ggplot(all_data_pre_post,aes(x=1, y=elicit_dbspl_94, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")
  # ylim(2.5,7.5)
MEMR_amp_plt

#Reflex threshold is more informative...concise I think
MEMR_thresh_plt <- ggplot(all_data_pre_post,aes(x=1, y=Threshold, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin(legend_on=TRUE)+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")+
  ylim(50,100)
MEMR_thresh_plt
save_fig("MEMR_Thresh_CA_v_TTS.png", MEMR_thresh_plt, width = 10, height = 10, units = "in")


m_mem_thresh <- lmer(Threshold ~ Group*Exposed + (1|Chin), data = all_data_pre_post)
Anova(m_mem_thresh,test.statistic = 'F')

emm_model_mem_thresh <- emmeans(m_mem_thresh, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_mem_thresh)
summary(pairwise_results,adjust = "Tukey")

memr_combined <- ggarrange(mem_plot,MEMR_thresh_plt,widths=c(2,1),nrow=1,labels=c("A","B"))
save_fig("memr_combined.png",memr_combined)

## MEMR 24 hours post:
MEMR_thresh_plt_tts24 <- ggplot(all_tts_pre_24hr,aes(x=1, y=Threshold, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")
# ylim(2.5,7.5)
MEMR_thresh_plt_tts24

m_mem_thresh_tts24 <- lmer(Threshold ~ Exposed + (1|Chin), data = all_tts_pre_24hr)
Anova(m_mem_thresh_tts24,test.statistic = 'F')

#No significant change between pre and 24 hour post TTS threshold.

mem_reshaped_tts24 <- all_tts_pre_24hr %>%
  pivot_longer(cols = elicit_dbspl_34:elicit_dbspl_94, 
               names_to = c(".value","Level"),
               names_pattern = "(elicit_dbspl)_(\\d+)")

mem_reshaped_tts24$Level <- factor(mem_reshaped_tts24$Level, 
                             levels = c(34,40,46,52,58,64,70,76,82,88,94))
mem_plot_tts24 <- ggplot(mem_reshaped_tts24,aes(x=Level, y=elicit_dbspl, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")+
  ylim(0,4)
mem_plot_tts24

m_mem_tts24 <- lmer(elicit_dbspl ~ Level*Exposed + (1|Chin), data = mem_reshaped_tts24)
Anova(m_mem_tts24,test.statistic = 'F')

emm_model_mem_thresh <- emmeans(m_mem_thresh, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_mem_thresh)
summary(pairwise_results,adjust = "Tukey")

#Summary-- Significant effect of exposure. But nothing significant on contrast...sample size probably too low.


#R_PLV Dependence on Group/TimePoint

R_PLV_plot_25 <- ggplot(all_data_pre_post,aes(x=1, y=R_PLV_SQ25, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")+
  ylim(2,7.5)


R_PLV25_m <- lmer(R_PLV_SQ25~ Group*Exposed+(1|Chin),data = all_data_pre_post)
Anova(R_PLV25_m, test.statistic='F')

emm_model_R_PLV25_m <- emmeans(R_PLV25_m, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_R_PLV25_m)
summary(pairwise_results,adjust = "Tukey")

R_PLV_plot_50 <- ggplot(all_data_pre_post,aes(x=1, y=R_PLV_SQ50, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")+
  ylim(2,7.5)

R_PLV50_m <- lmer(R_PLV_SQ50~ Group*Exposed+(1|Chin),data = all_data_pre_post)
Anova(R_PLV50_m, test.statistic='F')

emm_model_R_PLV50_m <- emmeans(R_PLV50_m, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_R_PLV50_m)
summary(pairwise_results,adjust = "Tukey")

R_PLV_plot_SAM <- ggplot(all_data_pre_post,aes(x=1, y=R_PLV_SAM, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) + 
  facet_wrap(~Group)+
  mean_std_theme_chin()+
  theme(axis.text.x = element_blank(),axis.ticks.x = element_blank())+
  xlab("Group")+
  ylim(2,7.5)

R_PLVSAM_m <- lmer(R_PLV_SAM~ Group*Exposed+(1|Chin),data = all_data_pre_post)
Anova(R_PLVSAM_m, test.statistic='F')

emm_model_R_PLVSAM_m <- emmeans(R_PLVSAM_m, ~ Group*Exposed)
pairwise_results <- pairs(emm_model_R_PLVSAM_m)
summary(pairwise_results,adjust = "Tukey")

#Plot all three
r_plv_all <- ggarrange(R_PLV_plot_SAM,R_PLV_plot_50,R_PLV_plot_25, nrow=1)
save_fig("R_PLV_all.png", r_plv_all, width = 10, height = 6, units = "in")
  
#Summary: SQ25 - Group & Exposed (not interaction) significant, other two nothing significant (p>0.05). 
#Interesting that group is significant for SQ25...


#Correlations
R_25_vs_ABRW1_amp_4 <- ggplot(all_data_pre_post, aes(x = X4k_P1, y = R_PLV_SQ25, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin(label.x= .7, legend_on=FALSE)+
  labs(color="Group")+
  xlab("4k | ABR Wave I Amplitude (μV)")+
  ylab(bquote(R[PLV] ~ "SQ25"))+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
  #ylim(0,12)

R_25_vs_ABRW1_amp_c <- ggplot(all_data_pre_post, aes(x = Click_P1, y = R_PLV_SQ25, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin(legend_on=FALSE)+
  xlab("Click | ABR Wave I Amplitude (μV)")+
  ylab(bquote(R[PLV] ~ "SQ25"))+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
#ylim(0,12)

R_25_vs_ABRW1_amp = ggarrange(R_25_vs_ABRW1_amp_c,R_25_vs_ABRW1_amp_4,nrow=1,common.legend = TRUE,legend="bottom")
save_fig("ABRClick_vs_RAM.png", R_25_vs_ABRW1_amp, width = 10, height = 6, units = "in")

# R_25_vs_ABRW5_amp <- ggplot(all_data_pre_post, aes(x = X4k_P5, y = R_PLV_SQ25, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
#   scatter_theme_chin()+
#   theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# #ylim(0,12)
# R_25_vs_ABRW5_amp

# R_25_vs_ABRW1_lat <- ggplot(all_data_pre_post, aes(x = X4k_P1_Latency, y = R_PLV_SQ25, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
#   scatter_theme_chin()+
#   theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# #ylim(0,12)
# R_25_vs_ABRW1_lat
# 
# R_25_vs_ABRW5_lat <- ggplot(all_data_pre_post, aes(x = X4k_P5_Latency, y = R_PLV_SQ25, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
#   scatter_theme_chin()+
#   theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# #ylim(0,12)
# R_25_vs_ABRW5_lat

R_25_vs_mem_thresh <- ggplot(all_data_pre_post, aes(x = Threshold, y = R_PLV_SQ25, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin()+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
#ylim(0,12)
R_25_vs_mem_thresh

#Think on this!

# dp_model <- lmer(F2 ~ Group * Exposed + Freq + (1 | Chin), data = dp_reshaped)
# Anova(dp_model,test.statistic='F')
# adjusted_means <- emmeans(dp_model, ~ Group * Exposed)
# adjusted_means_df <- as.data.frame(adjusted_means)
#   
# 
# residuals <- resid(dp_model)

#clean_F0DL_SigMin <- lm(F0DL_SigMin_dB ~ AUD_LF,data = place_time_data_LF);
#place_time_data_LF$F0DL_sigMin_LF_resid <- resid(clean_F0DL_SigMin)

R_50_vs_ABRW1_amp <- ggplot(all_data_pre_post, aes(x = X4k_P1, y = R_PLV_SQ50, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin()+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
R_50_vs_ABRW1_amp

R_50_vs_ABRW1_amp_c <- ggplot(all_data_pre_post, aes(x = Click_P1, y = R_PLV_SQ50, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin()+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
R_50_vs_ABRW1_amp_c


R_SAM_vs_ABRW1_amp <- ggplot(all_data_pre_post, aes(x = X4k_P1, y = R_PLV_SAM, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin()+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
R_SAM_vs_ABRW1_amp

R_SAM_vs_ABRW1_amp_c <- ggplot(all_data_pre_post, aes(x = Click_P1, y = R_PLV_SAM, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin()+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
R_SAM_vs_ABRW1_amp_c

## DPOAE
R_25_vs_DPOAE_LF <- ggplot(all_data_pre_post, aes(x = DP_LF, y = R_PLV_SQ25, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin()+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
R_25_vs_DPOAE_LF

# R_25_vs_DPOAE_MF <- ggplot(all_data_pre_post, aes(x = DP_MF, y = R_PLV_SQ25, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
#   scatter_theme_chin()+
#   theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_25_vs_DPOAE_MF
# 
# R_25_vs_DPOAE_HF <- ggplot(all_data_pre_post, aes(x = DP_HF, y = R_PLV_SQ25, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
#   scatter_theme_chin()+
#   theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_25_vs_DPOAE_HF


# R_50_vs_DPOAE_LF <- ggplot(all_data_pre_post, aes(x = DP_LF, y = R_PLV_SQ50, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
#   scatter_theme_chin()+
#   theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_50_vs_DPOAE_LF
# 
# R_50_vs_DPOAE_MF <- ggplot(all_data_pre_post, aes(x = DP_MF, y = R_PLV_SQ50, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
#   scatter_theme_chin()+
#   theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_50_vs_DPOAE_MF
# 
# R_50_vs_DPOAE_HF <- ggplot(all_data_pre_post, aes(x = DP_HF, y = R_PLV_SQ50, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
#   scatter_theme_chin()+
#   theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_50_vs_DPOAE_HF

# R_SAM_vs_DPOAE_LF <- ggplot(all_data_pre_post, aes(x = DP_LF, y = R_PLV_SAM, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
#   scatter_theme_chin()+
#   theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_SAM_vs_DPOAE_LF
# 
# R_SAM_vs_DPOAE_MF <- ggplot(all_data_pre_post, aes(x = DP_MF, y = R_PLV_SAM, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
#   scatter_theme_chin()+
#   theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_SAM_vs_DPOAE_MF
# 
# R_SAM_vs_DPOAE_HF <- ggplot(all_data_pre_post, aes(x = DP_HF, y = R_PLV_SAM, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
#   scatter_theme_chin()+
#   theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_SAM_vs_DPOAE_HF

#Summary From DP correlations...at a glance, changes in DPOAE don't appear correlated to RAM Changes


## MEMR Threshold
R_25_vs_MEMR_Thresh <- ggplot(all_data_pre_post, aes(x = Threshold, y = R_PLV_SQ25, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin()+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
R_25_vs_MEMR_Thresh

# R_50_vs_MEMR_Thresh <- ggplot(all_data_pre_post, aes(x = Threshold, y = R_PLV_SQ50, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) +
#   scatter_theme_chin()+
#   theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_50_vs_MEMR_Thresh
# 
# R_SAM_vs_MEMR_Thresh <- ggplot(all_data_pre_post, aes(x = Threshold, y = R_PLV_SAM, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = Exposed)) +
#   scatter_theme_chin()+
#   theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_SAM_vs_MEMR_Thresh

#Not correlated with changes in threshold...need more data.


## ABR Wave V/I vs R_PLV_SQ25 Threshold
R_25_vs_rat_c <- ggplot(all_data_pre_post, aes(x = w51rat_c, y = R_PLV_SQ25, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin(legend_on=FALSE,label.y=6.25)+
  labs(color = "Group")+
  xlab("Click | Wave V/I Ratio")+
  ylab(bquote("SQ25 |" ~ R[PLV]))+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_25_vs_rat_c

R_25_vs_rat_4k <- ggplot(all_data_pre_post, aes(x = w51rat_4k, y = R_PLV_SQ25, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin(legend_on=FALSE)+
  xlab("4k | Wave V/I Ratio")+
  ylab(bquote("SQ25 |" ~ R[PLV]))+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_25_vs_rat_4k

R_50_vs_rat_c <- ggplot(all_data_pre_post, aes(x = w51rat_c, y = R_PLV_SQ50, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin(legend_on=FALSE)+
  xlab("Click | Wave V/I Ratio")+
  ylab(bquote("SQ50 |" ~ R[PLV]))+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_50_vs_rat_c

R_50_vs_rat_4k <- ggplot(all_data_pre_post, aes(x = w51rat_4k, y = R_PLV_SQ50, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin(legend_on=FALSE)+
  xlab("4k | Wave V/I Ratio")+
  ylab(bquote("SQ50 |" ~ R[PLV]))+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_50_vs_rat_4k

R_SAM_vs_rat_c <- ggplot(all_data_pre_post, aes(x = w51rat_c, y = R_PLV_SAM, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin(legend_on=FALSE, label.y = 6)+
  xlab("Click | Wave V/I Ratio")+
  ylab(bquote("SAM |" ~ R[PLV]))+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_SAM_vs_rat_c

R_SAM_vs_rat_4k <- ggplot(all_data_pre_post, aes(x = w51rat_4k, y = R_PLV_SAM, color=interaction(Exposed, Group),fill=interaction(Exposed, Group), shape = interaction(Exposed,Group))) +
  scatter_theme_chin(legend_on=FALSE)+
  xlab("4k | Wave V/I Ratio")+
  ylab(bquote("SAM |" ~ R[PLV]))+
  theme(panel.background = element_rect(fill = "gray90")) # Use a light gray hex code)
# R_SAM_vs_rat_4k

#All R_PLVs neg correlated with Wave V/I ratio, except SAM w/click Wave V/I. 

r_plv_corr_rat_all <- ggarrange(R_25_vs_rat_c,R_25_vs_rat_4k,R_50_vs_rat_c,R_50_vs_rat_4k,R_SAM_vs_rat_c,R_SAM_vs_rat_4k, nrow=3, ncol=2,common.legend = TRUE,legend="bottom")
r_plv_corr_rat_all
save_fig("R_PLV_cor_rat_all.png", r_plv_corr_rat_all, width = 8, height = 10, units = "in")
