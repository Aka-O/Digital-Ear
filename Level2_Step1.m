%%% STEP 1


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

figure
% plot(fp)
% n = [4 64 128];
a = [1 0 -1];

subplot 311
[h1, ~] = impz(a, B(4,:), 1000);
plot(h1);
title("Impulse Response of Filter with fp = 98Hz")

subplot 312
[h2, ~] = impz(a, B(64,:), 150);
plot(h2);
title("Impulse Response of Filter with fp = 811Hz")

subplot 313
[h3, ~] = impz(a, B(128,:), 20);
plot(h3);
title("Impulse Response of Filter with fp = 7723Hz")



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 2



figure
hold on
grid on

A = poly(a);
[HA, w] = freqz(A, B(45, :));
% w = w/(2*pi);
plot(2.5*w, 20*log10(abs(HA)/max(abs(HA))))

[HB, w] = freqz(A, B(65, :));
% w = w/(2*pi);
plot(2.5*w, 20*log10(abs(HB)/max(abs(HB))))

xlim([0 2.5])
ylim([-30 0])
title("Magnitude Responses")
ylabel('Magnitude (dB)')
xlabel('Frequency (Hz)')


figure
subplot 221
[h1, t1] = impz(a, B(45,:), 160);
plot(h1);
title("Impulse Response of Filter with fp = 416Hz")
% xlim([0, 160]);

subplot 222
[h2, t2] = impz(a, B(65,:), 160);
plot(h2);
title("Impulse Response of Filter with fp = 840Hz")
% xlim([0 160]);

[HC, w] = freqz(A, B(100, :));
subplot 223
hold on
plot((8*w/w(end)), 20*log10(abs(HC)/max(abs(HC))))

title('Magnitude Response of Analysis Filter')
ylabel('Magnitude (dB)')
axis([0 8 -50 0])

subplot 224
plot(8*w/w(end), unwrap(angle(HC)))
axis([0 8 -2 4])
xlabel('Frequency (khz)')
ylabel('Phase (rad)')
title('Phase Response of Analysis Filter')





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 3

L = 160;

% figure
% hold on
% impz(a, B(70, :), L);
% [H, w] = freqz(A, B(70, :));
% plot(w/w(end), 20*log10(abs(H)/max(abs(H))));

figure
hold on
% filters 18, 30, 42, 66, 78, 90, 102, 114, 126
plot_filters = [18 30 42 66 78 90 102 114 126];
for k = 1:length(plot_filters)
    [H, w] = freqz(A, B(plot_filters(k), :));
    plot(8*w/pi, 20*log10(abs(H)/max(abs(H))))
end


axis([0 8 -15 0])
title("Magnitude Responses of the Analysis Filters")
ylabel('Magnitude (dB)')
xlabel('Frequency (kHz)')


[y, ~] = audioread("music.wav");
% [y, Fs] = audioread("speech.wav");
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

figure
subplot 311
plot(h_n(100,:));
title('Impulse Response of Analysis Filter 100; fp = 2882 Hz')
ylabel('h[n]')

subplot 312
plot(g_n(100,:));
title('Impulse Response of Synthesis Filter 100')
ylabel('g[n]')

subplot 313
plot(conv(h_n(100,:), g_n(100,:)))
title('Impulse Response of Combined Analysis & Synthesis Filters 100')
ylabel('h*g')
xlabel('Sample Index')



figure
subplot 221
[HA, w] = freqz(h_n(100, :), 1);
plot((8*w/w(end)), 20*log10(abs(HA)/max(abs(HA))))
axis([0 8 -50 0])
grid on
title('Magnitude Response of Analysis Filter')
ylabel('Magnitude (dB)')

subplot 222
plot(8*w/w(end), unwrap(angle(HA)))
axis([0 8 -2 4])
grid on
title('Phase Response of Analysis Filter')
ylabel('Phase (rad)')

[HB, w] = freqz(conv(h_n(100,:), g_n(100,:)), 1);
subplot 223
plot((8*w/w(end)), 20*log10(abs(HB)/max(abs(HB))))
axis([0 8 -50 0])
grid on
title('Magnitude Response of Combined Filters')
ylabel('Magnitude (dB)')
xlabel('Frequency (kHz)')

subplot 224
plot(8*w/w(end), unwrap(angle(HB)))
axis([0 8 -500 0])
grid on
title('Phase Response of Combined Filters')
ylabel('Phase (rad)')
xlabel('Frequency (kHz)')


plot_filters = [18 30 42 66 78 90 102 114 126];
figure
subplot 211
hold on
for k = 1:length(plot_filters)
    [H, w] = freqz(h_n(plot_filters(k), :), 1);
    plot(8*w/w(end), 20*log10(abs(H)/max(abs(H))))
end
title('Magnitude Response of the Analysis Filters')
ylabel('Magnitude (dB)')
xlabel('Frequency (Hz)')
axis([0 8 -15 0])

subplot 212
hold on
for k = 1:length(plot_filters)
    [H, w] = freqz(g_n(plot_filters(k), :), 1);
    plot(8*w/w(end), 20*log10(abs(H)/max(abs(H))))
end
title('Magnitude Response of the Synthesis Filters')
ylabel('Magnitude (dB)')
xlabel('Frequency (Hz)')
axis([0 8 -15 0])





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 5



% centre frequency 1kHz = filter 70
figure
hold on
[H, w] = freqz(g_n(70, :), 1);
plot(8*w/w(end), 20*log10(abs(H)/max(abs(H))))

[H, w] = freqz(h_n(70, :), 1);
plot(8*w/w(end), 20*log10(abs(H)/max(abs(H))))

A = poly(a);
[HA, w] = freqz(A, B(45, :));
% w = w/(2*pi);
plot(2.5*w, 20*log10(abs(HA)/max(abs(HA))))

[HB, w] = freqz(A, B(65, :));
% w = w/(2*pi);
plot(2.5*w, 20*log10(abs(HB)/max(abs(HB))))

xlim([0 2.5])
ylim([-30 0])
title("Magnitude Responses")
ylabel('Magnitude (dB)')
xlabel('Frequency (Hz)')

grid on
title('Magnitude Response of Filter 70')
ylabel('Magnitude (dB)')



combined_coeff = zeros(128, (2*L-1));
for k = 1:128
    combined_coeff(k, :) = conv(h_n(k, :), g_n(k, :));
end

[y, Fs] = audioread("music.wav");
% [y, Fs] = audioread("speech.wav");
filtered_data = zeros(length(y), 128);
length_y = length(y);
sum = zeros(length_y, 1);
for k = 1:128
%     equation_result = impz(a, B(k, :), 2*L);
    filtered_data(:, k) = filter(combined_coeff(k, :), 1, y);
    sum(:, 1) = sum(:, 1) + filtered_data(:, k);
end

soundsc(sum, fs);


