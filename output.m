%% FIR Output → WAV
clc; clear; close all;

load('audio_params.mat','fs','SAMPLE_COUNT');

input_file  = 'output.hex';
output_file = 'birdsong_out.wav';

% === READ HEX FILE ===
fid = fopen(input_file, 'r');
hex_data = textscan(fid, '%s');
fclose(fid);

raw = hex2dec(hex_data{1});
audio_data = typecast(uint16(raw), 'int16');

% === Normalize ===
audio_norm = double(audio_data) / double(intmax('int16'));

% === Check duration ===
duration = numel(audio_norm)/fs;
fprintf('Duration = %.2f sec\n', duration);

% === Play & Save ===
sound(audio_norm, fs);
audiowrite(output_file, audio_norm, fs);
disp(['✅ Audio saved as ', output_file]);
