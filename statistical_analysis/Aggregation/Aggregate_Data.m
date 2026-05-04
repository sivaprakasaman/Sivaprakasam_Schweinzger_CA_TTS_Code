% Author: Andrew Sivaprakasam
% Last Update: Nov 2023
% Script to clean up data and put it in a csv for statistical Analysis

cwd = pwd();
cd('Aggregate/');

load('OAE_CA_TTS_IVY.mat');
% load('abr_thresh_out.mat');
load('abr_aggregate_2.mat');
load('abr_output_compiled.mat');
CA_chins_thresh_new = ca_chins;
TTS_chins_thresh_new = tts_chins;

%%
chins = ["Q403","Q405","Q408","Q409","Q406","Q407","Q410","Q411"];
chins_cond = ["CA","CA","CA","CA","TTS","TTS","TTS","TTS"];
chins_sex = ["M","M","F","F","M","M","F","F"];
exposed = [0,1,2]; %0 - Baseline, 1 - 24hrs, 2 - 2wks


abr_heads = ["P1","N1","P2","N2","P3","N3","P4","N4","P5","N5","Threshold"];
abr_heads = [abr_heads,strcat(abr_heads(1:end-1),"_Latency")];
heads_click = strcat("Click_",abr_heads);
heads_4k = strcat("4k_",abr_heads);

