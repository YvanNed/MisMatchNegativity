function MMN_Duration_Lab_01
% needs make_swTone, ramp_sound in same folder
% =========================================================================
% basic MMN with at least 2 or 3 stds (o) in between dev (x)
% o o o  o o x  o o x  o o o  o o o  o o x
% std duration o  = 500 ms
% dev duration x  = 400 440 480 520 560 600 ms (X)
%
% PASSIVE LISTENING
% RUN the experiment 1 times to get ~100 stimuli fro each dev
% =========================================================================
% Triggers which ports?
% =========================================================================
% Virginie van Wassenhove 2019
% =========================================================================
% April, 3, 2019: debugging (G. Lemaitre et al.)%
% April, 8, 2019: add the correct random ITI (need to be confirm by PI) (Y. Nedelec)
% blablabla what should I do next ?

clear all; 
clc;
AddPsychJavaPath;

global w 
global FIX_HEIGHT 
global FIX_WIDTH 
global FIX_COLOR 
%global fRate 
global ESC_KEY
global USE_EEG 

ESC_KEY  ='ESCAPE';             % key value returned by KbName|exit

%fRate    = FrameRate([0]);      % important to control the timing

KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');

USE_EEG = false;
 
try 
    disp('InitializePsychSound')
    InitializePsychSound
    GetSecs;    % pre-load GetSecs if you want to use it later on your code
    pahandle = PsychPortAudio('Open', [], [], 0, [], 1);
    
    AssertOpenGL;
    starttime   = clock;
    rand('state',sum(100*clock));      % rand('seed',sum(100*clock))
    Screen('Preference', 'SkipSyncTests', 1); % should not be used if we want to be precise
    
    result_path = 'D:\Thèse\PROJECTS\MMN\RESULTS\';

    %--------------------------------------------------------------------------
    %----------------------- PC PORT INITIALIZATION for EEG?-------------------
    %--------------------------------------------------------------------------
    %% PC stim port def
    % NEED TO BE FILLED WITH WILLIAM
    
