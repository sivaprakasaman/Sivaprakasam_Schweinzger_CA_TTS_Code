close all
clear

blck = [0.25, 0.25, 0.25];
colors_ca = [0.8500, 0.3250, 0.0980];
colors_tts = [0, 0.4470, 0.7410];

load('TTS_analyzeMEMRsAVG_clean.mat');
chins_TTS = 3;
TTS_avg = AVG_memrDATA_ECpc_dBSPL;
TTS_std = STD_memrDATA_ECpc_dBSPL;
for j = 1:chins_TTS
      TTS_baselines(:,j) = MEMR_DATA{j,1}.y_clean;
end


load('CARBO_analyzeMEMRsAVG_clean.mat');
chins_ca = 4;
CARBO_avg = AVG_memrDATA_ECpc_dBSPL;
CARBO_std = STD_memrDATA_ECpc_dBSPL;

for j = 1:chins_ca
      CARBO_baselines(:,j) = MEMR_DATA{j,1}.y_clean;
end

all_baselines = horzcat(TTS_baselines,CARBO_baselines);
baseline_means = mean(all_baselines,2);
baseline_sem = std(all_baselines')/size(all_baselines,2);

%% Plotting

figure;
hold on
errorbar(elicitor_dBSPL,baseline_means,baseline_sem,'linewidth',1.5);
errorbar(elicitor_dBSPL,CARBO_avg(2,:),CARBO_std(2,:)/sqrt(chins_ca),'linewidth',1.5);
errorbar(elicitor_dBSPL,TTS_avg(3,:),TTS_std(3,:)/sqrt(chins_TTS),'linewidth',1.5);
errorbar(elicitor_dBSPL,TTS_avg(2,:),TTS_std(2,:)/sqrt(chins_TTS),'linewidth',1.5);
legend('Baseline','Carboplatin','TTS-Day1','TTS-Week2','Location','NorthWest')
xlabel('Elicitor Level (dB SPL)');
ylabel('\Delta Ear Canal Pressure (dB)');
legend('Baseline','Carboplatin','TTS-Day1','TTS-Week2','Location','NorthWest','Fontsize',12)
title('MEMR')
grid on
hold off

memr_fig = tiledlayout(2,1,'TileSpacing','Compact','Padding','Compact');
nexttile
hold on
title('Synaptopathy','Color',colors_tts)
errorbar(elicitor_dBSPL,TTS_avg(1,:),TTS_std(1,:)/sqrt(chins_TTS),'sq-','linewidth',2,'color',blck);
%errorbar(elicitor_dBSPL,TTS_avg(3,:),TTS_std(3,:)/sqrt(chins_TTS),'sq-','linewidth',1.5);
errorbar(elicitor_dBSPL,TTS_avg(2,:),TTS_std(2,:)/sqrt(chins_TTS),'sq-','linewidth',2,'color',colors_tts);
hold off
legend('Pre','Post','Location','NorthWest','Fontsize',12)
grid on
ylim([0,3])


nexttile
hold on
title('IHC Damage','Color',colors_ca)
errorbar(elicitor_dBSPL,CARBO_avg(1,:),CARBO_std(1,:)/sqrt(chins_ca),'sq-','linewidth',2,'color',blck);
errorbar(elicitor_dBSPL,CARBO_avg(2,:),CARBO_std(2,:)/sqrt(chins_ca),'sq-','linewidth',2,'color',colors_ca);
legend('Pre','Post','Location','NorthWest','Fontsize',12)
ylim([0,3])
memr_fig.XLabel.String = 'Elicitor Level (dB SPL)';
memr_fig.XLabel.FontSize = 17;
memr_fig.XLabel.FontWeight = 'Bold';
memr_fig.YLabel.String = '\Delta Ear Canal Pressure (dB)';
memr_fig.YLabel.FontSize = 17;
memr_fig.YLabel.FontWeight = 'Bold';
memr_fig.Title.String = 'MEMR';
memr_fig.Title.FontWeight = 'Bold';
xlim([30 100])

set(findall(gcf,'-property','FontSize'),'FontSize',15)
set(findall(gcf,'-property','FontWeight'),'FontWeight','bold')
set(findall(gcf,'-property','MarkerSize'),'LineWidth',3)
memr_fig.Title.FontSize = 20;

hold off
grid on
set(gcf,'Position',[311.4000 158.6000 492.0000 648]);
exportgraphics(memr_fig,'MEMRS_CA_TTS.png','Resolution',300)
% 
% sgtitle('MEMR')
% han=axes(gcf,'visible','off'); 
% han.YLabel.Visible='on';
% ylabel(han,'\Delta Ear Canal Pressure (dB)');