%Setup file for directory information (ABR threshold)

close all;
clear;

% set(0,'defaultfigurerenderer','painters')

condition = 'Baseline';
subj = 'Q406';

export = 1;
m_flag = 1;
mode = 3; %0 - Process single chin, 1 - plot single chin pre/post, 2 - batch process all, 3 - plot compiled pre-post for all

uname = 'sivaprakasaman';
prefix = ['/media/sivaprakasaman/AndrewNVME/IS_AS_Carbo_TTS_Project/Ivy_Andrew_CARBOvTTS/Data/ABR_reorg/'];

%if processing click, put a 0 in freqs
freqs = [0,4e3];
% freqs = [500,4e3,0]; 

switch mode 
    case 0 
        disp("Processing Single Chin...");

        suffix = [condition,'/',subj];
        datapath = [prefix,suffix];

        ABR_audiogram_chin;
    case 1
        warning("Sorry, will come back to this. For now, look at the summary plots in case 3")
%         disp("Processing Single Chin Pre vs Post...")
    case 2 
        disp("Batch Processing every chin, pre and post...This might take a while!")
        datapath = prefix;
        conditions = ["Baseline","CA","TTS"];
        Run_batchMode;
    case 3
        disp("Plotting summarized chin data");
        datapath = prefix;
        make_abr_summary_plots;
end






