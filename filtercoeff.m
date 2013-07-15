function [Band] = filtercoeff(lowcutoff,highcutoff,fs)
% script created by Richard Balson 12/03/2013

% description
% ~~~~~~~~~~~
% This script determines the filter coefficients to remove noise and dc
% from  the data, the inputs are frequencies for a low and high cutoff,
% with sampling frequency fs. The output is coefficients for a band pass
% filter with the speicifed cutoff frequencies. Notice for this
% implementation the number of filter coefficients is equal to the sampling
% frequency
 
 Filter_coeff = fs; % 20000 Specifiy number of filter coeffiecients
 
 fNyq = fs/2; % Determine the nyquist frequency
 
 % Normalise cutoff frequencies
normalised_low = lowcutoff/fNyq; % Normalise low cutoff
normalised_high = highcutoff/fNyq; % Normalise high cutoff

% Determine filter co-efficients using and FIR filter
Band = firfilter(Filter_coeff,[normalised_high normalised_low]); % Determine the filter coefficients for a bandpass filter