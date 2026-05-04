%% New plot that separates the conditions...
clear 
blck = [0.25, 0.25, 0.25];
colors_ca = [0.8500, 0.3250, 0.0980];
colors_tts = [0, 0.4470, 0.7410];

load('OAE_CA_TTS_IVY.mat');
%TTS Fig
combined_oaes = tiledlayout(2,1,'TileSpacing','Compact','Padding','Compact');
nexttile
hold on
errorbar(f2,tts_mean(:,1),tts_std(:,1)./sqrt(tts_nans_cond(:,1)),'linewidth',1.5,'color',blck);
%errorbar(f2,tts_mean(:,2),tts_std(:,2)./sqrt(tts_nans_cond(:,2)),'--','linewidth',1.5,'color',colors_tts.^.7);
errorbar(f2,tts_mean(:,3),tts_std(:,3)./sqrt(tts_nans_cond(:,3)),'-','linewidth',1.5,'color',colors_tts);
%legend('Baseline','TTS - Day 1','TTS - Week 2','Location','Southwest','FontSize',12)
legend('Pre','Post','Location','Southwest','FontSize',12)
title('Synaptopathy','Color',colors_tts)
grid on
set(gca,'XScale','log');
hold off
%Ca Fig
nexttile
hold on
errorbar(f2,ca_mean(:,1),ca_std(:,1)./sqrt(ca_nans_cond(:,1)),'linewidth',1.5,'color',blck);
%errorbar(f2,tts_mean(:,2),tts_std(:,2)./sqrt(tts_nans_cond(:,2)),'--','linewidth',1.5,'color',colors_tts.^.7);
errorbar(f2,ca_mean(:,2),ca_std(:,2)./sqrt(ca_nans_cond(:,2)),'-','linewidth',1.5,'color',colors_ca);
%legend('Baseline','TTS - Day 1','TTS - Week 2','Location','Southwest','FontSize',12)
legend('Pre','Post','Location','Southwest','FontSize',12)
title('IHC Damage','Color',colors_ca)
grid on
set(gca,'XScale','log');
hold off
combined_oaes.XLabel.String = 'F2 Frequency';
combined_oaes.XLabel.FontSize = 17;
combined_oaes.XLabel.FontWeight = 'Bold';
combined_oaes.YLabel.String = 'DPOAE (dB SPL)';
combined_oaes.YLabel.FontSize = 17;
combined_oaes.YLabel.FontWeight = 'Bold';
combined_oaes.Title.String = 'dpOAEs';
combined_oaes.Title.FontWeight = 'bold';

set(findall(gcf,'-property','FontSize'),'FontSize',15)
set(findall(gcf,'-property','FontWeight'),'FontWeight','bold')
set(findall(gcf,'-property','MarkerSize'),'LineWidth',3)
combined_oaes.Title.FontSize = 20;


set(gcf,'Position',[311.4000 158.6000 492.0000 648]);
exportgraphics(combined_oaes,'OAE_CA_TTS.png','Resolution','300')
