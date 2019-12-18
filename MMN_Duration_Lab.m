function MMN_Duration_Lab
% =========================================================================
% created by: YN. 27/11/2019
% last Update: YN. 16/12/2019
% =========================================================================
%% Description
% basic passive MMN duration with at least 2 standards (o) between a deviant (x)
% o o o o o x o o o o o x o o x ...
% =========================================================================
% The sounds need to be created before with the function GenerateSounds_Y 
% and then placed in a folder SOUNDS at the location "D:\Thèse\PROJECTS\MMN\SCRIPTS\SOUNDS"
% =========================================================================

clear all; 
clc;
AddPsychJavaPath;

global w
global screenRect
global pahandle
global FIX_HEIGHT 
global FIX_WIDTH 
global FIX_COLOR 
global ifi 
global ESC_KEY
global USE_EEG 

ESC_KEY  ='ESCAPE';             % key value returned by KbName|exit
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');

USE_EEG = false;
 
try 
    %----------------- Start the PsychToolBox sound driver ----------------
    %----------------------------------------------------------------------
    disp('InitializePsychSound')
    InitializePsychSound(1) % (1) to specify needlowlatency argument
    GetSecs;    % pre-load GetSecs if you want to use it later on your code
    pahandle = PsychPortAudio('Open', [], [], 0, [], 1);
    % adjust volume
    PsychPortAudio('Verbosity',5); 
    PsychPortAudio('Volume', pahandle, .6); % this migth need to be adjusted on your device
    s = PsychPortAudio('GetStatus', pahandle);
    %----------------------------------------------------------------------
    
    % Check if the correct Psychtoolbox is used
    AssertOpenGL;
    starttime = clock;
    
    %  ensure that MATLAB always gives different random numbers in separate
    %  runs. New correct writting should be: rng(sum(100*clock),'v4') the line below was written by VvW
    rand('state',sum(100*clock));      % rand('seed',sum(100*clock)) reiniti
    
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!! Will need to be removed !!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    Screen('Preference', 'SkipSyncTests', 1); % should not be used if we want to be precise
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    % Define the path of your results, where the expMat will be saved
    result_path = 'D:\Thèse\PROJECTS\MMN\SCRIPTS\RESULTS\';

    %----------------------- PC PORT INITIALIZATION for EEG----------------
    %----------------------------------------------------------------------
    if USE_EEG
        address = IOPort('OpenSerialPort','COM4'); % le port depend de l'ordi
    end
    %----------------------------------------------------------------------
    
