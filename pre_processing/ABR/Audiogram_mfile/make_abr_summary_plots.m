%% Plot ABR thresholds from new analysis

cwd = pwd();

set(0,'DefaultFigureRenderer','painters')

cd([datapath, filesep, 'Baseline']);
all_chins = dir('Q*');

% Get list of chins for each exposure
cd(datapath);
cd('CA')
ca_chins = dir('Q*');
ca_chins = {ca_chins.name};
cd(datapath);
% cd('PTS_2wksPost')
% pts_chins = dir('Q*');
% pts_chins = {pts_chins.name};
% cd(datapath);
cd('TTS')
tts_chins = dir('Q*');
tts_chins = {tts_chins.name};
cd(datapath);
% cd('GE_1wkPost')
% ge_chins = dir('Q*');
% ge_chins = {ge_chins.name};

cd(datapath)

% Initialize results/data matrices
% freq = [.5, 1, 2, 4, 8]; % kHz
freq = [0,4];
baseline = zeros(numel(all_chins),numel(freq));
post = zeros(numel(all_chins),numel(freq));
exp = [];

for k = 1:numel(all_chins)
    chin = all_chins(k).name;
    
    % Get Baseline data
    cd([all_chins(k).folder,filesep, chin, filesep, 'Processed'])
    cond = 'Baseline';
    load([all_chins(k).name,'_',cond,'_ABR_Data.mat']);
    freq = abr_out.freqs/1e3; %converted to kHz
    baseline(k,:) = abr_out.thresholds;
    
    cd(datapath);
    emptyFlag = 0;
    if sum(strcmp(chin, tts_chins)>0)
        cd(fullfile('TTS', chin, 'Processed'))
        cond = 'TTS';
        exp{k,1} = 'TTS';
%     elseif sum(strcmp(chin, pts_chins)>0)
%         cd(fullfile('PTS_2wksPost', chin, 'Processed'))
%         cond = 'PTS_2wksPost';
%         exp{k,1} = 'PTS';
    elseif sum(strcmp(chin, ca_chins)>0)
        cd(fullfile('CA', chin, 'Processed'))
        cond = 'CA';
        exp{k,1} = 'CA';
%     elseif sum(strcmp(chin, ge_chins)>0)
%         cd(fullfile('GE_1wkPost', chin, 'Processed'))
%         cond = 'GE_1wkPost';
%         exp{k,1} = 'GE';
    else
        exp{k,1} = 'NA';
        cond = 'Baseline';
        emptyFlag = 1;
    end
    
    %TODO handle missing pre/post data.
    if ~emptyFlag
        load([all_chins(k).name,'_',cond,'_ABR_Data.mat'])
        post(k,:) = abr_out.thresholds;
    end
    
end

%% Plot Data

blck = [0.25, 0.25, 0.25];
rd = [194 106 119]./255; %TTS
blu = [148 203 236]./255; %CA
yel = [220 205 125]./255; %PTS
gre = [93 168 153]./255; %GE

i_blck = [0.25, 0.25, .25, 75];
i_rd = [194 106 119 75]./255; %TTS
i_blu = [148 203 236 75]./255; %CA
i_yel = [220 205 125 75]./255; %PTS
i_gre = [93 168 153 57]./255; %GE

i_cols = [i_blck; i_blu; i_rd]; 
cols = [blck; rd; blu; yel; gre]; 
groups = {'NH', 'TTS', 'CA'}; 
subp = [0 1 3]'; 
    
%% Mean Plots

CA_inds = find(strcmp(exp,'CA'));
ca_mean = [mean(baseline(CA_inds,:),1)',mean(post(CA_inds,:),1)']; %col1 pre col2 post
ca_std= [std(baseline(CA_inds,:),[],1)',std(post(CA_inds,:),[],1)'];

TTS_inds = find(strcmp(exp,'TTS'));
tts_mean = [mean(baseline(TTS_inds,:),1)',mean(post(TTS_inds,:),1)']; 
tts_std= [std(baseline(TTS_inds,:),[],1)',std(post(TTS_inds,:),[],1)'];

jit = .5;
%Plot
figure;
subplot(1,2,1);
hold on
errorbar(freq-jit,tts_mean(:,1),tts_std(:,1),'o','color',blck,'LineWidth',2.5)
errorbar(freq+jit,tts_mean(:,2),tts_std(:,2),'o','color',blu,'LineWidth',2.5)
plot([freq(1)-jit,freq(1)+jit],[baseline(TTS_inds,1),post(TTS_inds,1)],'.-','color',[0,0,0,.2],'linewidth',1.5)
plot([freq(2)-jit,freq(2)+jit],[baseline(TTS_inds,2),post(TTS_inds,2)],'.-','color',[0,0,0,.2],'linewidth',1.5)
hold off
xticks(freq);
xticklabels(["Click", "4kHz"])
legend(["Baseline","Post-TTS"],"FontSize",13,"Location","Northwest")
yticks(0:10:100);
ylim([0,70]);
ylabel('Threshold (dB SPL)');
xlim([-2,6]);
title('Synaptopathy','color',blu)
grid on

subplot(1,2,2);
hold on
errorbar(freq-jit,ca_mean(:,1),ca_std(:,1),'o','color',blck,'LineWidth',2.5)
errorbar(freq+jit,ca_mean(:,2),ca_std(:,2),'o','color',rd,'LineWidth',2.5)
plot([freq(1)-jit,freq(1)+jit],[baseline(CA_inds,1),post(CA_inds,1)],'.-','color',[0,0,0,.2],'linewidth',1.5)
plot([freq(2)-jit,freq(2)+jit],[baseline(CA_inds,2),post(CA_inds,2)],'.-','color',[0,0,0,.2],'linewidth',1.5)
hold off
xticks(freq);
xticklabels(["Click", "4kHz"])
yticks(0:10:100);
ylabel('Threshold (dB SPL)');
xlim([-2,6]);
ylim([0,70]);
legend(["Baseline","Post-CA"],"FontSize",13,"Location","northwest")
title('IHC Damage','color',rd)
grid on

set(gcf,'Position',[670 553 1022 407])
cd(cwd)
cd("Figures")
print(gcf,'ABR_audiogram_pre_post_all.png','-r600','-dpng')
save("abr_output_compiled.mat","ca_chins","tts_chins","baseline","CA_inds","TTS_inds","post","all_chins","exp")

cd(cwd);