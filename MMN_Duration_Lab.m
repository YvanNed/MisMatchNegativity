function MMN_Duration_Lab
% =========================================================================
% created by: YN. 27/11/2019
% last Update: YN. 12/12/2019
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
    InitializePsychSound(1) % here we could add InitializePsychSound([1]) to have the low latency settings
    GetSecs;    % pre-load GetSecs if you want to use it later on your code
    pahandle = PsychPortAudio('Open', [], [], 0, [], 1);
    % adjust volume
    PsychPortAudio('Verbosity',5);
    PsychPortAudio('Volume', pahandle, .2);
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

        % Fourth, check if we have all the stim and add trigger: 
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

        % Fifth, add ISI in the 3rd column in ms
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
    instructions_end   = 'Fin du bloc. Merci! ';
    
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
    
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!! NEED TO BE CHANGE !!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    nT=10; % it was just to debug, the nbr of trial aka sound is reduce to 10
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    Screen('TextFont', w, 'Geneva'); 
    drawFixation(FIX_COLOR);
    Screen('Flip', w);

    % to check the time for debug
    Timer = -99*ones(10,nT+1);
    
    % trigger at the beginning of the task 
    t_start = GetSecs;
    if USE_EEG
        [nwritten_start, t_trigger_start] = IOPort('Write', address, uint8(226),0); % le trigger 226 signe le debut de la tâche
        WaitSecs(0.5);
        Timer(10,1) = t_trigger_start - t_start;
    end

    % START LOOP
    tic;
    for n = 1 : nT
        trial = n;
        
        Timer(1,trial) = toc;
        
        % get the sound filename of the trial
        file=['D:\Thèse\PROJECTS\MMN\SCRIPTS\SOUNDS/Sound_' num2str(expMat(trial,2)) '.wav'];
        % audioread returns sampled data and the sample rate for that data
        wavedata=audioread(file);
        
        Timer(2,trial) = toc;
        
        PsychPortAudio('FillBuffer', pahandle, wavedata');
        
        Timer(3,trial) = toc;
        
        % TRIAL display
        disp([' Trial #' num2str(trial) '/' num2str(nT)]);
        disp(['play stimulus: ' file]);
        
        % returns the time when the sound hit the speakers
        t_sound_start = PsychPortAudio('Start', pahandle,[],0,1);
        
        % trigger after the sound start, the timing should be cheked
        if USE_EEG
            [nwritten, t_trigger]=IOPort('Write', address, uint8(expMat(n,4)),0);
            Timer(8, trial) = t_trigger - t_sound_start;
        end
        
        Timer(4,trial) = toc;

        lag = GetSecs - t_sound_start;
        
        Timer(7, trial) = lag;
        
        % waiting for the sound to end, corrected with the lag created by
        % the start of the sound
        Soundwait = round((((expMat(trial,2)/1000))-lag)/ifi); % Wait for sound to finish
        
        % loop on th nbr of frame to wait in order the sound is finished
        for i=1 : Soundwait
            Screen('TextFont', w, 'Geneva'); 
            drawFixation(FIX_COLOR);
            Screen('Flip', w);
        end
        
        Timer(5,trial) = toc;
        
        % Compute a fix ISI of 50ms to trigger exaclty when the ISI start
        fixISIwaitfortrigger = round((50/1000)/ifi); % wit of 50ms turn into seconds (/1000) and turn into frames (/ifi)
        % Compute the waiting time for the ISI in frames
        ISIwait = round((expMat(trial,3)/1000)/ifi); % Wait for the ISI
        
        for i=1 : fixISIwaitfortrigger
            if i == 1
                Screen('TextFont', w, 'Geneva'); 
                drawFixation(FIX_COLOR);
                t_ISI_start = Screen('Flip', w);
                if USE_EEG
                    [nwrittenISI, t_triggerISI]=IOPort('Write', address, uint8(50),0); % le trigger 50 correspond aux ISI (mais les ISI sont random ?)
                    Timer(9,trial) = t_triggerISI -t_ISI_start;
                end
            else
                Screen('TextFont', w, 'Geneva'); 
                drawFixation(FIX_COLOR);
                Screen('Flip', w);
            end
        end
        
        % loop on the number of frame to wait for the ISI
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
    if USE_EEG
        [nwrittenEND, t_triggerEND]=IOPort('Write', address, uint8(200),0); % le trigger 200 correspond a la fin de la tâche
        Timer(10,1) = t_triggerEND - t_end;
    end

    Screen('TextSize', w, 30);
    Screen('TextFont', w, 'Arial Black'); 
    Screen('FillRect', w, black );
    Screen('DrawText', w, instructions_end,displayWidth/2 - 350 , displayHeight/3, white);
    Screen('TextFont', w, 'Geneva'); 
    Screen('Flip', w);
    KbWait;
    %------------------------------ End MMN -------------------------------

    %------------------------- Save and close ptb -------------------------
    %----------------------------------------------------------------------
    save(dataFile, 'expMat');
    tmptimer = [initials,blocknum];
    timerFile = [result_path tmptimer];
    save([timerFile 'Timer'],'Timer');
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
