function fExpMain(design,stimuli,practice)
% Main experiment function for all Rand Reg experiments. This
% function generates audio on each trial, records responses (if applicable) 
% and analyses any behavioural data (minimally). 
% If necesasry it sends triggers for the EEG
%
%__________________________________________________________________________
% FORMAT fExpMain(design, stimuli, practice)
%
% -- design : structure containing details about the experimental
%                    design, see parameters in Start_EEG_Experiment
% -- stimuli : actual frequency sequecnes to use
% -- practice : 0 for practice session, 1 for actual recording session -
%               determines whether triggers are sent / psychtoolbox screen
%               initialised
%__________________________________________________________________________
% Rosy Southwell 2017/02

clc;
commandwindow; % switch cursor to command window if not already done

%% Preparing a little Matlab matrix with the image of fixation crosses:
FixCr           = ones(20,20)*0;
FixCr(10:11,:)  = 255;
FixCr(:,10:11)  = 255;  %try imagesc(FixCr) to display the result in Matlab

%% Start PTB
%  when working with the PTB it is a good idea to enclose the whole body of
%  your program in a try ... catch ... end construct. This will often prevent
%  you from getting stuck in the PTB full screen mode
try
    
    % Perform PTB and Eyetracker initialisation (see inside for details)
    [pahandle, expWin, rect]=fInitialisePTB(design);
    
    % Get the midpoint (mx, my) of this window, x and y
    [mx, my] = RectCenter(rect);
    
    % This is our intro text. 
    if strcmp(design.typeExp,'RandReg_Omission') && design.passive == 0
    myText = ['In this experiment you are asked to detect occasional\n' ...
        'GAPS occurring during a rapid sequence of tones\n\n' ...
        '>>> Press <SPACEBAR> as fast as possible if you hear a gap \n' ...
        '>>> Do NOT press any button if there is no gap \n\n' ...
        'You will receive feedback throughout the experiment.\n' ...
        '(Press any key to continue)\n' ];
    elseif strcmp(design.typeExp,'RandReg_Deviant') && design.passive == 0
     myText = ['In this experiment you are asked to detect occasional\n' ...
        'DEVIANT TONES occurring during a rapid sequence of tones\n\n' ...
        '>>> Press  <SPACEBAR> as fast as possible if you hear a deviant \n' ...
        '>>> Do NOT press any button if there is no deviant \n\n' ...
        'You will receive feedback throughout the experiment.\n' ...
        '(Press any key to continue)\n' ];
    else
        myText = 'Are you ready for the experiment?\n';
    end
    % Draw 'myText', centered in the display window:
    DrawFormattedText(expWin, myText, mx/2, 'center', 255, 0, [], [], 1.1);
    
    % Show the drawn text at next display refresh cycle:
    Screen('Flip', expWin);
    
    % Wait for key stroke. This will first make sure all keys are
    %released, then wait for a keypress and release:
    KbQueueWait;
    
   
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Start experiment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    
    trial.done      = 0; % flag=1 when experiment finished
    
    for b = design.whichBlock:(design.whichBlock+design.nBlocksRun-1)
        trial.currBlock = b;
        
        % Filename and path
        if practice == 0 % if not practice block
            outfile = sprintf('log_sub%s_block%d', design.subnum, ...
                trial.currBlock);
        elseif practice == 1
            outfile = sprintf('log_sub%s_training', design.subnum);
        end
        outpath = design.resultsDir;
        
        % First, randomise MATLAB's random number generator
        % rand('seed',sum(100*clock)); % for older versions of MATLAB
        % rng('shuffle');   % completely random
        % rng('default')
        rng(now+trial.currBlock);   
        
        % Generate stimulus presentation order (should be randomised)
        condIDs=[];     stimIDs=[];
        for c= 1:numel(design.conds) %for all main conditions
            % Each condition is assigned a unique integer i between 1 and Nconds.
            % this corresponds to the order they are specified in Start_experiment
            % The reason why we want to balance stimulus numbers within each block
            % is because it makes it possible to compute d primes per block, and
            % also makes it easier to resume the experiment
            condIDs=[condIDs c*ones(1,design.nEachCond(c)/design.nBlocks)]; %condition IDs
            stimIDs =[stimIDs ...
                stimuli(c).order((trial.currBlock-1)*design.nEachCond(c)/design.nBlocks+1 : ...
                trial.currBlock*design.nEachCond(c)/design.nBlocks)]; % stim IDs
            
        end
        
        shufOrder = randperm(design.stimPerBlock+design.ctrlPerBlock); % uses same random order to reshuffle condition IDs and stimulus IDs
        design.condShuf{b} = condIDs(shufOrder);
        design.stimShuf{b} = stimIDs(shufOrder);
        
        
        design.nStimTot    = numel(condIDs)*design.nBlocks;
        if ~design.passive
        design.rKey        = KbName('Space'); %response key is Space bar;
        end
        %% Set up a 'results' structure. This contains subjects results and stats
        results.condi       = NaN*ones(1,design.stimPerBlock+design.ctrlPerBlock);   	%to  be filled in after each trial
                results.freqlist    = [];                       	%list of freqs used
