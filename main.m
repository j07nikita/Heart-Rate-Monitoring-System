function [] = main(trainDir, testDir, outDir)
cd testDir;
files = dir(fullfile(testDir, '*.mat'));

for itr = 1:length(files)
    load(files(itr).name);
    sig = sig(2:end,:);
    % disp('HEYyasdsa'); 
    sampling_rate = 125;							% 125 Hz
    N = 60 * sampling_rate;                               
	f = 60*sampling_rate * [ 0 : 1 :N- 1 ]./N;
    window_length   = 8 * sampling_rate;                    % window length is 8 seconds
    jump     = 2 * sampling_rate;
    % disp('Ysad');                    % jump size is 2 seconds    
    window_number = (length(sig)-window_length)/jump + 1;  % total number of windows    
%     figure; plot(PPG_average);
%     figure; plot(x_acceleration);
%     figure; plot(y_acceleration);
%     figure; plot(z_acceleration);
    peaks_all = [];
    for i = 1 : window_number
    	last_value = (i-1) * jump + window_length;
    	if ((i-1)*jump+window_length > length(sig(2,:)))
    		last_value = length(sig(2,:));
    	end
        window_segment = round((i-1)*jump+1 : last_value);
    	peaks_all(i) = piece_filtering(sig(:,window_segment), sampling_rate, peaks_all);
    end
    pred = peaks_all(1:125);
    save(strcat(outDir, 'output_team_18_', files(fileindex).name), 'pred')
    % peaks = []
%     for i = 1 : window_number
% % 	    Find peaks and BPM without SPT
% 		[pks , locs]=findpeaks(peaks_all(i),f);
% 		[,index]= max (pks);
% 		peaks = locs(index) ;
%     	if(i > 3)
%     		peaks(i) = 0.9*peaks(i) + 0.05*peaks(i-2) + 0.05*peaks(i-1);
% 	   	end
%     end
end  
end