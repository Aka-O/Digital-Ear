% Learning Activity 1
% Outer Ear
fs = 20*10^3;
z1 = 0.8;
z2 = 0.8;
z3 = -0.9 + 0.1i;
z4 = -0.9 - 0.1i;
% z5 = 0.5i;
% z6 = -0.5i;

p1 = 0;
p2 = 0;
p3 = 0.8 + 0.5i;
p4 = 0.8 - 0.5i;

z_oear = [z1, z2, z3, z4];
p_oear = [p1, p2, p3, p4];
b = poly(z_oear);
a = poly(p_oear);

figure
sgtitle('Outer Ear Implementation')
subplot 211
zplane(b, a);
title('Pole-Zero Plot')

subplot 212
n = 1024;
[H, w] = freqz(b, a, n);
mag_db = 10*log10(abs(H));
semilogx(fs/2*(w/w(end)), mag_db);
grid on;
title('Magnitude Response')
ylabel('Magnitude (dB)')
xlabel('Frequency (Hz)')




% % Middle Ear
% z1 = 0.95;
% z2 = 0.95;
% z3 = -0.4 + 0.1i;
% z4 = -0.4 - 0.1i;
% 
% p1 = 0;
% p2 = 0;
% p3 = 0.9 + 0.3i;
% p4 = 0.9 - 0.3i;
% 
% z_mear = [z1 z2 z3 z4];
% p_mear = [p1 p2 p3 p4];
% b = poly(z_mear);
% a = poly(p_mear);
% 
% figure
% sgtitle('Middle Ear Implementation')
% subplot 211
% zplane(b,a)
% title('Pole-Zero Plot');
% 
% n = 1024;
% k0 = 20;
% [H, w] = freqz(k0*b, a, n);
% subplot 212
% semilogx(fs/2*w/w(end), 10*log(abs(H)));
% grid on
% xlabel('Frequency (Hz)')
% ylabel('Magnitude (dB)')
% title('Approximate mag. res. of middle ear')
% 
% 
% 
% 
% % Combined
% z_combined = [z_oear z_mear];
% p_combined = [p_oear p_mear];
% 
% b = poly(z_combined);
% a = poly(p_combined);
% 
% figure
% sgtitle('Outer Ear and Middle Ear Implementation')
% subplot 211
% zplane(b, a);
% title('Pole-Zero Plot')
% 
% n = 1024;
% k0 = 100;
% [H, w] = freqz(k0*b, a, n);
% subplot 212
% semilogx(fs/2*w/w(end), 10*log10(abs(H)));
% grid on
% xlabel('Frequency (Hz)')
% ylabel('Magnitude (dB)')
% title('Approximate mag. res. of outer and middle ear')