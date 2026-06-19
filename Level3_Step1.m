%%% STEP 1
close all;
clear all;

fs = 16*10^3;
fp = zeros(1, 128);
Qp = zeros(1, 128);
BWp = zeros(1, 128);
thetap = zeros(1, 128);
radiusp = zeros(1, 128);
b1 = zeros(1, 128);
b2 = zeros(1, 128);
B = zeros(128,3);

for k = 1:128
    fp(129 - k) = 8000*10^(-0.667*0.02293*k);
end
for k = 1:128
    Qp(k) = (5/127)*k - 640/127 + 10;
    BWp(k) = fp(k)/Qp(k);
    thetap(k) = (2*pi*fp(k))/fs;
    radiusp(k) = 1 - (BWp(k)/fs)*pi;
    b1(k) = 2*radiusp(k)*cos(thetap(k));
    b2(k) = (radiusp(k))^2;
    B(k,:) = [1 -b1(k) b2(k)];
end

% figure
% % plot(fp)
% % n = [4 64 128];
a = [1 0 -1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 2

A = poly(a);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 3

L = 160;

[y, ~] = audioread("speech.wav");
filtered_data = zeros(length(y), 128);
length_y = length(y);
sum = zeros(length_y, 1);
for k = 1:128
    equation_result = impz(a, B(k, :), L);
    filtered_data(:, k) = filter(equation_result, 1, y);
    sum(:, 1) = sum(:, 1) + filtered_data(:, k);
end

% soundsc(sum, fs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 4

h_n = zeros(128, L);
g_n = zeros(128, L);

for k = 1:128
    h_n(k, :) = impz(a, B(k, :), L);
    g_n(k, :) = flip(h_n(k, :));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 5

combined_coeff = zeros(128, (2*L-1));
for k = 1:128
    combined_coeff(k, :) = conv(h_n(k, :), g_n(k, :));
end

[y, Fs] = audioread("speech.wav");
% [y, ~] = audioread("Recording.wav");
filtered_data = zeros(length(y), 128);
length_y = length(y);
sum = zeros(length_y, 1);
for k = 1:128
%     equation_result = impz(a, B(k, :), 2*L);
    filtered_data(:, k) = filter(combined_coeff(k, :), 1, y);
    sum(:, 1) = sum(:, 1) + filtered_data(:, k);
end

% soundsc(sum, fs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  LEVEL 3  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t = 0:(1/fs):1;
sine_results = zeros(length(t), 128);
maximum_filter_gain = zeros(1, 128);
filter_gain = zeros(1, 128);
impz_results = zeros(length(t), 128);

zeroth_spatial_diff = zeros(length(t), 128);
first_spatial_diff = zeros(length(t), 128);
second_spatial_diff = zeros(length(t), 128);
for k = 1:128
    sine = sin(2*pi*fp(k)*t);
    sine_results(:, k) = filter(A, B(k, :), sine);
    impz_results(:, k) = impz(A, B(k, :), length(t));
    maximum_filter_gain(k) = max(abs(sine_results(:, k)));
    filter_gain(k) = 1/maximum_filter_gain(k);

    zeroth_spatial_diff(:, k) = filter_gain(k) * impz_results(:, k);
end

for k = 1:127
    first_spatial_diff(:, k) = zeroth_spatial_diff(:, k) - zeroth_spatial_diff(:, k+1);
end

for k = 1:126
    second_spatial_diff(:, k) = first_spatial_diff(:, k) - first_spatial_diff(:, k+1);
end

% for k = 1:128
%     for i = 1:(length(t)-1)
%         first_spatial_diff(i, k) = zeroth_spatial_diff(i, k) - zeroth_spatial_diff(i+1, k);
%     end
% end
% 
% for k = 1:128
%     for i = 1:(length(t)-2)
%        second_spatial_diff(i, k) = first_spatial_diff(i, k) - first_spatial_diff(i+1, k); 
%     end
% end

% filter 84
[H, w] = freqz(zeroth_spatial_diff(:, 84), 1);
figure
semilogx(fs*w/(2*1000*w(end)), 20*log10(abs(H)/max(abs(H))))
% plot(fs*w/(2*1000*w(end)), 20*log10(abs(H)/max(abs(H))))

hold on
[H, w] = freqz(first_spatial_diff(:, 84), 1);
semilogx(fs*w/(2*1000*w(end)), 20*log10(abs(H)/max(abs(H))), 'LineStyle','--')
% plot(fs*w/(2*1000*w(end)), 20*log10(abs(H)/max(abs(H))), 'LineStyle','--')

hold on
[H, w] = freqz(second_spatial_diff(:, 84), 1);
semilogx(fs*w/(2*1000*w(end)), 20*log10(abs(H)/max(abs(H))), 'LineStyle','-.')
% plot(fs*w/(2*1000*w(end)), 20*log10(abs(H)/max(abs(H))), 'LineStyle','-.')

axis([1.1 2.5 -40 0])
ylabel('Magnitude (dB)')
xlabel('log(Frequency)')
title('Magnitude Response of Filter 84')
legend('No Spatial Differentiation', '1 Spatial Differentiation', '2 Spatial Differentiation')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sine = sin(2*pi*fp(60)*t) + sin(2*pi*fp(100)*t);
for k = 1:128
    sine_results(:, k) = filter(A, B(k, :), sine);
%     impz_results(:, k) = impz(A, B(k, :), length(t));
    maximum_filter_gain(k) = max(abs(sine_results(:, k)));
    filter_gain(k) = 1/maximum_filter_gain(k);

    zeroth_spatial_diff(:, k) = filter_gain(k) * sine_results(:, k);
end

for k = 1:127
    first_spatial_diff(:, k) = zeroth_spatial_diff(:, k) - zeroth_spatial_diff(:, k+1);
end

for k = 1:126
    second_spatial_diff(:, k) = first_spatial_diff(:, k) - first_spatial_diff(:, k+1);
end

fc = 30;
c_0 = exp(-2*pi*fc/fs);
output_v_n = zeros(length(t), 128);
for k = 2:126
    output_v_n(:, k) = (1 - c_0).*second_spatial_diff(:, k) + c_0.*output_v_n(:, k - 1);
end

time_instant = 1000;
figure
subplot 411
% plot(zeroth_spatial_diff(time_instant, :)/norm(zeroth_spatial_diff(time_instant, :)));
% [temp1, temp2] = impz(zeroth_spatial_diff(time_instant, :), 1);
% plot(zeroth_spatial_diff(time_instant, :)/max(abs(zeroth_spatial_diff(time_instant, :))))
plot(zeroth_spatial_diff(time_instant, :))
title("Displacement before spatial differentation s_1[n]...s_N[n]")
xlabel("Displacement")


subplot 412
% plot(first_spatial_diff(time_instant, :)/max(abs(first_spatial_diff(time_instant, :))))
plot(first_spatial_diff(time_instant, :))
title("Displacement after first spatial differentation d_1[n]...d_N[n]")
xlabel("Displacement")
axis([0 128 -0.4 0.6])

subplot 413
% plot(second_spatial_diff(time_instant, :)/max(abs(second_spatial_diff(time_instant, :))))
plot(second_spatial_diff(time_instant, :))
title("Displacement after second spatial differentation e_1[n]...e_N[n]")
xlabel("Displacement")
axis([0 128 -0.6 0.4])

subplot 414
% plot(output_v_n(time_instant, :)/max(abs(output_v_n(time_instant, :))))
% plot((output_v_n(time_instant, :)/max(abs(output_v_n(time_instant, :)))))
plot(impz(output_v_n(time_instant, :), 1)/max(abs(output_v_n(time_instant, :))))
title("Inner hair cell output E_1...E_N")
xlabel("Energy")
ylabel("Filter Number")




%%%%%%%%%%%%%%%%%%%%%%%%
t = 0:(1/1500):1;
sine_results = zeros(length(t), 128);
maximum_filter_gain = zeros(1, 128);
filter_gain = zeros(1, 128);
impz_results = zeros(length(t), 128);

zeroth_spatial_diff = zeros(length(t), 128);
first_spatial_diff = zeros(length(t), 128);
second_spatial_diff = zeros(length(t), 128);

% sine = audiorecorder(fs);
% recordblocking(sine, 5);
% sine = getaudiodata(sine);
% record voice into .wav format, then use audioread at fs = 16k

% sine = sin(2*pi*fp(20)*t) + sin(2*pi*fp(40)*t) + sin(2*pi*fp(60)*t) + sin(2*pi*fp(80)*t) + sin(2*pi*fp(100)*t) + sin(2*pi*fp(120)*t);
clear sine
samples = [2*fs+1, 2*fs+length(t)];
[sine, ~] = audioread("Recording.wav", samples);
% audiowrite(sine, temp, fs);
% [y, Fs] = audioread(sine);

for k = 1:128
    sine_results(:, k) = filter(A, B(k, :), sine);
    impz_results(:, k) = impz(A, B(k, :), length(t));
    maximum_filter_gain(k) = max(abs(sine_results(:, k)));
    filter_gain(k) = 1/maximum_filter_gain(k);

    zeroth_spatial_diff(:, k) = filter_gain(k) * impz_results(:, k);
end

for k = 1:127
    first_spatial_diff(:, k) = zeroth_spatial_diff(:, k) - zeroth_spatial_diff(:, k+1);
end

for k = 1:126
    second_spatial_diff(:, k) = first_spatial_diff(:, k) - first_spatial_diff(:, k+1);
end


figure
subplot 211
% [H, w] = freqz(second_spatial_diff(time_instant, :), 1);
% plot(fs*w/(2*1000*w(end)), 20*log10(abs(H)/max(abs(H))))
X = 1:128;
% plot(X, 20*log10(second_spatial_diff(time_instant, :)))
plot(X, (second_spatial_diff(time_instant, :)))
xlabel("Filter Number")
ylabel("Magnitude (dB)")
title("Output of Spectrum Analyser at time instant")

subplot 212
temp = fft(sine);
plot(abs(temp))
% xlabel("Frequency (Hz)")
% ylabel("|fft(sine)|")
title("Magnitude Spectrum of input signal")