if ~design.passive
                results.response    = NaN*ones(1,design.stimPerBlock+design.ctrlPerBlock);      %to  be filled in after each trial
        results.keypress    = NaN*ones(1,design.stimPerBlock+design.ctrlPerBlock);   	%stores all keypresses
        results.RTs         = NaN*ones(1,design.stimPerBlock+design.ctrlPerBlock);   	%reaction times
        results.correct     = NaN*ones(1,design.stimPerBlock+design.ctrlPerBlock);
end   
        %% Set up a 'trial' structure. This contains all info pertaining to current trial
        trial.keypress  = [];
    
    if ~design.passive
    % Only record f8 and space, and enter keys
    keycodes=zeros(1,256);
    keycodes(KbName({'f8', 'space', 'Return'}))=1;
    KbQueueCreate([], keycodes); % Restrict to certain keys
    KbQueueStart(); % Start recording keypresses
    end
    

        
         % Draw fixation cross and wait for keypress
    fixcross=Screen('MakeTexture',expWin,FixCr);
    DrawFormattedText(expWin, [ ...
        'Press <SPACEBAR> to start next block'], 'center', 'center', 255, 0, [], [], 1.1);
    Screen('Flip', expWin);
    KbQueueWait;
            WaitSecs(1); 
        for i=1:(design.stimPerBlock+design.ctrlPerBlock)
                    %% start trial