%% Initialisation
    % In the lab, we want at least 100 dev per duration (this number will be optimized for the train travel on another script)
    % And we want at least 2 std between a dev ( o o x )
    % we have 4 dev so 400 dev in total. it means we need at least 400 sequences o o x
    % we want 5% of dev compared to std so we will do loop putting 2 std and
    % then take randomly either a std or a dev.
    
    %---------------------------- Parameters ------------------------------
    %----------------------------------------------------------------------
    % std duration (o) = 500 ms                 80%
    std_dur = 500;
    % dev duration (x) = 400 475 525 600 ms     5% each (with at least 100stim)
    dev_dur = [400 475 525 600];
    % ISI              = [800-1200] ms
    ISI = [800 1200];
    % standard number  = 1600 (80%)
    nStd = 266; % calculate by hands, 2000/3 = 666 ; we have 400 dev ; so we still need 266 std 
    % deviant number   = 400  (5% each) (100 each)
    nDev = 100;
    % stimulus number  = 2000 (100%)
    nTOT = 2000;
    %----------------------------------------------------------------------

    %-------------------- Compute Experimental Matrix ---------------------
    %----------------------------------------------------------------------
    rep = 0;
    while rep == 0
        
        % compute the experimentale matrix that will contain: stim_nb; stim_dur; ISI; trigger
        expMat       = -99*ones(nTOT,4);
        expMat(:,1)  = randperm(length(expMat));
        expMat       = sortrows(expMat);

        % First, we need to create this random order of dev and std.
        n_std  = std_dur*ones(nStd,2);                       % create a vector of 266 stim containing 500 for the duration of std
        n_dev1 = dev_dur(1,1)*ones(nDev,2);                  % create a vector of 100 stim containing 400 for the duration of dev1
        n_dev2 = dev_dur(1,2)*ones(nDev,2);
        n_dev3 = dev_dur(1,3)*ones(nDev,2);
        n_dev4 = dev_dur(1,4)*ones(nDev,2);

        rand_stim = [n_std; n_dev1; n_dev2; n_dev3; n_dev4]; % concatenate all the simulus that will be randomly drawn

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

        % just to check if we have all the stim and add trigger: 
        % o 1 = dev1;
        % o 2 = dev2;
        % o 3 = dev3;
        % o 4 = dev4;
        % o 5 = std;
        
        countDev1 = 0;
        countDev2 = 0;
        countDev3 = 0;
        countDev4 = 0;
        countStd = 0;
        for i = 1:length(expMat)
            
            if expMat(i,2) == dev_dur(1)
                countDev1 = countDev1 +1;
                expMat(i,4) = 1;
                
            elseif expMat(i,2) == dev_dur(2)
                countDev2 = countDev2 +1;
                expMat(i,4) = 2;  
                
            elseif expMat(i,2) == dev_dur(3)
                countDev3 = countDev3 +1;
                expMat(i,4) = 3;
                
            elseif expMat(i,2) == dev_dur(4)
                countDev4 = countDev4 +1;
                expMat(i,4) = 4;
                
            elseif expMat(i,2) == std_dur
                countStd = countStd +1;
                expMat(i,4) = 5;
            end
        end

        % add ISI in the 3rd column in ms
        nTOT = length(expMat);
        expMat(:,3) = ((ISI(2)-ISI(1))*rand(1,nTOT) + ISI(1))'; % randomise une difference entre 800 et 1200 et l'ajoute a 800 (plus petit ISI) pour avoir des ISI entre 800 et 1200  

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
    
    %--------------------------------------------------------------------------
    %--------------------- PROMPT USER FOR DATA FILE NAME ---------------------
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
    %-------------------- END PROMPT USER FOR DATA FILE NAME ------------------
    %--------------------------------------------------------------------------
    %-------------------- INITIALIZE DISPLAY ---------------------------------- 
    HideCursor;
    screenHeight = 30;                      % Vertical screen size (cm)
    screenWidth  = 41;

    screens = Screen('Screens');
    screenNumber = max(screens);

    % Get the white and black indexes of the loaded gamma lookup table
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    gray  = (white+black)/2;

    % screenRect returns rectangular coordinates of the screen size in pixels
    [w,screenRect]= Screen('OpenWindow',screenNumber,0,[],32,2);
    displayWidth  = screenRect(3) - screenRect(1);
    displayHeight = screenRect(4) - screenRect(2);
    
    % Calculate fixation points and set GLOBAL variables
    FIX_HEIGHT = displayHeight/2;
    FIX_WIDTH  = displayWidth/2;
    FIX_COLOR  = white;
    
    ifi = Screen('GetFlipInterval',w);

    %-------------------- INITIALIZE DISPLAY ----------------------------------
    %--------------------------------------------------------------------------
    %--------------------- Display initial screen text ------------------------
    instructions       = 'Appuyez sur un bouton pour commencer';
    instructions_end   = 'Fin du bloc. Merci! ';
    Screen('TextSize', w, 20);
    Screen('TextFont', w, 'Arial Black'); 
    Screen('FillRect', w, black );
    Screen('DrawText', w, instructions, displayWidth/2 - 120 , displayHeight/1.5, FIX_COLOR);
    Screen('TextFont', w, 'Geneva'); 
    drawFixation(FIX_COLOR);
    Screen('Flip', w);
    KbWait;
    %---------------------end display initial screen text ---------------------
    %--------------------------------------------------------------------------
    %------------------------	START LOOP	-----------------------------------
    %--------------------------------------------------------------------------

    % ----- variable intialization ------
    save(dataFile, 'expMat');

    Screen('FillRect',w, black);
    drawFixation(FIX_COLOR);
    Screen('Flip', w);
    % -----------------------------------

    priorityLevel=MaxPriority(w);
    Priority(priorityLevel);
    tmp=zeros(1,10000);
    PsychPortAudio('FillBuffer', pahandle,tmp);
    t0 = PsychPortAudio('Start', pahandle,[],0,1);
    WaitSecs(0.5); % Hack to initialize PsychSound
    
    if USE_EEG
        address = IOPort('OpenSerialPort','COM4'); % le port depend de l'ordi
        IOPort('Write', address, uint8(226),0); % le trigger 226 signe le debut de la tâche
        WaitSecs(0.5);
    end
    
    % ------- NEED TO BE CHANGE --------
    nT=10; % it was just to test 
    
    %    Screen('DrawText', w, num2str(trial), displayWidth/2 - 120 , displayHeight/1.5, FIX_COLOR);
    Screen('TextFont', w, 'Geneva'); 
    drawFixation(FIX_COLOR);
    Screen('Flip', w);

    Timer = -99*ones(9,nT+1);
    
    % ------- START RUNS LOOP -------
    t_start = GetSecs;
    % mettre un trigger sur le t_start
    tic;
    for n = 1 : nT
        trial = n;
        
        Timer(1,trial) = toc;
        
        %file=['C:\Users\Recherche\Stage_Blandine_Yvan_2019\Sounds/Sound_' num2str(expMat(trial,3)) '.wav'];
        file=['D:\Thèse\PROJECTS\MMN\SCRIPTS\SOUNDS/Sound_' num2str(expMat(trial,2)) '.wav'];
        wavedata=audioread(file);
        
        Timer(2,trial) = toc;
        
        PsychPortAudio('FillBuffer', pahandle, wavedata');
        
        Timer(3,trial) = toc;
        
        % TRIAL display
        % HERE : PLAY SOUNDS
        disp([' Trial #' num2str(trial) '/' num2str(nT)]);
        disp(['play stimulus: ' file]);

        t_sound_start = PsychPortAudio('Start', pahandle,[],0,1);
        
        if USE_EEG
            [nwritten, t_trigger]=IOPort('Write', address, uint8(expMat(n,4)),0);
        end
        
        Timer(8, trial) = t_trigger - t_sound_start;
        
        Timer(4,trial) = toc;

        lag = GetSecs - t_sound_start;
        
        Timer(7, trial) = lag;
        
        % waiting for the sound to end, corrected with the lag created by
        % the start of the sound
        Soundwait = round((((expMat(trial,2)/1000))-lag)/ifi); % Wait for sound to finish
        
        for i=1 : Soundwait
            Screen('TextFont', w, 'Geneva'); 
            drawFixation(FIX_COLOR);
            Screen('Flip', w);
        end
        
        Timer(5,trial) = toc;
        
        % Compute the waiting time for the ISI in frames
        ISIwait = round((expMat(trial,3)/1000)/ifi); % Wait for the ISI
        % Compute a fix ISI of 50ms to trigger exaclty when the ISI start
        fixISIwaitfortrigger = round((50/1000)/ifi); % wit of 50ms turn into seconds (/1000) and turn into frames (/ifi)
        
        for i=1 : fixISIwaitfortrigger
            if i == 1
                Screen('TextFont', w, 'Geneva'); 
                drawFixation(FIX_COLOR);
                t_ISI_start = Screen('Flip', w);
                if USE_EEG
                    [nwrittenISI, t_triggerISI]=IOPort('Write', address, uint8(50),0); % le trigger 50 correspond aux ISI (mais les ISI sont random ?)
                end
                Timer(9,trial) = t_triggerISI -t_ISI_start;
            else
                Screen('TextFont', w, 'Geneva'); 
                drawFixation(FIX_COLOR);
                Screen('Flip', w);
            end
        end
        
        for i=1 : ISIwait
            Screen('TextFont', w, 'Geneva'); 
            drawFixation(FIX_COLOR);
            Screen('Flip', w);
        end
        
        Timer(6,trial) = toc;
        
        [KeyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        KeyNum = find(keyCode);
        if keyCode(escapeKey)
            error('Esc key was pressed');       % ESCAPE program
            break;
        end
    end
    
    t_end = GetSecs;
    % mettre un trigger sur le t_end

    Screen('TextSize', w, 20);
    Screen('TextFont', w, 'Arial Black'); 
    Screen('FillRect', w, black );
    Screen('DrawText', w, instructions_end,...
        displayWidth/2 - 120 , displayHeight/1.5, white);
    Screen('TextFont', w, 'Geneva'); 
    Screen('Flip', w);
    KbWait;
    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------

    %% save %%
    save(dataFile, 'expMat');
    tmptimer = [initials,blocknum];
    timerFile = [result_path tmptimer];
    save([timerFile 'Timer'],'Timer');
    ShowCursor;
    sca
    PsychPortAudio('Stop',pahandle);
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

%--------------------------------------------------------------------------
%------- SUB FUNCTIONS   --------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function drawFixation( color )
% draws a fixation point to the Screen background buffer
% color - the gamma lookup table color index
    global w
    global FIX_HEIGHT
    global FIX_WIDTH
    Offset_x = 8;  
    Offset_y = 11;  
    % number of Pixels that the the center of the cross is offset from the center of the screen
    % this is font size and type dependent
    Screen('DrawText', w, '+', ...
                FIX_WIDTH-Offset_x, FIX_HEIGHT-Offset_y, color);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function displayFixation( color )
% draws a fixation point and refreshes the Screen
% color - the gamma lookup table color index
global w
drawFixation( color );
Screen('Flip', w);
%--------------------------------------------------------------------------
