%% MEMR preprocessALL script - Step 1
    %This script allows you to loop through and call preprocess1
    
%Process:
%1. Loop through Chin and Condition...
%2. Call preprocess1_MEMR.m each time

%Saves:
%No saving, sole purpose is for looping through chins/conditions
%All saving done in preprocess1_MEMR.m

%Before running code, MUST DO:
%Edit "Directory-related" to be specific to computer of use
%**Edit Chins2Run and Conds2Run to loop through

%% Directory-related - FIRST!
%NOTE: EDIT directories to be specific to your computer
%Current folder is "Data Collection"

%Set USERdir automatically
%Hint for USERdir: use pwd when you have cd'd into correct directory of
%code, ignore "data collection" subfolder in pwd name
%If using mac computer..
if (ismac == 1) %MAC computer
    USERdir = strcat(filesep,'Volumes',filesep,'Heinz-Lab/Projects/Ivy_Andrew_CARBOvTTS/Data');
else %if using WINDOWS computer..
    %home
    USERdir = strcat('/mnt/Heinz_Synology',filesep,'Projects',filesep,'Ivy_Andrew_CARBOvTTS');
    %work
    %USERdir = strcat('/run/user/1000/gvfs/smb-share:server=1353-heinzlab2.hhs.purdue.edu,share=heinz-lab/',filesep,'Projects',filesep,'Ivy_Andrew_CARBOvTTS');
end
addpath(pwd);

EXPname = 'MEMR';
CODEname = 'Data Collection'; 
ANALYSISname = 'Analysis';
DATAname = 'Data';
SUBFUNCTIONname = 'subfunctions';

ROOTdir=strcat(USERdir);
DATAdir=strcat(ROOTdir,filesep,DATAname);
CODEdir = strcat(ROOTdir,filesep,CODEname);
CODEsub = strcat(ROOTdir,filesep,CODEname,filesep,SUBFUNCTIONname);
ANALYSISdir = strcat(ROOTdir,filesep,ANALYSISname,filesep);
ANALYSISsub = strcat(ROOTdir,filesep,ANALYSISname,filesep,"MEMR",filesep,SUBFUNCTIONname);
%Before every subfunction, change to subfunction folder
ANALYZEDdatadir = strcat(ROOTdir,filesep,ANALYSISname,filesep,EXPname,filesep,'Analyzed Data');

%% Collect all Data - SECOND!
Chins2Run={'Q406','Q407','Q410','Q411'};
Conds2Run = {strcat('pre',filesep,'Baselines'), strcat('post',filesep,'2weeksPostTTS'),strcat('post',filesep,'1dayPostTTS')};

% Chins2Run = {"Q403","Q405","Q408","Q409"};
% Conds2Run = {"pre/Baselines","post/2weeksPostCA"};

%Conds2Run = {strcat('pre',filesep,'Baselines')};
%% Looping through Chins and Conditions
%Enter "Analyzed Data" subfolder
%Begin looping
for ChinIND=1:length(Chins2Run)
	for CondIND=1:length(Conds2Run)
        cd(ANALYZEDdatadir);
		SKIP=0;
		fprintf('Pre-Processing MEMR Data for Chin: %s;  Cond: %s\n',Chins2Run{ChinIND},Conds2Run{CondIND})
		% Check if basic directories (chin#/pre & /post) exist for this chin already
		Dlist=dir(Chins2Run{ChinIND});
		if isempty(Dlist) %create directory if it doesn't exist
			fprintf('   ***Creating "%s" Directory (/pre and /post)\n',Chins2Run{ChinIND})
			mkdir(Chins2Run{ChinIND})
			cd(Chins2Run{ChinIND})
			mkdir('pre')
			mkdir('post')
		else
			cd(Chins2Run{ChinIND})
        end
        %Now cd'd into chin folder
        %cd(Chins2Run{ChinIND});
		Dlist=dir(Conds2Run{CondIND}); % check if specific Condition directory exists, if not make it
		if isempty(Dlist)
			fprintf('   ***Creating "%s" Directory\n',Conds2Run{CondIND})
			mkdir(Conds2Run{CondIND})
            cd(Conds2Run{CondIND});
        else
            cd(Conds2Run{CondIND});
        end
        %Now cd'd into condition subfolder
        
        %Only complete preprocessing if preprocessing has not been
        %completed yet...
		%filename=sprintf('MEMR_AR_%s_%s',Chins2Run{ChinIND},Conds2Run{CondIND}(findstr(Conds2Run{CondIND},'\')+1:end));
        filesep_loc = findstr(Conds2Run{CondIND},filesep);
        filename=sprintf('MEMR_AR_%s_%s',Chins2Run{ChinIND},Conds2Run{CondIND}(filesep_loc+1:end));
		Dlist=dir(sprintf('%s*',filename));
		if ~isempty(Dlist)  %If data exists, SKIP recomputing
			SKIP=1;
			fprintf('   ***DATA ALREADY EXISTS: SKIPPING pre-processing Data for Chin: %s;  Cond: %s\n',Chins2Run{ChinIND},Conds2Run{CondIND})
        end
        here = pwd;
		
        %After checking, complete preprocessing...
		if ~SKIP
            %preprocess1_MEMR in main folder (not subfunctions)
			memrDATA1 = preprocess1_MEMR(DATAdir,ANALYSISdir,Chins2Run{ChinIND},Conds2Run{CondIND},filename);
        end	
	end   % Cond loop
	
	%Make sure all figures are closed
	close all;
end  % Chin loop


