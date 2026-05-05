clear all;
close all; 

code_dir = pwd;
chins_C = ["Q403","Q405","Q408","Q409"];
chins_T = ["Q406","Q407","Q410","Q411"];

dataPath = '/mnt/Heinz_Synology/Projects/Ivy_Andrew_CARBOvTTS/Analysis/ABR';
cd(dataPath)

%process carbo
for c=1:length(chins_C)
    disp(['processing chin: ',chins_C{c}])
    cd(chins_C(c))
    %pre
    cd("pre")
    %click
    clck_file = ls('*click*');
    load(string(clck_file(1:end-1)));
    ca_pre_click_thresh(:,c) = abrs.thresholds';

    %highest level only! P1,N1...P5,N5
    ca_pre_click_level(:,c) = abrs.waves(1,2);
    ca_pre_click_wform(:,c) =  abrs.waves(1,3:end);
    ca_pre_click_latencies(:,c) = abrs.x(1,3:12);
    ca_pre_click_pks(:,c) = abrs.y(1,3:12);

    %4k
    clck_file = ls('*4000*');
    load(string(clck_file(1:end-1)));
    ca_pre_4k_thresh(:,c) = abrs.thresholds';

    %highest level only! P1,N1...P5,N5
    ca_pre_4k_level(:,c) = abrs.waves(1,2);
    ca_pre_4k_wform(:,c) =  abrs.waves(1,3:end);

    ca_pre_4k_latencies(:,c) = abrs.x(1,3:12);
    ca_pre_4k_pks(:,c) = abrs.y(1,3:12);

    cd ../

    %post
    cd("post")
    %click
    clck_file = ls('*click*');
    load(string(clck_file(1:end-1)));
    ca_post_click_thresh(:,c) = abrs.thresholds';
    ca_post_click_level(:,c) = abrs.waves(1,2);
    ca_post_click_wform(:,c) =  abrs.waves(1,3:3026);

    ca_post_click_latencies(:,c) = abrs.x(1,3:12);
    ca_post_click_pks(:,c) = abrs.y(1,3:12);

    %4k
    clck_file = ls('*4000*');
    load(string(clck_file(1:end-1)));
    ca_post_4k_thresh(:,c) = abrs.thresholds';
    ca_post_4k_level(:,c) = abrs.waves(1,2);
    ca_post_4k_wform(:,c) =  abrs.waves(1,3:3026);

    ca_post_4k_latencies(:,c) = abrs.x(1,3:12);
    ca_post_4k_pks(:,c) = abrs.y(1,3:12);

    cd(dataPath)
end

%process tts
for c=1:length(chins_T)
    disp(['processing chin: ',chins_T{c}])
    cd(chins_T(c))
    %pre
    cd("pre")
    %click
    clck_file = ls('*click*');
    load(string(clck_file(1:end-1)));
    tts_pre_click_thresh(:,c) = abrs.thresholds';


    %highest level only! P1,N1...P5,N5
    tts_pre_click_level(:,c) = abrs.waves(1,2);
    tts_pre_click_wform(:,c) =  abrs.waves(1,3:3026);

    tts_pre_click_latencies(:,c) = abrs.x(1,3:12);
    tts_pre_click_pks(:,c) = abrs.y(1,3:12);


    %4k
    clck_file = ls('*4000*');
    load(string(clck_file(1:end-1)));
    tts_pre_4k_thresh(:,c) = abrs.thresholds';
    tts_pre_4k_level(:,c) = abrs.waves(1,2);
    tts_pre_4k_wform(:,c) =  abrs.waves(1,3:3026);

    tts_pre_4k_latencies(:,c) = abrs.x(1,3:12);
    tts_pre_4k_pks(:,c) = abrs.y(1,3:12);
    cd ../

    %post
    cd("post")
    %click
    clck_file = ls('*click*');
    load(string(clck_file(1:end-1)));
    tts_post_click_thresh(:,c) = abrs.thresholds;

    tts_post_click_level(:,c) = abrs.waves(1,2);
    tts_post_click_wform(:,c) =  abrs.waves(1,3:3026);
    tts_post_click_latencies(:,c) = abrs.x(1,3:12);
    tts_post_click_pks(:,c) = abrs.y(1,3:12);

    %4k
    clck_file = ls('*4000*');
    load(string(clck_file(1:end-1)));
    tts_post_4k_thresh(:,c) = abrs.thresholds';
    tts_post_4k_level(:,c) = abrs.waves(1,2);
    tts_post_4k_wform(:,c) =  abrs.waves(1,3:3026);

    tts_post_4k_latencies(:,c) = abrs.x(1,3:12);
    tts_post_4k_pks(:,c) = abrs.y(1,3:12);

    cd(dataPath)
end
cd(code_dir)
clear abrs;
save('abr_thresh_out.mat')
%% Plotting 
clear
close all;
fig_dir = '/mnt/Heinz_Synology/Projects/Ivy_Andrew_CARBOvTTS';
load('abr_thresh_out.mat');
abr_fig = figure();
x = [1,2,3.5,4.5];
blck = [0.25, 0.25, 0.25];
colors_ca = [0.8500, 0.3250, 0.0980];
colors_tts = [0, 0.4470, 0.7410];

plot_colors = [blck',colors_ca',blck',colors_ca'];
ca_data = [ca_pre_click_thresh(2,:)',ca_post_click_thresh(2,:)', ...
    ca_pre_4k_thresh(2,:)',ca_post_4k_thresh(2,:)'];
subplot(2,1,1)
hold on
for i = 1:length(x)
    boxchart(x(i)*ones(length(ca_data),1),ca_data(:,i),'BoxFaceColor',plot_colors(:,i),'LineWidth',2);
end
lin = 0:50;
plot(mean(x)*ones(length(lin),1),lin,'k--','linewidth',1.5)
text(0.6,45,'Click','FontSize',13,'FontWeight','bold');
text(2.9,45,'4k','FontSize',13,'FontWeight','bold');

hold off
xticks(x);
xticklabels(["Pre","Post","Pre","Post"])
set(gca,"FontSize",12)
%set(findobj(gca,'type','line'),'linew',1.75)
title('CA | IHC Damage','Color',colors_ca)
ylim([0,50])
grid on
box on

plot_colors = [blck',colors_tts',blck',colors_tts'];
tts_data = [tts_pre_click_thresh(2,:)',tts_post_click_thresh(2,:)', ...
    tts_pre_4k_thresh(2,:)',tts_post_4k_thresh(2,:)'];
subplot(2,1,2)
hold on
for i = 1:length(x)
    boxchart(x(i)*ones(length(tts_data),1),tts_data(:,i),'BoxFaceColor',plot_colors(:,i),'LineWidth',2);
end
plot(mean(x)*ones(length(lin),1),lin,'k--','linewidth',1.5)
text(0.6,45,'Click','FontSize',13,'FontWeight','bold');
text(2.9,45,'4k','FontSize',13,'FontWeight','bold');
hold off
xticks(x);
xticklabels(["Pre","Post","Pre","Post"])
set(gca,"FontSize",12)
set(findobj(gca,'type','line'),'linew',1.5)
title('TTS | Cochlear Synaptopathy','color',colors_tts)
ylim([0,50])
grid on
box on
text(0.2,40,0,'ABR Threshold (dB SPL)','Rotation',90,'FontSize',13,'FontWeight','bold');
set(gcf,'Position',[675 410 973 561]);
cd(fig_dir)
print(abr_fig,'abr_ca_tts.png','-dpng','-r600')
print(abr_fig,'abr_ca_tts.svg','-dsvg')
cd(code_dir)