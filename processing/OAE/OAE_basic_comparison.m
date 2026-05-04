clear all

%OAE Analysis:

 chins = ["Q403","Q405","Q408","Q409"];
 conds = ["pre/Baselines","post/2weeksPostCA"];
% 

%conds = ["post/2weeksPostTTS"];
dataPath = '/mnt/Heinz_Synology/Projects/Ivy_Andrew_CARBOvTTS/Data';
cwd = pwd;

for cnd = 1:length(conds)
    
    for c = 1:length(chins)
        cd(dataPath)
        cd(strcat(chins(c),'/OAE/',conds(cnd)))
        
        fname = ls('*dpoae.m');
        fname = fname(1:end-3);
        eval('run(fname)')
        
        x = ans;
        
        dpdat = x.DpoaeData;
        f2 = dpdat(:,2);
        dp(c,:) = dpdat(:,4);
       
        if cnd == 1
            ca_baseline(:,1) = dp(c,:);
        end
        ca_nans_chin(:,c) = ~isnan(dp(c,:));
    end
    ca_nans_cond(:,cnd) = sum(ca_nans_chin,2);
    ca_mean(:,cnd) = mean(dp,1,'omitnan');
    ca_std(:,cnd) = std(dp,'omitnan');
end


chins = ["Q406","Q407","Q410","Q411"];
conds = ["pre/Baselines","post/1dayPostTTS","post/2weeksPostTTS"];
clear dp
for cnd = 1:length(conds)
    
    for c = 1:length(chins)
        cd(dataPath)
        cd(strcat(chins(c),'/OAE/',conds(cnd)))
        
        fname = ls('*dpoae.m');
        fname = fname(1:end-3);
        eval('run(fname)')
        
        x = ans;
        
        dpdat = x.DpoaeData;
        f2 = dpdat(:,2);
        dp(c,:) = dpdat(:,4);
               
        if cnd == 1
            tts_baseline(:,1) = dp(c,:);
        end
        tts_nans_chin(:,c) = ~isnan(dp(c,:));
    end
    tts_nans_cond(:,cnd) = sum(tts_nans_chin,2);
    tts_mean(:,cnd) = mean(dp,1,'omitnan');
    tts_std(:,cnd) = std(dp,'omitnan');
end

totalbaseline = [ca_baseline,tts_baseline]';

%% plot

cd(cwd);

purp = [0.4940 0.1840 0.5560];
gren = [0.4660 0.6740 0.1880];
blue = [0 0.4470 0.7410];
red = [0.8500 0.3250 0.0980];

figure;
hold on
errorbar(f2,mean(totalbaseline,'omitnan'),std(totalbaseline,'omitnan')'./sqrt(ca_nans_cond(:,1)+tts_nans_cond(:,1)),'linewidth',1.5);
errorbar(f2,ca_mean(:,2),ca_std(:,2)./sqrt(ca_nans_cond(:,2)),'linewidth',1.5);
errorbar(f2,tts_mean(:,2),tts_std(:,2)./sqrt(tts_nans_cond(:,2)),'linewidth',1.5);
errorbar(f2,tts_mean(:,3),tts_std(:,3)./sqrt(tts_nans_cond(:,3)),'linewidth',1.5);
% 
% shadedErrorBar(f2,mean(totalbaseline,'omitnan'),std(totalbaseline,'omitnan')'./sqrt(ca_nans_cond(:,1)+tts_nans_cond(:,1)),'transparent',true,'patchSaturation',0.1,'lineprops',{'linewidth',1.5,'color',blue});
% shadedErrorBar(f2,ca_mean(:,2),ca_std(:,2)./sqrt(ca_nans_cond(:,2)),'transparent',true,'patchSaturation',0.1,'lineprops',{'linewidth',1.5,'color',red});
% shadedErrorBar(f2,tts_mean(:,2),tts_std(:,2)./sqrt(tts_nans_cond(:,2)),'transparent',true,'patchSaturation',0.1,'lineprops',{'linewidth',1.5,'color',purp});
% shadedErrorBar(f2,tts_mean(:,3),tts_std(:,3)./sqrt(tts_nans_cond(:,3)),'transparent',true,'patchSaturation',0.1,'lineprops',{'linewidth',1.5,'color',gren});
legend('Baseline','Carboplatin','TTS - Day 1','TTS - Week 2','Location','Southwest')
xlabel('F2 Frequency');
ylabel('DPOAE (dB SPL)');
title('dpOAE');
grid on
set(gca,'XScale','log');
hold off

% 
% figure;
% hold on;
% errorbar(f2, mean(dp_n,'omitnan'), std(dp_n,'omitnan'),'k','linewidth',1.5);
% errorbar(f2, mean(dp_i,'omitnan'), std(dp_i,'omitnan'),'r','linewidth',1.5);
% legend('Pre','Post');
% xlabel('F2 Frequency');
% ylabel('DPOAE (dB SPL)');
% title('Carboplatin - OAE');
% grid on
% set(gca,'XScale','log');
% hold off
save('OAE_CA_TTS_IVY.mat','ca_mean','tts_mean','ca_std','tts_std','ca_nans_cond','tts_nans_cond','f2')
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
