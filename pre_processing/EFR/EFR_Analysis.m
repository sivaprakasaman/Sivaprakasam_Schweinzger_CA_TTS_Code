%Description: EFR Processing Code for TTS/Carbo project with Ivy. Using similar calculations to
% Zhu 2013, computes DFT and PLV spectra. Identifies harmonic peaks in the spectra as a fxn of frequency,
% and finally computes the R_PLV as detailed in our most recent study (Sivaprakasam, Schweinzger, Heinz 2026).

% Note: There is no subtraction of insignificant floor values (noisefloor removal) when computing the PLV spectra
% in this version.

%Last Updated: Andrew Sivaprakasam, 05/2026

tic
clear all;
close all;

%% Parameters:

%isHuman = input('Type 0 for Chinchilla Data, 1 for Human Data: '); %MAKE SURE THIS IS 1 for Human or 0 for Chin

%Sampling
Fs0_Human = 8e3; %if subject is Human
Fs0_Chin = round(48828.125); %if subject is a Chin

Fs = 8e3; %What you want to downsample to
F0 = 100; %Fundamental freq of interest in Hz

iterations = 100;
%window = [0,0.17];
window = [0.6, 1.3];
gain = 20e3; %Gain (doesn't really matter since looking at SNR & PLV, used for magnitude accuracy)
%gain = 1;

K_MRS = 200; %number of distributions to average spectra and PLVs over
NF_iters = 100;

harmonics = 16;
%% Load Files:
%
% if(isHuman)
%     Fs0 = 8e3; %sampling rate in Hz
%
%     [fname, pname, ~] = uigetfile('.mat', 'Choose the SAM FFR Picture File:');
%     SAM_data = load(strcat(pname,fname));
%     [fname, pname, ~] = uigetfile('.mat', 'Choose the SQ25 FFR Picture File:');
%     sq25_data = load(strcat(pname,fname));
%     [fname, pname, ~] = uigetfile('.mat', 'Choose the SQ50 FFR Picture File:');
%     sq50_data = load(strcat(pname,fname));
%
%     %temporary patch
%     SAM_tot_full = SAM_data.AS_EFR_SL;
%     sq25_tot_full = sq25_data.AS_EFR_SL;
%     sq50_tot_full = sq50_data.AS_EFR_SL;
% %
% %     SAM_tot_full = SAM_data.SAM_tot_arr;
% %     sq25_tot_full = sq25_data.SQ25_tot_arr;
% %     sq50_tot_full = sq50_data.SQ50_tot_arr;
%
% else

    Fs0 = round(48828.125); %sampling rate in hz

    %cd(strcat('Data/',subject));
addpath(pwd)
code_dir = pwd;
% chins = ["Q403","Q405","Q408","Q409"];
% conds = ["pre/Baselines","post/2wksPostCA"];
% type = 'CA';

chins = ["Q406","Q407","Q410","Q411"];
conds = ["pre/Baselines","post/2wksPostTTS"];
type = 'TTS';

 %Andrew - Home
 dataPath = '/mnt/Heinz_Synology/Projects/Ivy_Andrew_CARBOvTTS/Data';
 %Andrew - Work
%  dataPath = '/run/user/1000/gvfs/smb-share:server=1353-heinzlab2.hhs.purdue.edu,share=heinz-lab/Projects/Ivy_Andrew_CARBOvTTS/Data'


data_out.chins = chins;
for cnd = 1:length(conds)

for c = 1:length(chins)

    cd(dataPath)
    cd(strcat(chins(c),'/EFR/',conds(cnd)));
    chin = chins(c);

    %WHY DID EVERYTHING GET RE-FORMATTED!
    fold = ls;
    cd(fold(1:end-1))

    %This is so dumb...damn cifs issues...only really need this line if
    %working off synology while at work..could result in indefinite loop if
    %files don't exist.
    err=1;
    while err==1
        try
            SAM_data = load(strcat(pwd,'/',ls('p*SAM*.mat')));
            sq_25_data = load(strcat(pwd,'/',ls('p*sq_25*.mat')));
            sq_50_data = load(strcat(pwd,'/',ls('p*sq_50*.mat')));
            err=0;
        catch
            disp('Connecting...');
            err=1;
        end
    end

    cd(code_dir)
    SAM_tot_full = SAM_data.data.AD_Data.AD_All_V;
    sq25_tot_full = sq_25_data.data.AD_Data.AD_All_V;
    sq50_tot_full = sq_50_data.data.AD_Data.AD_All_V;

    dbSAM = SAM_data.data.Stimuli.calib_dBSPLout - SAM_data.data.Stimuli.atten_dB;
    dbSQ25 = sq_25_data.data.Stimuli.calib_dBSPLout - sq_25_data.data.Stimuli.atten_dB;
    dbSQ50 = sq_50_data.data.Stimuli.calib_dBSPLout - sq_50_data.data.Stimuli.atten_dB;

fprintf('Files Loaded \n')

%% Select random dataset of certain number
        %disp(length(SAM_tot_full));
        x = 1:length(SAM_tot_full);
        odv = x(rem(x,2)==1);
        evv = x(rem(x,2)==0);
        SAM_r_odds = odv';
        SAM_r_evens = evv';

        %Account for different number of collected trials, this may be
        %redundant, since taking same number of trials now...

        x = 1:length(sq25_tot_full);
        odv = x(rem(x,2)==1);
        evv = x(rem(x,2)==0);
        r_odds = odv';
        r_evens = evv';

        trials = min([length(SAM_tot_full)/2,length(sq25_tot_full)/2,length(sq50_tot_full)/2]);

        SAM_tot = cell(1,trials*2);
        sq25_tot = cell(1,trials*2);
        sq50_tot = cell(1,trials*2);

        for t = 1:2:trials*2

            %pos
            SAM_tot{t} = SAM_tot_full{SAM_r_odds(ceil(t/2),1)};
            sq25_tot{t} = sq25_tot_full{r_odds(ceil(t/2),1)};
            sq50_tot{t} = sq50_tot_full{r_odds(ceil(t/2),1)};

            %neg
            SAM_tot{t+1} = SAM_tot_full{SAM_r_evens(ceil(t/2),1)};
            sq25_tot{t+1} = sq25_tot_full{r_evens(ceil(t/2),1)};
            sq50_tot{t+1} = sq50_tot_full{r_evens(ceil(t/2),1)};

        end

        %% Calculate the DFT for Responses

        [SAM_f,SAM_DFT,SAM_PLV, floor_SAM, ENV_SAM_T] = getDFT(SAM_tot,trials,window,Fs,Fs0,gain,K_MRS,NF_iters);
        [sq25_f,sq25_DFT,sq25_PLV, floor_25, ENV_SQ25_T] = getDFT(sq25_tot,trials,window,Fs,Fs0,gain,K_MRS,NF_iters);
        [sq50_f,sq50_DFT,sq50_PLV, floor_50, ENV_SQ50_T] = getDFT(sq50_tot,trials,window,Fs,Fs0,gain,K_MRS,NF_iters);


        %for ARO export
        if(cnd==1)
            data_out.plv_base_sq25(:,c) = sq25_PLV;
            data_out.plv_base_sq50(:,c) = sq50_PLV;
            data_out.plv_base_SAM(:,c) = SAM_PLV;
        else
            data_out.plv_exp_sq25(:,c) = sq25_PLV;
            data_out.plv_exp_sq50(:,c) = sq50_PLV;
            data_out.plv_exp_SAM(:,c) = SAM_PLV;
        end

        figure;
        plot(SAM_f,floor_SAM,sq25_f,floor_25,sq50_f,floor_50);
        legend('SAM','Sq25','Sq50');

        %% Converting back to linear

        SAM_DFT_uv = 10.^(SAM_DFT/20);
        sq25_DFT_uv = 10.^(sq25_DFT/20);
        sq50_DFT_uv = 10.^(sq50_DFT/20);

        %% Plotting & Summation
%
        MAG = figure;
        subplot(2,1,1)
        hold on;
        plot(SAM_f,SAM_DFT_uv)
        plot(sq25_f,sq25_DFT_uv)
        plot(sq50_f,sq50_DFT_uv,'g')
        title('DFT with Noise Floor removed')
        %ylabel('SNR (dB)/Magnitude (dB, arbitrary)')
        ylabel('SNR (Linear Scale)')
        xlabel('Frequency')
        xlim([0,2e3])
        ylim([0,max([SAM_DFT_uv,sq25_DFT_uv,sq50_DFT_uv])*1.25])

%
%         MAG = figure;
%         subplot(2,1,1)
%         hold on;
%         plot(SAM_f,SAM_DFT)
%         plot(sq25_f,sq25_DFT)
%         plot(sq50_f,sq50_DFT,'g')
%         title('DFT with Noise Floor removed')
%         %ylabel('SNR (dB)/Magnitude (dB, arbitrary)')
%         ylabel('SNR (Linear Scale)')
%         xlabel('Frequency')
%         xlim([0,2e3])
%         %ylim([0,max(SAM_DFT)+5e-3])
%

        %PLV Figure:
        PLV = figure;
        subplot(2,1,1)
        hold on;
        plot(SAM_f,SAM_PLV)
        plot(sq25_f,sq25_PLV)
        plot(sq50_f,sq50_PLV,'g')
        title('PLV of Multiple Conditions')
        %ylabel('SNR (dB)/Magnitude (dB, arbitrary)')
        ylabel('PLV')
        xlabel('Frequency')
        xlim([0,2e3])
        ylim([0,1])

%
        %Get peaks and sum them, look at crossings

        [SAM_SUM,SAM_PKS,SAM_LOCS] = getSum(SAM_f,SAM_DFT_uv,F0,harmonics);
        [SQ25_SUM,SQ25_PKS,SQ25_LOCS] = getSum(sq25_f,sq25_DFT_uv,F0,harmonics);
        [SQ50_SUM,SQ50_PKS,SQ50_LOCS] = getSum(sq50_f,sq50_DFT_uv,F0,harmonics);

        [SAMP_SUM,SAMP_PKS,SAMP_LOCS] = getSum(SAM_f,SAM_PLV,F0,harmonics);
        [SQ25P_SUM,SQ25P_PKS,SQ25P_LOCS] = getSum(sq25_f,sq25_PLV,F0,harmonics);
        [SQ50P_SUM,SQ50P_PKS,SQ50P_LOCS] = getSum(sq50_f,sq50_PLV,F0,harmonics);


        SAM_MAG_SUM = SAM_SUM(end);
        SQ25_MAG_SUM = SQ25_SUM(end);
        SQ50_MAG_SUM = SQ50_SUM(end);


        SAM_PLV_SUM = SAMP_SUM(end);
        SQ25_PLV_SUM = SQ25P_SUM(end);
        SQ50_PLV_SUM = SQ50P_SUM(end);

        SAM_PLV_Rat = sum(SAMP_PKS(3:end))/sum(SAMP_PKS(1:2));
        SQ25_PLV_Rat = sum(SQ25P_PKS(3:end))/sum(SQ25P_PKS(1:2));
        SQ50_PLV_Rat = sum(SQ50P_PKS(3:end))/sum(SQ50P_PKS(1:2));

%         SAM_PLV_Rat = sum(SAMP_PKS(3:end))/SAMP_PKS(2);
%         SQ25_PLV_Rat = sum(SQ25P_PKS(3:end))/SQ25P_PKS(2);
%         SQ50_PLV_Rat = sum(SQ50P_PKS(3:end))/SQ50P_PKS(2);

    SAM_MAG_MEAN = mean(SAM_MAG_SUM);
    SQ25_MAG_MEAN = mean(SQ25_MAG_SUM);
    SQ50_MAG_MEAN = mean(SQ50_MAG_SUM);

    SAM_MAG_std = std(SAM_MAG_SUM);
    SQ25_MAG_std = std(SQ25_MAG_SUM);
    SQ50_MAG_std = std(SQ50_MAG_SUM);


    SAM_PLV_MEAN = mean(SAM_PLV_SUM);
    SQ25_PLV_MEAN = mean(SQ25_PLV_SUM);
    SQ50_PLV_MEAN = mean(SQ50_PLV_SUM);

    SAM_PLV_std = std(SAM_PLV_SUM);
    SQ25_PLV_std = std(SQ25_PLV_SUM);
    SQ50_PLV_std = std(SQ50_PLV_SUM);

    SAM_PLV_MEAN_rat = mean(SAM_PLV_Rat);
    SQ25_PLV_MEAN_rat = mean(SQ25_PLV_Rat);
    SQ50_PLV_MEAN_rat = mean(SQ50_PLV_Rat);

    SAM_PLV_std_rat = std(SAM_PLV_Rat);
    SQ25_PLV_std_rat = std(SQ25_PLV_Rat);
    SQ50_PLV_std_rat = std(SQ50_PLV_Rat);
%% Saving Data


% SAM_MAG_all_means = [t_array',SAM_MAG_MEAN',SAM_MAG_std'];
% SQ25_MAG_all_means = [t_array',SQ25_MAG_MEAN',SQ25_MAG_std'];
% SQ50_MAG_all_means = [t_array',SQ50_MAG_MEAN',SQ50_MAG_std'];
%
% save('SAM_MAG_all_m.mat','SAM_MAG_all_means')
% save('SQ25_MAG_all_m.mat','SQ25_MAG_all_means')
% save('SQ50_MAG_all_m.mat','SQ50_MAG_all_means')
%
% SAM_PLV_all_means = [t_array',SAM_PLV_MEAN',SAM_PLV_std'];
% SQ25_PLV_all_means = [t_array',SQ25_PLV_MEAN',SQ25_PLV_std'];
% SQ50_PLV_all_means = [t_array',SQ50_PLV_MEAN',SQ50_PLV_std'];
%
% save('SAM_PLV_all_m.mat','SAM_PLV_all_means')
% save('SQ25_PLV_all_m.mat','SQ25_PLV_all_means')
% save('SQ50_PLV_all_m.mat','SQ50_PLV_all_means')

figure(MAG)
subplot(2,1,1);
hold on;
plot(SAM_LOCS,SAM_PKS,'bo',SQ25_LOCS,SQ25_PKS,'ro',SQ50_LOCS,SQ50_PKS,'go')
legend('SAM','SQ25','SQ50','SAM','SQ25','SQ50')

subplot(2,1,2)
plot(SAM_LOCS,SAM_SUM,SQ25_LOCS,SQ25_SUM,SQ50_LOCS,SQ50_SUM,'g')
xlabel('Frequency')
ylabel('Cummulative Sum of Harmonic Magnitudes')
xlim([0,2000]);

figure(PLV)
subplot(2,1,1);
hold on;
plot(SAMP_LOCS,SAMP_PKS,'bo',SQ25P_LOCS,SQ25P_PKS,'ro',SQ50P_LOCS,SQ50P_PKS,'go')
legend('SAM','SQ25','SQ50','SAM','SQ25','SQ50')

subplot(2,1,2)
plot(SAMP_LOCS,SAMP_SUM,SQ25P_LOCS,SQ25P_SUM,SQ50P_LOCS,SQ50P_SUM,'g')
xlabel('Frequency')
ylabel('Cummulative Sum of PLV Peaks')
xlim([0,2000]);

if(cnd == 1)
    sq25_allChins_n(c,:) = SQ25P_SUM;
    sq50_allChins_n(c,:) = SQ50P_SUM;
    SAM_allChins_n(c,:) = SAMP_SUM;

    sq25_all_n(c,:) = ENV_SQ25_T;
    sq50_all_n(c,:) = ENV_SQ50_T;
    sam_all_n(c,:) = ENV_SAM_T;

    sq25_allChins_n_r(c) = SQ25_PLV_Rat;
    sq50_allChins_n_r(c) = SQ50_PLV_Rat;
    SAM_allChins_n_r(c) = SAM_PLV_Rat;

    dbSAM_n(c) = dbSAM;
    dbSQ25_n(c) = dbSQ25;
    dbSQ50_n(c) = dbSQ50;

else
    sq25_allChins_i(c,:) = SQ25P_SUM;
    sq50_allChins_i(c,:) = SQ50P_SUM;
    SAM_allChins_i(c,:) = SAMP_SUM;

    sq25_all_i(c,:) = ENV_SQ25_T;
    sq50_all_i(c,:) = ENV_SQ50_T;
    sam_all_i(c,:) = ENV_SAM_T;

    sq25_allChins_i_r(c) = SQ25_PLV_Rat;
    sq50_allChins_i_r(c) = SQ50_PLV_Rat;
    SAM_allChins_i_r(c) = SAM_PLV_Rat;

    dbSAM_i(c) = dbSAM;
    dbSQ25_i(c) = dbSQ25;
    dbSQ50_i(c) = dbSQ50;

end

end
end

data_out.f = SAM_f;

toc
%% Plotting:
harms = 1:harmonics;

cd(dataPath);
cd ../
cd Analysis/Figures

%sq25
figure;
hold on;
errorbar(harms, mean(sq25_allChins_n), std(sq25_allChins_n),'k','linewidth',1.5);
errorbar(harms, mean(sq25_allChins_i), std(sq25_allChins_i),'r','linewidth',1.5);
legend('Pre','Post');
xlabel('Harmonic Number');
ylabel('Cumulative Sum of PLV Peaks');
title('Carboplatin - SQ 25');
hold off
grid on
print('-dtiff','sq25_CA_16')

%sq50
figure;
hold on;
errorbar(harms, mean(sq50_allChins_n), std(sq50_allChins_n),'k','linewidth',1.5);
errorbar(harms, mean(sq50_allChins_i), std(sq50_allChins_i),'g','linewidth',1.5);
legend('Pre','Post');
xlabel('Harmonic Number');
ylabel('Cumulative Sum of PLV Peaks');
title('Carboplatin - SQ 50');
grid on
print('-dtiff','sq50_CA_16')

%SAM
figure;
hold on;
errorbar(harms, mean(SAM_allChins_n), std(SAM_allChins_n),'k','linewidth',1.5);
errorbar(harms, mean(SAM_allChins_i), std(SAM_allChins_i),'b','linewidth',1.5);
legend('Pre','Post');
xlabel('Harmonic Number');
ylabel('Cumulative Sum of PLV Peaks');
title('Carboplatin - SAM');
grid on
print('-dtiff','SAM_CA_16')

%????
figure;
boxplot([SAM_allChins_n_r',SAM_allChins_i_r', sq25_allChins_n_r',sq25_allChins_i_r', sq50_allChins_n_r',sq50_allChins_i_r'],...
     'Labels', {'SAM - Pre','SAM - Post', 'SQ25 - Pre','SQ25 - Post','SQ50 - Pre','SQ50 - Post'});
title('Carboplatin - Ratio of \Sigma (3:16 Harmonics) to \Sigma (1:2 Harmonics)');
ylabel('PLV Ratio (Dimensionless)')

%Check dbs
figure;
boxplot([dbSAM_n',dbSAM_i', dbSQ25_n',dbSQ25_i',dbSQ50_n',dbSQ50_i'],...
     'Labels', {'SAM - Pre','SAM - Post', 'SQ25 - Pre','SQ25 - Post','SQ50 - Pre','SQ50 - Post'});
title('Carboplatin - dbSPL of Stim Presentation');
ylabel('dbSPL')

figure;
boxplot([dbSAM_n'-dbSAM_i', dbSQ25_n'-dbSQ25_i',dbSQ50_n'-dbSQ50_i'],...
     'Labels', {'SAM ','SQ25','SQ50'});
title('Carboplatin - \Delta dbSPL of Stim Presentation (Pre-Post)');
ylabel('dbSPL')

data_out.mean_Level = mean(mean([dbSAM_n',dbSAM_i', dbSQ25_n',dbSQ25_i',dbSQ50_n',dbSQ50_i']));
data_out.pre_post_SAM_rat = [SAM_allChins_n_r',SAM_allChins_i_r'];
data_out.pre_post_sq25_rat = [sq25_allChins_n_r',sq25_allChins_i_r'];
data_out.pre_post_sq50_rat = [sq50_allChins_n_r',sq50_allChins_i_r'];

%% Time Waveforms
t = (0:(size(sam_all_n,2)-1))/Fs;

figure;
subplot(3,1,1);
title('SAM')
hold on
plot(t,mean(sam_all_n,1),'linewidth',1.5)
plot(t,mean(sam_all_i,1),'linewidth',1.5)
hold off
legend('Pre','Post')

subplot(3,1,2);
title('SQ50')
hold on
plot(t,mean(sq50_all_n,1),'linewidth',1.5)
plot(t,mean(sq50_all_i,1),'linewidth',1.5)
hold off

subplot(3,1,3);
title('SQ25')
hold on
plot(t,mean(sq25_all_n,1),'linewidth',1.5)
plot(t,mean(sq25_all_i,1),'linewidth',1.5)
hold off
xlabel('Time (s)')

sgtitle('Carbo | EFR 100 Hz F_{mod}')

data_out.sam_all_n = sam_all_n;
data_out.sq50_all_n = sq50_all_n;
data_out.sq25_all_n = sq25_all_n;

data_out.sam_all_i = sam_all_i;
data_out.sq50_all_i = sq50_all_i;
data_out.sq25_all_i = sq25_all_i;

data_out.t = t;
%% Export data
save([type,'_Processed.mat'],'data_out')
