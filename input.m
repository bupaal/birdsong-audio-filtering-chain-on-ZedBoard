%% ============================================
%  Birdsong to HEX + Correct FIR Scaling + Target Level
% ============================================
clc; clear; close all;

%% Read mono audio
[signal, fs] = audioread('birdsong.wav');
if size(signal,2) > 1, signal = signal(:,1); end
signal = signal / max(1e-12, max(abs(signal)));

% int16 hex for testbench/ROM
sig_i16 = int16(max(-1, min(1, signal)) * 32767);
fid = fopen('birdsong.hex','w');
for i = 1:numel(sig_i16)
    fprintf(fid, '%04X\n', typecast(sig_i16(i), 'uint16'));
end
fclose(fid);
disp('✅ birdsong.hex written.');

%% FIR band-pass (2–6 kHz), 65 taps (N=64 gives 65 coeffs)
f_low  = 2000;
f_high = 6000;
N = 64;                   % order -> 65 taps
Wn = [f_low f_high]/(fs/2);
b = fir1(N, Wn, 'bandpass', hamming(N+1));

% >>> Correct scaling for band-pass:
% Normalize so peak passband gain ≈ 1 (not by sum(b)!)
[H, ww] = freqz(b,1,8192,fs);
pass = (ww >= f_low & ww <= f_high);
gpb = max(abs(H(pass)));
if gpb < 1e-9, gpb = 1; end
b = b / gpb;

% Optional modest boost if desired in hardware by shifting, not here.
% Keep headroom for Q15 quantization.
bq = round(b * 32767);
bq = max(-32768, min(32767, bq));
coeff_int16 = int16(bq);

% Save coeffs (65 lines)
fid = fopen('coeffs.hex','w');
for i = 1:numel(coeff_int16)
    fprintf(fid, '%04X\n', typecast(coeff_int16(i), 'uint16'));
end
fclose(fid);
disp('✅ coeffs.hex written.');

%% Quick sanity: filtered reference & suggested post gain
y_ref = filter(b,1,signal);
% Use 95th percentile to pick a safe loudness target (~-1 dBFS)
p95 = prctile(abs(y_ref), 95);
safe_target = 0.89; % ~ -1 dBFS margin
pgain = (p95>1e-9) * (safe_target / p95);
y_loud = max(-1, min(1, y_ref * pgain));
audiowrite('filtered_preview.wav', y_loud, fs);
disp('✅ filtered_preview.wav written (software preview of FIR+gain).');
