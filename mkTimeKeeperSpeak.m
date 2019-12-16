%% this script extract the infos of TimeKeeper, saved as subjnamesessionTimer.mat

clc
clear all;

result_path = [pwd '\'];

% ask the name of the file
dataFile   = 'tmp';
promptUser = true;

while promptUser

    prompt1=inputdlg('Subject ID','Output File',1,{'tmp'});
    if isempty(prompt1)
        disp(['Script annulé...']);
        return;
    else
        initials=prompt1{1};
    end

    prompt2=inputdlg('Block number','Output File',1,{'tmp'});
    if isempty(prompt2)
        disp(['Script annulé...']);
        return;
    else
        blocknum =prompt2{1};
    end

    if initials
        tmpFile = [initials,blocknum,'_mmn_dur.mat'];
        timerFile = [initials,blocknum, 'Timer.mat'];
        if  exist(tmpFile)
            dataFile = [result_path tmpFile];
            load(dataFile);
            load(timerFile);
            promptUser = false;
        else
            replace=questdlg(['Ce fichier n''existe pas.', tmpFile, '. Voulez-vous recommencer?']);
            if strcmp( replace, 'Yes' )
               promptUser = true;
            end
        end
    end
end

% did you used eeg ?
used_EEG = false;

% check for -99
B = TimeKeeper == -99;
C = sum(sum(B)); % nbr of element missing should be 3*20
disp(['il manque ' num2str(C) ' éléments.'])
if ~ used_EEG
    disp('3*20 éléments manquants étaient attendus')
else
    disp('c''est pas normal, t''as encore fait une erreur... toc hard')
end

%% check delay between trials
% initialization
trial_start_diff = -99*(length(TimeKeeper)-1);
sound1_start_diff = -99*(length(TimeKeeper)-1);
trial_stop_diff = -99*(length(TimeKeeper)-1);
sound2_start_diff = -99*(length(TimeKeeper)-1);
counter = 0;
i = 0;
% compute the diff between each trial to see if everything goes in the same timinng 
for i=2:length(TimeKeeper)
    counter = counter + 1;
    trial_start_diff(counter) = TimeKeeper(i,1) - TimeKeeper(i-1,1);
    sound1_start_diff(counter) = TimeKeeper(i,2) - TimeKeeper(i-1,2);
    sound2_start_diff(counter) = TimeKeeper(i,7) - TimeKeeper(i-1,7);
    trial_stop_diff(counter) = TimeKeeper(i,12) - TimeKeeper(i-1,12);
end

trial_start_min = min(trial_start_diff);
trial_start_max = max(trial_start_diff);
trial_start_max_diff = trial_start_max - trial_start_min;
disp(['Maximum delay betwteen trial starts: ' num2str(trial_start_max_diff)])
disp('Theoretical delay is 400ms (ISI range)')

figure
plot(trial_start_diff);
title('trial start diff')
xlabel('time in seconds')
ylabel('time of each trial')

sound1_start_min = min(sound1_start_diff);
sound1_start_max = max(sound1_start_diff);
sound1_start_max_diff = sound1_start_max - sound1_start_min;
disp(['Maximum delay betwteen sound_1 starts: ' num2str(sound1_start_max_diff) ' mean is ' num2str(mean(sound1_start_diff))])
disp('Theoretical delay is 400ms (ISI range)')

figure
plot(sound1_start_diff);
title('sound start diff')
xlabel('time in seconds')
ylabel('time of each trial')

sound2_start_min = min(sound2_start_diff);
sound2_start_max = max(sound2_start_diff);
sound2_start_max_diff = sound2_start_max - sound2_start_min;
disp(['Maximum delay betwteen sound_2 starts: ' num2str(sound2_start_max_diff) ' mean is ' num2str(mean(sound2_start_diff))])
disp('Theoretical delay is 400ms (ISI range)')

figure
plot(sound1_start_diff);
title('sound start diff')
xlabel('time in seconds')
ylabel('time of each trial')

trial_stop_min = min(trial_stop_diff);
trial_stop_max = max(trial_stop_diff);
trial_stop_max_diff = trial_stop_max - trial_stop_min;
disp(['Maximum delay betwteen trial stops: ' num2str(trial_stop_max_diff) ' mean is ' num2str(mean(trial_stop_diff))])
disp('Theoretical delay is 400ms (ISI range)')

figure
plot(trial_stop_diff);
title('trial stop diff')
xlabel('time in seconds')
ylabel('time of each trial')

%% check delay within trials
n = 0;
timing_within = -99*ones(length(TimeKeeper), 6);
timing_within(:,1) = expMat(:,2)/1000; % set the theoretical value of stim duration in sec
for n = 1:length(TimeKeeper)
    timing_within(n,2) = TimeKeeper(n,7) - TimeKeeper(n,2); % set the stim duration measured
    timing_within(n,3) = abs(timing_within(n,1)-timing_within(n,2));
    
    if used_EEG
        timing_within(n,4) = TimeKeeper(n,3)-TimeKeeper(n,2);
        timing_within(n,5) = TimeKeeper(n,8)-TimeKeeper(n,7);
        timing_within(n,6) = TimeKeeper(n,14)-TimeKeeper(n,12);
    end
end

figure
plot(timing_within(:,3));
title('diff between stim duration theoretical and measured')
xlabel('trial')
ylabel('stim diff (in sec)')

min_diff = min(timing_within(:,3));
max_diff = max(timing_within(:,3));
maximun_range_of_diff = max_diff - min_diff;
disp(['Range of diff between maximun_range_of_diff ' num2str(maximun_range_of_diff)])
disp(['Mean diff between maximun_range_of_diff: ' num2str(mean(timing_within(:,3)))])

%% check ISI timing
p = 0;
timing_ISI = -99*ones(length(TimeKeeper)-1,3);
timing_ISI(:,1) = expMat(:,1:length(expMat)-1); % to check if it worked correctly
for p = 2:length(TimeKeeper)
    timing_ISI(p-1,2) = TimeKeeper(p,1) - TimeKeeper(p-1,12);
    timing_ISI(p-1,3) = abs(timing_ISI(p-1,1) - timing_ISI(p-1,2)); 
end

figure
plot(timing_ISI(:,3));
title('diff between ISI duration theoretical and measured')
xlabel('trial')
ylabel('ISI diff (in sec)')

minISI_diff = min(timing_ISI(:,3));
maxISI_diff = max(timing_ISI(:,3));
maximun_ISIrange_of_diff = maxISI_diff - minISI_diff;
disp(['Range of diff between maximun_range_of_diff ' num2str(maximun_ISIrange_of_diff)])
disp(['Mean diff between maximun_range_of_diff: ' num2str(mean(timing_ISI(:,3)))])