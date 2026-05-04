function [peaks, latencies] = findPeaks_dtw(t_signal, signal,template,latencies_template,tolerance,snap_to_localminmax)
%FINDPEAKS_DTW Summary of this function goes here
%   Detailed explanation goes here


    if ~exist('tolerance','var')
        tolerance = 20;
    end

    if ~exist('snap_to_localminmax','var')
        snap_to_localminmax = 1;
    end
        
    [~, xi, yi] = dtw(template/max(template),signal/max(signal),tolerance);
    
    for i = 1:size(latencies_template,1)
         warp_ind_temp = find(xi==latencies_template(i,3));
         warp_ind(i) = round(mean(warp_ind_temp));
    end 
    
    sig_inds = yi(warp_ind);
    frame_sig = 1:length(signal);

    if snap_to_localminmax
        %ASSUMPTION - order of latencies is Peak -> Negative -> Peak ->
        %Negative. This will change whether min or max is identified.
        %refining to identify nearest local max/min
    
        %derivative
        signal = signal(:);
        deriv = [signal',0]-[0,signal'];
        deriv = deriv(2:end);
        
        %simplify by making it a slope direction instead of value
        pos = 1*(deriv>0);
        neg = -1*(deriv<0);
        slope_dir = pos+neg;
        
        ddir = [slope_dir,0]-[0,slope_dir];
        ddir = ddir(2:end);
    
        pks = find(ddir<0)+1; %need to shift by one, since position is .5 shifted/derivative
        vals = find(ddir>0)+1;

        %make sure pks/vals are in range. 
        pks = pks(pks<length(signal));
        vals = vals(vals<length(signal));

        for j = 1:length(sig_inds)
            
            if mod(j,2)==0 %Ns
                [~,ind] = min(abs(sig_inds(j)-vals));
                sig_inds(j) = vals(ind);
            else %Ps
                [~,ind] = min(abs(sig_inds(j)-pks));
                sig_inds(j) = pks(ind);
            end
        end 
    
    end

    peaks = signal(sig_inds);
    latencies = t_signal(sig_inds);

%     figure;
%     hold on
%     plot(t_signal,signal)
%     plot(latencies, peaks,'*k')
%     hold off
end