%% Initialisation
    % In the lab, we want at least 100 dev per duration (this number will be optimized for the train travel on another script)
    % And we want at least 2 std between a dev ( o o x ) for 3000 stimulus.
    % we have 6 dev so 900 dev in total. it means we need at least 900 sequences o o x
    % we want 5% of dev compared to std so we will do loop putting 2 std and
    % then take randomly either a std or a dev.
    
    %---------------------------- Parameters ------------------------------
    %----------------------------------------------------------------------
    % std duration (o) = 500 ms                 80%
    std_dur = 500;
    % dev duration (x) = 400 475 525 600 ms     5% each (with at least 100stim)
    dev_dur = [425 450 475 525 550 575];
    % ISI              = [800-1200] ms
    ISI = [1000 1400];
    % standard number  = 2100 (70%)
    nStd = 100; % calculate by hands, 3000/3 = 1000 ; we have 900 dev ; so we still need 100 std to have 3000 stimulus 
    % deviant number   = 900  (5% each) (150 each)
    nDev = 150;
    % stimulus number  = 2000 (100%)
    nTOT = 3000;
    
    % sound parameters:
    tonefreq = 1000;
    tonedur = 0.005; % 5ms
    audiofreq = s.SampleRate; % or fixe it at 44100 or 48000
    %----------------------------------------------------------------------

    %-------------------- Compute Experimental Matrix ---------------------
    %----------------------------------------------------------------------
    rep = 0;
    while rep == 0
        
        % compute the experimentale matrix that will contain: stim_nb; stim_dur; ISI; trigger_sound1; trigger_sound2
        expMat       = -99*ones(nTOT,5);
        expMat(:,1)  = randperm(length(expMat));
        expMat       = sortrows(expMat);

        % First, we need to create this random order of dev and std.
        n_std  = std_dur*ones(nStd,2);                       % create a vector of 266 stim containing 500 for the duration of std
        n_dev1 = dev_dur(1,1)*ones(nDev,2);                  % create a vector of 100 stim containing 400 for the duration of dev1
        n_dev2 = dev_dur(1,2)*ones(nDev,2);
        n_dev3 = dev_dur(1,3)*ones(nDev,2);
        n_dev4 = dev_dur(1,4)*ones(nDev,2);
        n_dev5 = dev_dur(1,5)*ones(nDev,2);
        n_dev6 = dev_dur(1,6)*ones(nDev,2);

        rand_stim = [n_std; n_dev1; n_dev2; n_dev3; n_dev4; n_dev5; n_dev6]; % concatenate all the simulus that will be randomly drawn

        rand_stim(:,1) = randperm(length(rand_stim));        % create the random order
        rand_stim = sortrows(rand_stim);

        % Second, we need to create the loop that will add a random stim between two std
        idx = 1; 
        for i = 3:3:length(expMat)
            expMat(i,2) = rand_stim(idx,2);
            idx = idx+1;
        end

        % Third, fill up the matrix with the std
        count = 0;
        for i = 1:length(expMat)
            if expMat(i,2) == -99
                expMat(i,2) = 500;
            else
                count = count+1;
            end
        end

        % Fourth, check if we have all the stim and add trigger: 
        % o 10 & 11 = dev1 sound1 & sound2;
        % o 20 & 21 = dev2 sound1 & sound2;
        % o 30 & 31 = dev3 sound1 & sound2;
        % o 40 & 41 = dev4 sound1 & sound2;
        % o 50 & 51 = std  sound1 & sound2;
        
        countDev1 = 0;
        countDev2 = 0;
        countDev3 = 0;
        countDev4 = 0;
        countDev5 = 0;
        countDev6 = 0;
        countStd = 0;
        for i = 1:length(expMat)
            
            if expMat(i,2) == dev_dur(1)
                countDev1 = countDev1 +1;
                expMat(i,4) = 10;
                expMat(i,5) = 11;
                
            elseif expMat(i,2) == dev_dur(2)
                countDev2 = countDev2 +1;
                expMat(i,4) = 20;  
                expMat(i,5) = 21;
                
            elseif expMat(i,2) == dev_dur(3)
                countDev3 = countDev3 +1;
                expMat(i,4) = 30;
                expMat(i,5) = 31;
                
            elseif expMat(i,2) == dev_dur(4)
                countDev4 = countDev4 +1;
                expMat(i,4) = 40;
                expMat(i,5) = 41;
                
            elseif expMat(i,2) == dev_dur(5)
                countDev5 = countDev5 +1;
                expMat(i,4) = 50;
                expMat(i,5) = 51;
            
            elseif expMat(i,2) == dev_dur(6)
                countDev6 = countDev6 +1;
                expMat(i,4) = 60;
                expMat(i,5) = 61;
                
            elseif expMat(i,2) == std_dur
                countStd = countStd +1;
                expMat(i,4) = 70;
                expMat(i,5) = 71;
            end
        end

        % Fifth, add ISI in the 3rd column in ms
        nTOT = length(expMat);
        expMat(:,3) = round(((ISI(2)-ISI(1))*rand(1,nTOT) + ISI(1))'); % randomise une difference entre 800 et 1200 et l'ajoute a 800 (plus petit ISI) pour avoir des ISI entre 800 et 1200  

        % ask if the numbers of stim presentation are correct
        disp(['Std number  : ' num2str(countStd) ' (' num2str((countStd*100)/length(expMat)) '%)'])
        disp(['Dev1 number : ' num2str(countDev1) ' (' num2str((countDev1*100)/length(expMat)) '%)'])
        disp(['Dev2 number : ' num2str(countDev2) ' (' num2str((countDev2*100)/length(expMat)) '%)'])
        disp(['Dev3 number : ' num2str(countDev3) ' (' num2str((countDev3*100)/length(expMat)) '%)'])
        disp(['Dev4 number : ' num2str(countDev4) ' (' num2str((countDev4*100)/length(expMat)) '%)'])
        disp(['Total number of stimuli : ' num2str(countStd + countDev1 + countDev2 + countDev3 + countDev4)])

        ok = input('Are you cool with those numbers? (0/1)');
        if ok == 1
            rep = 1;
        else
            rep = 0;
        end
    end

    %------------------- END Compute Experimental Matrix ------------------
    
    %--------------------- PROMPT USER FOR DATA FILE NAME -----------------
    %----------------------------------------------------------------------
    dataFile   = 'tmp';
    promptUser = true;

    while promptUser

        prompt1=inputdlg('Subject ID','Output File',1,{'tmp'});
        if isempty(prompt1)
            disp(['Experience annulée...']);
            return;
        else
            initials=prompt1{1};
        end

        prompt2=inputdlg('Block number','Output File',1,{'tmp'});
        if isempty(prompt2)
            disp(['Experience annulé...']);
            return;
        else
            blocknum =prompt2{1};
        end

        if initials
            tmpFile = [initials,blocknum,'_mmn_dur.mat'];
            if ~ exist(tmpFile)
                dataFile = [result_path tmpFile];
                promptUser = false;
            else
                replace=questdlg(['Un fichier à ce nom existe déjà', tmpFile, '. Voulez-vous le remplacer?']);
                if strcmp( replace, 'Yes' )
                   dataFile = [result_path tmpFile];
                   promptUser = false;
                end
            end
        end
    end
    %------------------ END PROMPT USER FOR DATA FILE NAME ----------------

    %% MMN task
    %----------------------- Initialize Screen info -----------------------
    %----------------------------------------------------------------------
    HideCursor;
    
    % Get the number of screens, to choose the screen where you want to display the task
    screens = Screen('Screens');
    % Choose the external screen attached to the computer
    screenNumber = max(screens);

    % Get the white and black indexes of the loaded gamma lookup table
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);

    % screenRect returns rectangular coordinates of the screen size in pixels
    [w,screenRect]= Screen('OpenWindow',screenNumber,0,[],[],2); 
    
    % Get the size of the screen in pixels
    displayWidth  = screenRect(3) - screenRect(1);
    displayHeight = screenRect(4) - screenRect(2);
    
    % Get center of the screen for fixation cross and set global variables
    FIX_HEIGHT = displayHeight/2;
    FIX_WIDTH  = displayWidth/2;
    FIX_COLOR  = white;
    
    % inter-frame-interval:minimum possible time between drawing to the screen (should be 0.0167seconds)
    ifi = Screen('GetFlipInterval',w);
    %---------------------- END Initialize Screen info --------------------

    %------------------------ Display intial Screen -----------------------
    %----------------------------------------------------------------------
    instructions       = 'Appuyez sur la barre espace pour commencer';
    instructions_end   = 'Fin de la session. Merci! ';
    
    disp_instr = 0;
    while disp_instr == 0
        Screen('TextSize', w, 30);
        Screen('TextFont', w, 'Arial Black'); 
        Screen('FillRect', w, black );
        Screen('DrawText', w, instructions, displayWidth/2 - 350 , displayHeight/3, FIX_COLOR); % 350 depend de la taille de l'ecran 
        Screen('TextFont', w, 'Geneva'); 
        drawFixation(FIX_COLOR);
        Screen('Flip', w);
        
        [KeyIsDown,secs, keyCode, deltaSecs] = KbCheck;
        keyNum = find(keyCode);
        if keyNum == 32
            disp_instr = 1;
        elseif keyCode(escapeKey)
            error('Esc key was pressed');
            break
        end
    end
    %---------------------- END Display intial Screen----------------------
    
    %----------------------------- Start MMN ------------------------------
    %----------------------------------------------------------------------
    % save expMat
    save(dataFile, 'expMat');
    
    % initialization
    Screen('FillRect',w, black);
    drawFixation(FIX_COLOR);
    Screen('Flip', w);
    
    % set prioritylevel at maximum for minimum delay
    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    
    % initialize PsychSound
    tmp=zeros(1,10000);
    PsychPortAudio('FillBuffer', pahandle,tmp);
    t0 = PsychPortAudio('Start', pahandle,[],0,1);
    WaitSecs(0.5); % Hack to initialize PsychSound
    % make the tone
    tone = [];
    tone = MakeBeep(tonefreq, tonedur, audiofreq);
    
    nT = length(expMat);
    
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!! NEED TO BE REMOVED !!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    nT=20; % it was just to debug, the nbr of trial aka sound is reduce to 10
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    % insert the initialization of the timer_count here (or above at the begining of the task
    TimeKeeper = -99*ones(nT,14);
    
    Screen('TextFont', w, 'Geneva'); 
    drawFixation(FIX_COLOR);
    t_start = Screen('Flip', w);
    
    % trigger pour le debut de la tâche
    if USE_EEG
        [nwritten_start, t_trigger_start] = IOPort('Write', address, uint8(226),0); % le trigger 226 signe le debut de la tâche
        WaitSecs(0.5);
    end

    PsychPortAudio('FillBuffer', pahandle, tone);
    % START LOOP
    tic;
    for n = 1 : nT
        trial = n;
        current_dur = expMat(trial,2)/1000; % duration is converted in second
        current_trigger_sound1 = expMat(trial,4);
        current_trigger_sound2 = expMat(trial,5);

        %PsychPortAudio('FillBuffer', pahandle, tone);
        
        % TRIAL display
        disp([' Trial #' num2str(trial) '/' num2str(nT)]);
        disp(['play stimulus: ' current_dur]);
        
        if trial == 1
             t_trial_start_planned = GetSecs + 4;
             Screen('TextFont', w, 'Geneva'); 
             drawFixation(FIX_COLOR);
             trial_start = Screen('Flip',w,t_trial_start_planned);
        else
            current_isi = (expMat(trial-1,3) + 5)/1000; % ISI is converted in second. + 5 is for the duration of sound2
            % now the ISI is played at the beginning of the trial so the ISI 1 is played on the trial 2 ,ISI 2 in trial 3 etc.. 
            %the last ISI will not be played
             % I'm not sure that the trigger will corespond to the begining of the ISI
             if USE_EEG
                    [nwrittenISI, t_triggerISI]=IOPort('Write', address, uint8(100),0); % le trigger 100 correspond aux ISI (mais les ISI sont random ?)
                    TimeKeeper(trial-1,14) = t_triggerISI;
             end
             Screen('TextFont', w, 'Geneva'); 
             drawFixation(FIX_COLOR);
             trial_start = Screen('Flip',w,trial_stop + current_isi); % add + current_isi);
        end
        TimeKeeper(trial,1) = trial_start;
        
        % returns the time when the sound hit the speakers
        if trial == 1
            t_sound1_start = PsychPortAudio('Start', pahandle,[],trial_start,1); % should be trial_start
        else
            t_sound1_start = PsychPortAudio('Start', pahandle,[],t_sound2_start + current_isi,1); % should be trial_start
        end
        TimeKeeper(trial,2) = t_sound1_start;
        % trigger after the sound start, the timing should be cheked
        if USE_EEG
            [nwritten1, t_trigger1]=IOPort('Write', address, uint8(current_trigger_sound1),0);
            TimeKeeper(trial,3) = t_trigger1;
        end
        
        [startTime_s1 endPositionSecs_s1 xruns estStopTime_s1] = PsychPortAudio('Stop', pahandle, 1);
        % endPositionsSecs should be the last moment the device is used and estStopTime is an estimate of when the playback is stopped
        TimeKeeper(trial,4) = startTime_s1;
        TimeKeeper(trial,5) = endPositionSecs_s1;
        TimeKeeper(trial,6) = estStopTime_s1;
        
        PsychPortAudio('FillBuffer', pahandle, tone);
        
        t_sound2_start = PsychPortAudio('Start', pahandle,[],t_sound1_start + current_dur,1);
        TimeKeeper(trial,7) = t_sound2_start;
        
        % trigger after the sound start, the timing should be cheked
        if USE_EEG
            [nwritten2, t_trigger2]=IOPort('Write', address, uint8(current_trigger_sound2),0);
            TimeKeeper(trial,8) = t_trigger2;
        end
        
        [startTime_s2 endPositionSecs_s2 xruns estStopTime_s2] = PsychPortAudio('Stop', pahandle, 1);
        TimeKeeper(trial,9) = startTime_s2;
        TimeKeeper(trial,10) = endPositionSecs_s2;
        TimeKeeper(trial,11) = estStopTime_s2;
        
        Screen('TextFont', w, 'Geneva'); 
        drawFixation(FIX_COLOR);
        trial_stop = Screen('Flip', w, t_sound2_start + tonedur); % the trial stops at the start of the second sound + the duration of the secoond sound!
        TimeKeeper(trial,12) = trial_stop;
        
        if USE_EEG
            [nwritten, t_trigger_trialstop]=IOPort('Write', address, uint8(150),0); % le trigger 150 correspond à la fin du trial
            TimeKeeper(trial,13) = t_trigger_trialstop;
        end
        
        [KeyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        KeyNum = find(keyCode);
        if keyCode(escapeKey)
            error('Esc key was pressed');       % ESCAPE program
            break;
        end
    end
    
    if USE_EEG
        [nwrittenEND, t_triggerEND]=IOPort('Write', address, uint8(200),0); % le trigger 200 correspond a la fin de la tâche
    end

    Screen('TextSize', w, 30);
    Screen('TextFont', w, 'Arial Black'); 
    Screen('FillRect', w, black );
    Screen('DrawText', w, instructions_end,displayWidth/2 - 150 , FIX_HEIGHT, white);
    Screen('TextFont', w, 'Geneva'); 
    t_end = Screen('Flip', w);
    KbWait;
    %------------------------------ End MMN -------------------------------

    %------------------------- Save and close ptb -------------------------
    %----------------------------------------------------------------------
    save(dataFile, 'expMat');
    tmptimer = [initials,blocknum];
    timerFile = [result_path tmptimer];
    save([timerFile 'Timer'],'TimeKeeper','t_start','t_end');
    ShowCursor;
    sca
    PsychPortAudio('Stop',pahandle);
    %----------------------------------------------------------------------
    
catch
    % "catch" executes in case of an error in the "try" 
    % closes the onscreen w if open.
    ShowCursor;
    Screen('CloseAll');
    endtime=clock;
    disp(['CRITICAL ERROR: ' lasterr ])
    disp(['Exiting program ...'])
    rethrow(lasterror);
    PsychPortAudio('Stop',pahandle);
end %try..catch..

%==========================================================================
%------------------------------ SUB FUNCTIONS -----------------------------
%==========================================================================

%--------------------------------------------------------------------------
function drawFixation( color )
    % draws a fixation point to the Screen background buffer
    % color - the gamma lookup table color index
    global w
    global FIX_HEIGHT
    global FIX_WIDTH
    
    % length and width og the cross
    cross_length = 30;  
    penWidth = 5;
    
     % Color of the cross
    if ischar(color)
        if strcmp(color, 'white')
            color_rgb = [255 255 255];
        elseif strcmp(color, 'black')
            color_rgb = [0 0 0];
        else
            disp('This color is not yet programmed. The cross will be white')
            color_rgb = [255 255 255];
        end
    elseif isreal(color)
        color=num2str(color);
        if strcmp(color, '255')
            color_rgb = [255 255 255];
        elseif strcmp(color, '0')
            color_rgb = [0 0 0];
        else
            disp('This color is not yet programmed. The cross will be white')
            color_rgb = [255 255 255];
        end
    end
    
    bar_H_HdimStart = FIX_WIDTH - cross_length;
    bar_H_HdimEnd = FIX_WIDTH + cross_length;
    bar_H_VPosition = FIX_HEIGHT;
    Screen('DrawLine', w, color_rgb, bar_H_HdimStart, bar_H_VPosition, bar_H_HdimEnd, bar_H_VPosition, penWidth);

    % Vertical bar of the cross
    bar_V_HPosition = FIX_WIDTH;
    bar_V_VdimStart = FIX_HEIGHT - cross_length ;
    bar_V_VdimEnd = FIX_HEIGHT + cross_length;
    Screen('DrawLine', w, color_rgb, bar_V_HPosition, bar_V_VdimStart, bar_V_HPosition, bar_V_VdimEnd, penWidth);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function displayFixation( color )
    % draws a fixation point and refreshes the Screen
    % color - the gamma lookup table color index
    global w
    drawFixation( color );
    Screen('Flip', w);
