function lpFilter = Lowpass_filter(Fs, cutoffFreq, filterOrder)
    % Design a Butterworth low-pass filter
    % Fs          = Sampling Frequency (Hz)
    % cutoffFreq  = Cutoff Frequency (Hz)
    % filterOrder = Order of the Filter

    % Normalize cutoff frequency (convert to Nyquist frequency scale)
    Wn = cutoffFreq / (Fs / 2); 
    
    % Create Butterworth filter coefficients
    [b, a] = butter(filterOrder, Wn, 'low'); 
    
    % Return filter object
    lpFilter = dfilt.df2t(b, a); 
end