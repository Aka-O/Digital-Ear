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
a = [1 0 -1];

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



% centre frequency 1kHz = filter 70

combined_coeff = zeros(128, (2*L-1));
for k = 1:128
    combined_coeff(k, :) = conv(h_n(k, :), g_n(k, :));
end

% samples = [2*fs, 2*fs+1000];
samples = [1, 1000];
[y, Fs] = audioread("speech.wav", samples);
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  LEVEL 4  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 1


% Analysis Filter Output
% equation_result = impz(a, B(k, :), L);
%  filtered_data(:, k) = filter(equation_result, 1, y);\

% [y, Fs] = audioread("music.wav");
% [y, Fs] = audioread("speech.wav");
rectified_data = zeros(length(y), 128);
for k = 1:128
    equation_result = impz(a, B(k, :), L);
    filtered_data(:, k) = filter(equation_result, 1, y);
    for i = 1:length(y)
        if filtered_data(i, k) > 0
            rectified_data(i, k) = filtered_data(i, k);
        end
    end
end


figure
subplot 211
plot(rectified_data(:, 50))
title("Half wave rectified: Filter No 50 (speech.wav)")
xlabel("Sample Number")
ylabel("Amplitude x_m[n]")

subplot 212
[peaks, locs] = findpeaks(rectified_data(:, 50));
% stem(samples, peaks)
stem(locs, peaks)
xlabel("Sample Number")
ylabel("Peak amplitude")
title("Positive Peaks of x_m[n]: Filter No 50")





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 2


tau = 0.009;
c_0 = exp(-tau);
y_mn = zeros(length_y, 128);
x_mn = rectified_data;

% y_mn(:, 1) = x_mn(:, 1);
for k = 1:128
    for i = 2:length_y
        if x_mn(i, k) > (c_0*y_mn(i-1, k))
            y_mn(i, k) = x_mn(i, k);
        else 
            y_mn(i, k) = c_0*y_mn(i-1, k);
        end
    end
end

figure
subplot 211
stem(locs, peaks)
hold on
plot(y_mn(:, 50), 'LineStyle', '--')
% plot(y_mn(:, 50), 'LineStyle', '--')
title("Masking Threshold y_m[n]")
ylabel("Amplitude")
xlabel("Sample Number")

% for k = 1:length(peaks)
%     if peaks(k) < y_mn(locs(k), 50)
%         peaks(k) = 0;
%     end
% end

peaks = zeros(35, 128);
locs = zeros(35, 128);
for k = 1:128
    [temp1, temp2] = findpeaks(rectified_data(:, 50));
    peaks(:, k) = temp1;
    locs(:, k) = temp2;
end

for i = 1:128
    for k = 1:length(peaks)
        if peaks(k) < y_mn(locs(k), 50)
            peaks(k) = 0;
        end
    end
end

% temp = zeros(35, 1);
for k = 1:128
    for i = 1:35
        if peaks(i, k) < y_mn(locs(i, k), k)
            peaks(i, k) = 0;
        end
    end
end

% for k = 1:length(peaks)
%     if peaks(k) < y_mn(locs(k), 50)
%         peaks(k) = 0;
%     end
% end


subplot 212
stem(locs(:, 50), peaks(:, 50))
title("Unmasked Pulse Train")
ylabel("Amplitude")
xlabel("Sample Number")














%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 3



samples = [2*fs, (2*fs) + 1000];
[y, Fs] = audioread("music.wav", samples);
filtered_data = zeros(length(y), 128);
length_y = length(y);
sum = zeros(length_y, 1);
for k = 1:128
    filtered_data(:, k) = filter(combined_coeff(k, :), 1, y);
    sum(:, 1) = sum(:, 1) + filtered_data(:, k);
end

% soundsc(sum, fs);


% h_n = zeros(128, L);          % analysis
% g_n = zeros(128, L);          % synthesis



y_mn = zeros(length_y, 128);
x_mn = rectified_data;
for k = 1:128
    for i = 2:(length_y - 1)
        if x_mn(i, k) > (c_0*y_mn(i-1, k))
            y_mn(i, k) = x_mn(i, k);
        else 
            y_mn(i, k) = c_0*y_mn(i-1, k);
        end
    end
end    

peaks = zeros(length_y, 128);
locs = zeros(length_y, 128);
for k = 1:128
    [temp1, temp2] = findpeaks(rectified_data(:, k));
    peaks(:, k) = temp1;
    locs(:, k) = temp2;
end

for i = 1:128
    for k = 1:length(peaks)
        if peaks(k) < y_mn(locs(k), 50)
            peaks(k) = 0;
        end
    end
end

sum = zeros(length_y, 1);
for k = 1:128
    for i = 1:35
        if peaks(i, k) < y_mn(locs(i, k), k)
            peaks(i, k) = 0;
        end
    end
%     sum(:, 1) = sum(:, 1) + rectified_data(:, k);
end

% rectified_data = zeros(length(y), 128);
% for k = 1:35
%     for i = 1:128
% %         sum(locs(k)) = sum(locs(k)) + peaks(i, k);
%         rectified_data(locs(i, k), k) = peaks(i, k);
%     end
% end
% 
% for k = 1:128
%     sum(:, 1) = sum(:, 1) + rectified_data(:, k);
% end

% soundsc(sum, fs);







