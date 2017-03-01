% Behavioural detection experiment - detect omissions 
% tone sequence stimuli which are rand or reg but include an OMSISION.
%
% 1. generate a structure 'design' containing experiment parameters
% 2. get subject details
% 3. design stimuli
% 4. start experiment
%______________________________Rosy Southwell, last updated Feb 27th 2017

clearvars;
close all;

result_dir='Results/';
if ~exist(result_dir,'dir')
    mkdir(result_dir)
end
%% Parameters
design.typeExp          = 'RandReg_Omission';   % Choose experiment

Screen('Preference', 'SkipSyncTests', 0); % if problems with psychtoolbox screen sync, set to 1

design.nBlocks          = 6; % number of blocks total - needed for generating conditions
design.nBlocksRun       = 6; % number of blocks to run - e.g. set to 1 and re-start matlab before each block

design.stimPerBlock     = 64;
design.ctrlPerBlock     = 8;
design.nEachCond        = [96 96 96 96 24 24];  % repeats throughout experiment, must divide by n blocks
    
design.conds            = {'REG10', 'RAND10', 'REG10_gap1','RAND10_gap1','CTRL','CTRL_gap1'};   % condition labels
design.condsDeviant     = [0 0 1 1 0 1 ];    % which condition(s) require a button press i.e. contains a deviant
design.omissionDur      = [0 0 1 1 0 1 ]; % numebr of tones to omit for each condition
design.condsSize        = [10 10 10 10 1 1];    % how many tones in pool for the respective conditions
design.condsRand        = [0 1 0 1 0 0];    % which conditions are RAND sequences
design.condi            = [1 2 3 4 5 6 ]; % assign each condition with  unique number to use throughout
design.condsCTRL        = [0 0 0 0 1 1];

design.fs               = 44100;      	% sampling freq hz
design.toneDur          = 50;          	% pip duration
design.seqLength        = 60;           % number of pips in sequence
design.freqPool         = [198;222;250;280;315;354;397;445;500;561;630;707;793;890;1000;1122;1259;1414;1587;1781;2000;2244;2519;2828;3174;3563];

design.devType          = 0; % 0: omission!! % 1: use any deviant // 2: deviant outside of range of sequence only

design.drawReplace      = 0; % 1: freqs drawn with replacement
% 0: freqs drawn without replacement
design.noRep            = 1; % 0: allow adjacent tones to repeat
% 1: do not allow adjacent tones to repeat
design.seqRange         = 13; % select sub-pool ranging over x tones to make sequence portion from (0 = unrestricted)
design.buffer           = 1 ; % tones in s
design.ISI              = 1100:1500;   	% ISI (ms)
design.endWait          = 500; % must be less than ISI+250 % how many milliseconds to wait at endof trial for accepting further button presses
% silence following stimulus = 250ms in stimulus + ISI
design.passive = 0; 
design.EEG              = 0;            % include trigger-channel?

%%
clc
design.subnum       = input('Write down subject number : ','s');
whichBlock          = input('Block number : ');

design.resultsDir = ['Results/Subject_' num2str(design.subnum) '/'];
mkdir(design.resultsDir);


if whichBlock ==1
    design.whichBlock=1;
    try
        load([design.resultsDir 'design_sub' num2str(design.subnum) '.mat']);
        design.whichBlock=1;
        
    catch % 
        disp('No design file generated, making one now, please be patient! \n')
        [design, stimuli] = fDesignStimuli(design);
        save([design.resultsDir 'design_sub' num2str(design.subnum) '.mat'],'design', 'stimuli');
    end
else
    try
        load([design.resultsDir 'design_sub' num2str(design.subnum) '.mat']);
        design.whichBlock = whichBlock; % overwrite design.whichBlock as we are now on the next one
        
    catch % just generate again for remaining blocks
        disp('*** ERROR - no design file found for previous blocks, generating again! \nPress any letter to continue')
        design.nBlocks=design.nBlocks-whichBlock+1;
        design.whichBlock=1; % technically start from block 1
        [design, stimuli] = fDesignStimuli(design);
        save([design.design.resultsDir 'design_sub' num2str(design.subnum) '.mat'],'design', 'stimuli');
        
    end
end

fExpMain(design,stimuli,0);