trial.trialNum  = i;
            Screen('Flip', expWin);
            KbQueueFlush; %Empty keyboard queue before each trial
            
            Screen('DrawTexture', expWin, fixcross,[],[mx-10,my-10,mx+10,my+10]);
            Screen('Flip', expWin);
            
            % Gets the next trial; some of the trial parameters are stored in a
            % 'trial' struct
            [trial,results] = fnewTrial(results,design,trial,stimuli);
            trial.stim = [trial.stim; trial.stim]; % make it stereo
            
            % If recording EEG, add a trigger channel to the stimulus matrix
            if design.EEG
                trial = fTrigger(trial,design);
            end
            
            % Fill the audio playback buffer with the audio data 'wavedata':
            PsychPortAudio('FillBuffer', pahandle, trial.stim);
            
            if ~design.passive
            % Only record f8 and space, and enter keys
            keycodes=zeros(1,256);
            keycodes(KbName({'f8', 'space', 'Return'}))=1;
            KbQueueCreate([], keycodes); %restrict to certain keys
            KbQueueStart; %start recording keypresses
            end 
            
            % Start trial
            trial.t0 = GetSecs(); %get time at beginning of trial
            
            % Start audio playback, return onset timestamp.
            PsychPortAudio('Start', pahandle, 1, 0, 1);
            
            % Wait until end of stimulus
            WaitSecs('UntilTime', trial.t0+size(trial.stim,2)/design.fs + design.endWait/1000);
            
            if ~design.passive
            %% Record response time
            %  the Psychtoolbox method of using 'StimulusOnsetTime' seems to be
            %  the more reliable solution, specifically on varying hardware
            %  setups or under suboptimal conditions
            [trial.keypress.n, ~, ~, trial.keypress.t, ~] = KbQueueCheck();
            
            % If escape key (F8) ---> ABORT
            if trial.keypress.t(KbName('f8')) > 0
                trial.done=1;
                break;
            end
            
            % Restrict KbQueueCheck results to keys of interest (f8/space)
            trial.keypress.key = find(trial.keypress.t); %translate code into string
            trial.keypress.t = trial.keypress.t(trial.keypress.key); %find RT of target button
            trial.keypress.n = numel(trial.keypress.t);
            
            %% Analyse keypress, evaluate response
            [trial,results] = fAnalyseKey(trial,results,design);
            
            trial.keypress = []; % Erase keypress
            Screen('Flip', expWin,0); % Flip screen
            
            % Draw feedback on screen
            switch trial.correct
                case 'Yes' %Correct response, green check mark
                    imdata=imread('_imgood.png');
                    Screen('PutImage',expWin,imdata);
                case 'No' %Incorrect response, red cross
                    imdata=imread('_imbad.png');
                    Screen('PutImage',expWin,imdata);
                case 'WrongKey' % DRAW BLUE
                    DrawFormattedText(expWin, 'Wrong key pressed.', 'center', 'center', 255, 0, [], [], 1.1);
                case 'NoKey'  %No key was pressed, yellow fixation
                    DrawFormattedText(expWin, 'No key pressed.', 'center', 'center', 255, 0, [], [], 1.1);
            end
            end
            
            Screen('Flip', expWin);
            
            % ISI
            WaitSecs(design.ISI(randi(numel(design.ISI-design.endWait)))/1000); %wait ISI
            Screen('Flip', expWin,0); % RVS changed from 1
               
        end
        
        
        
        %% Save data to file at end of each block - allows you to quit program
        if exist([outpath outfile '.mat'],'file')~=0 && practice==0 % check if file exists, in which case append x to name
            outfile = [outfile 'x'];
        end
        if practice == 0
        save([outpath outfile],'results','design','stimuli');
        end 
        
        if ~design.passive
        hits =  sum(results.response==1);
        fpos =  sum(results.response==-1)+sum(results.response==-2);
        fneg = sum(results.response == 0);
        crej = sum(results.response == 2);
        tgt_tot = hits + fneg;
        ntgt_tot = fpos + crej;
        dp = dprime(hits,fpos,tgt_tot,ntgt_tot,0);
        
        myText = ['End of block ' num2str(trial.currBlock) '\n\n'...
            'Misses : ' num2str(fneg) '\n' ...
            'False Alarms : ' num2str(fpos) '\n\n' ...
            '---(d prime : ' num2str(dp) ')---\n' ...
            '(Press any key to continue)\n' ];
        else
             myText = ['End of block ' num2str(trial.currBlock) '\n\n'...
            '(Press any key to continue)\n' ];
        end
        DrawFormattedText(expWin, myText, 'center', 'center', 255, 0, [], [], 1.1);
        Screen('Flip',expWin,1);
        KbQueueWait();
        
      
        
        if trial.currBlock == design.nBlocks
            trial.done=1;
        end
    end
    
    if trial.done
                  myText = ['End of experiment \n\n' ...
                '(Press any key to continue)\n' ];
        
        DrawFormattedText(expWin, myText, 'center', 'center', 255, 0, [], [], 1.1);
        Screen('Flip',expWin,1);
        KbQueueWait();
    end
    fCleanup();
    
catch err
    % This section is executed only in case an error happens in the
    % experiment code implemented between try and catch...
    fCleanup();
    rethrow(err)
end

%% Finally put the main variable in the workspace (for debugging)
assignin('base', 'design', design);
assignin('base', 'results', results);
assignin('base', 'trial', trial);
clc
end
