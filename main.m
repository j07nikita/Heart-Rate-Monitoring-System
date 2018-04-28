function [] = main(trainDir, testDir, outDir)
cd(testDir);
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
    save(strcat(outDir, 'output_team_18_', files(itr).name), 'pred')
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

function [y] = adaptive_filter(PPG,X,Y,Z)
	temp = zeros(1,length(PPG)) ;
	rlsFilt = dsp.RLSFilter(69 ,'ForgettingFactor', 0.990) ;
	[, err] = rlsFilt(X,PPG);
    temp = temp + err;
	[, err] = rlsFilt(Y,PPG);
	temp = temp + err;
	[, err] = rlsFilt(Z,PPG);
	temp = temp + err;
	y = temp;
end	

function x = band_pass(PPG,sample_rate)

% Bandpass Filter: 0.4 to 3.5Hz
%
    ff = fft(PPG);
    n = 0:1023;
    np = n*2*pi/1024;
    ff(np < 2*pi*0.4/sample_rate | np > 2*pi*(1-0.4/sample_rate)) = 0;
    ff(np > 2*pi*3.5/sample_rate & np < 2*pi*(1-3.5/sample_rate)) = 0;
    PPG1 = ifft(ff);
    x = real(PPG1);
end

function [pks, peakX] = fft_helper(signal,sampling_rate)
	% band_pass(sin)
	Y = fft(signal);
	L = length(signal);
	P2 = abs(Y/L);
	P1 = P2(1:L/2+1);
	P1(2:end-1) = 2*P1(2:end-1);
	f = sampling_rate*(0:(L/2))/L;
	% [peakY,peakX] = findpeaks(P1,f,'MinPeakHeight',10);
	[pks,locs] = findpeaks(P1,f);
	% plot()
	% disp(locs);
	[,index] = max(pks);
	disp(index);
	peakX = index;
	% [peakY, peakX] = findpeaks(P1, 'sortstr', 'descend');
	% [peakY,peakX] = findpeaks(p1(1:L/2),f,'MinPeakHeight',4000);
	% figure; plot(f,P1);
	% title('Single-Sided Amplitude Spectrum of S(t)');
	% xlabel('f (Hz)');
	% ylabel('|P1(f)|');

end

function [peakX] = piece_filtering(sig, sampling_rate, peaks)
    x_acceleration = band_pass(sig(3,:),sampling_rate);
    y_acceleration = band_pass(sig(4,:),sampling_rate);
	z_acceleration = band_pass(sig(5,:),sampling_rate);
	PPG_average = .5*(band_pass(sig(1,:),sampling_rate)+band_pass(sig(2,:),sampling_rate)); %averaging both channels	
	filtered_signal = adaptive_filter(PPG_average,x_acceleration,y_acceleration,z_acceleration);
	L = length(filtered_signal);
	[peakY,peakX] = fft_helper(filtered_signal, sampling_rate);
	% disp(L);
	peakX = peakX(1);
	peak = peakX;	
	f = sampling_rate*(0:(L/2))/L;
	N = 60 * sampling_rate;
	f = 60 * sampling_rate * [ 0 : 1 :N- 1 ]./N;
	Y_clean = abs(fft(filtered_signal ,N)).^2;
 %    if(length(peaks) > 3)
 %    	peak = 0.9*peak + 0.05*peaks(end) + 0.05*peaks(end-1);
	% end
end