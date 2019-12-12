% This script generates 4 empty sound signals separated by two noise burst
% of 5ms
% =========================================================================
% March 19, 2018
% G. Lemaitre for C. Lakhlifi
% =========================================================================
% November 27, 2019
% Y. Nedelec
% adapted to create 4 empty sounds of 400 475 500 525 600 ms
% =========================================================================

%% Init
clear
clc
close all

%% Global parameter
sr=44100; % Sampling rate 
beep_duration=floor(0.005*sr);
beep_frequency=1000;
dur=floor([0.4 .475 .5 .525 .60]*sr) - beep_duration; %signal duration
n_sig=length(dur);

%% Generate signals
figure
t_beep=[0:beep_duration-1]/44100;
%beep=sin(2*pi*beep_frequency*t_beep); % Beep
beep=2*rand(1,beep_duration)-1; % Noise burst
for n = 1:n_sig
    silence=zeros(1,dur(n));
    sig=[beep silence beep];


    subplot(n_sig,1,n)
    plot([0:length(sig)-1]/sr,sig)
    axis([0 0.8 -1 1])
    grid on
    
    audiowrite(['Sound_' num2str(round((dur(n)+beep_duration)/sr*1000)) '.wav'],0.9*sig,sr)
    movefile(['Sound_' num2str(round((dur(n)+beep_duration)/sr*1000)) '.wav'],'D:\Thèse\PROJECTS\MMN\SCRIPTS\SOUNDS')
end

