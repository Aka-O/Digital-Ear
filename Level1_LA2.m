% Impulse and magnitude response calculation of an auditory filter
clc; 
clear; 
close all;
fs=20000;
num_filter = 128; % nubmer of filters
NFFT=1024; % number of FFT points
% 2.9985 and 0.0869 are xmax and xmin
delta_x = (2.9985-0.0869)/(num_filter-1);
k = 128:-1:1; % filter index
fp = 8000*10.^(-0.667*k*delta_x); % centre frequencies
% Auditory filter parameters
b=1.14;
T=1/fs; % sampling period
N=4; % order of filter
n=0:199; % sample index
% filter's impulse response
g = zeros(200, 1);
for i=1:num_filter
    g(:,i)=((n*T).^(N-1)).*exp(-2*pi*b*(24.7+0.108*fp(i))*n*T).*cos(2*pi*fp(i)*n*T);
end
G=fft(g, NFFT); % filter's frequency response in [0 fs]
G=abs(G(1:NFFT/2,:)); % filter's magnitude response in [0 fs/2]
for i=1:num_filter
% normalize all the impulse response max to 1
g(:,i)=g(:,i)/max(abs(G(:,i)));
end
G=fft(g, NFFT); % normalised filter's frequency response in [0 fs]
% normalised filter's magnitude response [0 to fs/2] in dB
G = 20*log10(abs(G(1:NFFT/2,:)));
% est. filter's bandwidth
% i.e, width of freq. region where filter's gain > -3dB
freqHz = fs*(0:NFFT-1)/NFFT; % frequency axis [0 fs]
freqHz = freqHz(1:NFFT/2); % frequency axis [0 fs/2]
BW = zeros(1, 128);
for i=1:num_filter
    % find frequency index in passband region of filter
    pass_band_freqID = find(G(:,i)>=-3);
    % Bandwidth of filter
    BW(i) = freqHz(pass_band_freqID(end)) - freqHz(pass_band_freqID(1));
end

Q = fp./BW; % Q factor of filter (Selectivity)
figure
subplot 311
plot(fp/10^3) % plot centre frequencies
xlim([1 num_filter])
ylabel('fp (kHz)')
title('Filter''s centre frequency')

subplot 312
plot(BW/10^3) % plot bandwidth
ylabel('BW (kHz)')
xlim([1 num_filter])
title('Filter''s bandwidth')

subplot 313
plot(Q) % plot Q factor
xlim([1 num_filter])
ylabel('Q')
xlabel('Filter number')
title('Filter Q factor')

figure
vlimit=[0.02 0.05 0.1 0.5];
checked_filter_index = [70, 90, 110, 121];
for i = 1:length(checked_filter_index)
    subplot(4,1,i)
    plot(g(:,checked_filter_index(i)))
    axis([0 200 min(g(:,checked_filter_index(i))) max(g(:,checked_filter_index(i)))])
    title(['Impulse response of filter ' num2str(i) '; fp=' num2str(round(fp(i))) 'Hz'])
end
xlabel('Sample index')

figure
plot(freqHz/10^3,G(:,checked_filter_index));
hold on
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
axis([0, fs/2/10^3 -50 0]);
ylim([-30 0]);
title('Magnitude response of 4 selected filters');
grid on;

figure
plot(freqHz/10^3,G(:,:));
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
axis([0, fs/2/10^3 -50 0]);
ylim([-30 0]);
title('Magnitude response of all filters');