dp_heads = num2str(round(f2)');
dp_heads = split(dp_heads);
dp_heads = strcat('F2_',dp_heads)';
%may need to convert the above to string!

load("TTS_analyzeMEMRsAVG_clean.mat");
TTS_memr_data = MEMR_DATA;
MEMR_chins_T = cellfun(@(x) x.chin, TTS_memr_data, 'UniformOutput', false);
MEMR_chins_T = {MEMR_chins_T{:,1}};

load("CA_analyzeMEMRsAVG_clean.mat");
CA_memr_data = MEMR_DATA;
MEMR_chins_C = cellfun(@(x) x.chin, CA_memr_data, 'UniformOutput', false);
MEMR_chins_C = {MEMR_chins_C{:,1}};

load('TTS_Processed.mat');
TTS_efr_data = data_out;
TTS_chins = TTS_efr_data.chins;

load('CA_Processed.mat');
CA_efr_data = data_out;
CA_chins = CA_efr_data.chins;

memr_heads = num2str(MEMR_DATA{1,1}.elicitor);
memr_heads = split(memr_heads);
memr_heads = strcat('elicit_dbspl_',memr_heads)';
memr_heads{end+1} = 'Threshold';

efr_heads = ["SAM","SQ50","SQ25"];
efr_heads = strcat('R_PLV_',efr_heads);

header_full= ["Chin","Sex","Group","Exposed",heads_click,heads_4k,dp_heads,memr_heads,efr_heads];
aggregate_out = table();
nan_data = nan(1,length(header_full));

aggregate_out{:,:}=num2cell(nan_data);

aggregate_out.Properties.VariableNames = header_full;
abr_ind = find(strcmp(aggregate_out.Properties.VariableNames,'Click_P1'));
abr_ind = [abr_ind, abr_ind+2*length(abr_heads)-1]; %2 since click and 4k
dp_ind = find(strcmp(aggregate_out.Properties.VariableNames,'F2_500'));
dp_ind = [dp_ind, dp_ind+length(dp_heads)-1];

memr_ind = find(strcmp(aggregate_out.Properties.VariableNames,'elicit_dbspl_34'));
memr_ind = [memr_ind, memr_ind+length(memr_heads)-1];

efr_ind = find(strcmp(aggregate_out.Properties.VariableNames,'R_PLV_SAM'));
efr_ind = [efr_ind, efr_ind+length(efr_heads)-1];

row = 0;
%Chin Loop
for c = 1:length(chins)
    if chins_cond(c)=="CA"
        exposed = [0,2];
        %ABR
        c_ind_a = find(strcmp(chins(c),chins_C));
        c_ind_a_thresh = find(strcmp(chins(c),CA_chins_thresh_new));
        c_sub_inds = CA_inds(c_ind_a_thresh);
        %dp
        c_ind_d = find(strcmp(chins(c),chins_ca));
        %memr
        c_ind_m = find(strcmp(chins(c),MEMR_chins_C));
        %efr
        c_ind_e = find(strcmp(chins(c),CA_chins));
    else
        exposed = [0,1,2];
        %ABR
        c_ind_a = find(strcmp(chins(c),chins_T));
        c_ind_a_thresh = find(strcmp(chins(c),TTS_chins_thresh_new));
        c_sub_inds = TTS_inds(c_ind_a_thresh);
        %dp
        c_ind_d = find(strcmp(chins(c),chins_tts));
        %memr
        c_ind_m = find(strcmp(chins(c),MEMR_chins_T));
        %efr
        c_ind_e = find(strcmp(chins(c),TTS_chins));
    end

    for e = 1:length(exposed)
        row = row + 1;
        aggregate_out(row,1:4) = cellstr([chins(c), chins_sex(c), chins_cond(c),exposed(e)]);

        switch chins_cond(c)
            case "CA"

                if exposed(e)==0
                    %abr
%                     aggregate_out{row,abr_ind(1):abr_ind(2)} = num2cell([ca_pre_click_pks2(:,c_ind_a)',ca_pre_click_thresh(3,c_ind_a),ca_pre_click_lats2(:,c_ind_a)'...
%                         ca_pre_4k_pks2(:,c_ind_a)',ca_pre_4k_thresh(3,c_ind_a),ca_pre_4k_lats2(:,c_ind_a)']);
                    aggregate_out{row,abr_ind(1):abr_ind(2)} = num2cell([ca_pre_click_pks2(:,c_ind_a)',baseline(c_sub_inds,1),ca_pre_click_lats2(:,c_ind_a)'...
                        ca_pre_4k_pks2(:,c_ind_a)',baseline(c_sub_inds,2),ca_pre_4k_lats2(:,c_ind_a)']);
                    %dpoae
                    aggregate_out{row,dp_ind(1):dp_ind(2)} = num2cell(squeeze(dp_raw_ca(c_ind_d,1,:))');
                    %memr
                    aggregate_out{row,memr_ind(1):memr_ind(2)} = num2cell([CA_memr_data{c_ind_m,1}.y_clean,CA_memr_data{c_ind_m,1}.thresh]);
                    %efr
                    aggregate_out{row,efr_ind(1):efr_ind(2)} = num2cell([CA_efr_data.pre_post_SAM_rat(c_ind_e,1),CA_efr_data.pre_post_sq50_rat(c_ind_e,1)...
                        CA_efr_data.pre_post_sq25_rat(c_ind_e,1)]);
                elseif exposed(e)==2
%                     aggregate_out{row,abr_ind(1):abr_ind(2)} = num2cell([ca_post_click_pks2(:,c_ind_a)',ca_post_click_thresh(3,c_ind_a),ca_post_click_lats2(:,c_ind_a)'...
%                         ca_post_4k_pks2(:,c_ind_a)',ca_post_4k_thresh(3,c_ind_a),ca_post_4k_lats2(:,c_ind_a)']);
                    
                    aggregate_out{row,abr_ind(1):abr_ind(2)} = num2cell([ca_post_click_pks2(:,c_ind_a)',post(c_sub_inds,1),ca_post_click_lats2(:,c_ind_a)'...
                        ca_post_4k_pks2(:,c_ind_a)',post(c_sub_inds,2),ca_post_4k_lats2(:,c_ind_a)']);
                    aggregate_out{row,dp_ind(1):dp_ind(2)} = num2cell(squeeze(dp_raw_ca(c_ind_d,2,:))');
                    aggregate_out{row,memr_ind(1):memr_ind(2)} = num2cell([CA_memr_data{c_ind_m,2}.y_clean,CA_memr_data{c_ind_m,2}.thresh]);
                    aggregate_out{row,efr_ind(1):efr_ind(2)} = num2cell([CA_efr_data.pre_post_SAM_rat(c_ind_e,2),CA_efr_data.pre_post_sq50_rat(c_ind_e,2)...
                        CA_efr_data.pre_post_sq25_rat(c_ind_e,2)]);
                else
                    aggregate_out(row,abr_ind(1):abr_ind(2)) = NaN;
                    aggregate_out{row,dp_ind(1):dp_ind(2)} = NaN;
                    aggregate_out{row,efr_ind(1):efr_ind(2)} = NaN;
                end

            case "TTS"
                if exposed(e)==0
%                         aggregate_out{row,abr_ind(1):abr_ind(2)} = num2cell([tts_pre_click_pks2(:,c_ind_a)',tts_pre_click_thresh(3,c_ind_a),tts_pre_click_lats2(:,c_ind_a)'...
%                         tts_pre_4k_pks2(:,c_ind_a)',tts_pre_4k_thresh(3,c_ind_a),tts_pre_4k_lats2(:,c_ind_a)']);
                   aggregate_out{row,abr_ind(1):abr_ind(2)} = num2cell([tts_pre_click_pks2(:,c_ind_a)',baseline(c_sub_inds,1),tts_pre_click_lats2(:,c_ind_a)'...
                        tts_pre_4k_pks2(:,c_ind_a)',baseline(c_sub_inds,2),tts_pre_4k_lats2(:,c_ind_a)']);

                    aggregate_out{row,dp_ind(1):dp_ind(2)} = num2cell(squeeze(dp_raw_tts(c_ind_d,1,:))');

                    %MEMR data is missing for one TTS chin...
                    try
                        aggregate_out{row,memr_ind(1):memr_ind(2)} = num2cell([TTS_memr_data{c_ind_m,1}.y_clean,TTS_memr_data{c_ind_m,1}.thresh]);
                    catch
                        aggregate_out{row,memr_ind(1):memr_ind(2)} = num2cell(NaN);
                        disp(strcat('missing ',chins(c),' MEMR data!'));
                    end

                    aggregate_out{row,efr_ind(1):efr_ind(2)} = num2cell([TTS_efr_data.pre_post_SAM_rat(c_ind_e,1),TTS_efr_data.pre_post_sq50_rat(c_ind_e,1)...
                        TTS_efr_data.pre_post_sq25_rat(c_ind_e,1)]);

                elseif exposed(e)==1
                    aggregate_out{row,dp_ind(1):dp_ind(2)} = num2cell(squeeze(dp_raw_tts(c_ind_d,2,:))');

                    try
                        aggregate_out{row,memr_ind(1):memr_ind(2)} = num2cell([TTS_memr_data{c_ind_m,2}.y_clean,TTS_memr_data{c_ind_m,2}.thresh]);
                    catch
                        aggregate_out{row,memr_ind(1):memr_ind(2)} = num2cell(NaN);
                        disp(strcat('missing ',chins(c),' MEMR data!'));
                    end
                    aggregate_out{row,abr_ind(1):abr_ind(2)} = num2cell(NaN);
                    aggregate_out{row,efr_ind(1):efr_ind(2)} = num2cell(NaN);

                elseif exposed(e)==2
%                     aggregate_out{row,abr_ind(1):abr_ind(2)} = num2cell([tts_post_click_pks2(:,c_ind_a)',tts_post_click_thresh(3,c_ind_a),tts_post_click_lats2(:,c_ind_a)'...
%                         tts_post_4k_pks2(:,c_ind_a)',tts_post_4k_thresh(3,c_ind_a),tts_post_4k_lats2(:,c_ind_a)']);

                      aggregate_out{row,abr_ind(1):abr_ind(2)} = num2cell([tts_post_click_pks2(:,c_ind_a)',post(c_sub_inds,1),tts_post_click_lats2(:,c_ind_a)'...
                        tts_post_4k_pks2(:,c_ind_a)',post(c_sub_inds,2),tts_post_4k_lats2(:,c_ind_a)']);

                    aggregate_out{row,dp_ind(1):dp_ind(2)} = num2cell(squeeze(dp_raw_tts(c_ind_d,3,:))');
                    try
                        aggregate_out{row,memr_ind(1):memr_ind(2)} = num2cell([TTS_memr_data{c_ind_m,3}.y_clean,TTS_memr_data{c_ind_m,3}.thresh]);
                    catch
                        aggregate_out{row,memr_ind(1):memr_ind(2)} = num2cell(NaN);
                        disp(strcat('missing ',chins(c),' MEMR data!'));
                    end

                    aggregate_out{row,efr_ind(1):efr_ind(2)} = num2cell([TTS_efr_data.pre_post_SAM_rat(c_ind_e,2),TTS_efr_data.pre_post_sq50_rat(c_ind_e,2)...
                        TTS_efr_data.pre_post_sq25_rat(c_ind_e,2)]);
                end
        end
    end
end

cd(cwd)
writetable(aggregate_out,'all_ca_tts_data_updatedThreshold_Peaks.csv');
