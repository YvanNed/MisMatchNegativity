load('tmptmptimer.mat')

temps_stim_mesure = [];
for i=1:length(Timer2)
    temps_stim_mesure(i) = Timer2(5,i) - Timer2(1,i);
end

lag_entre_avt_son_et_apres_son = []; %
for i=1:length(Timer2)
    lag_entre_avt_son_et_apres_son(i) = Timer2(4,i) - Timer2(3,i);
end

temps_isi_mesure = [];
for i=1:length(Timer2)
    temps_isi_mesure(i) = Timer2(6,i)-Timer2(5,i);
end

temps_trial = [];
for i=1:length(Timer2)-1
    temps_trial(i) = Timer2(1,i+1) - Timer2(1,i);
end
    
temps_apres_stim = [];
for i=1:length(Timer2)
    temps_apres_stim(i) = Timer2(5,i) - Timer2(4,i);
end
