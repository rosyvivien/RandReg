% set up experiment parameters for RR_EEG_CT (Candida Tufo's) experiment.
%
% REGULAR sequences are those which follow a cyclical pattern.
%
% RANDOM sequences are made to match each REG sequence, but with a shuffled
% order
%
% other parameters - cycle length, tone length, alphabet size, tone range
%
% % Stimulus sequences are designed at the start of the experiment, and
% the tones themselves generated at each trial.
%
% parameters for designing stimuli are set in this script and saved in a
% structure called 'design'.
%
% This 'design' is passed to the function fDesignStimuli to generate the
% sequences. This outputs 'design' and 'stimuli' structures which are
% passed to fExpMain to run the experiment.
%
%______________________________Rosy Southwell, last updated Feb 27th 2017

clearvars;
close all;

%% Parameters
design.typeExp          = 'RandReg';   % Choose experiment: '

Screen('Preference', 'SkipSyncTests', 1);
design.trigchan = 4;        design.audchan = [6 7];


%% Parameters
design.conds            = {'REG1', 'REG3','REG5', 'RAND3', 'RAND5','RAND20'};   % condition labels, must have same dimensions as vectors below.

design.nBlocks          = 6; % number of blocks total - needed for generating conditions
design.nBlocksRun       = 1; % number of blocks to run - e.g. set to 1 and re-start matlab before each block for EEG

design.stimPerBlock     = 96; % number of stimulu per lock
design.ctrlPerBlock     = 0;  % number of cpntrol stimuli per block
design.nEachCond        = [96 96 96 96 96 96];  % total repeats throughout experiment, must divide by n blocks!

design.typeExp          = 'RandReg';   % Choose experiment type, needed for instructions string
design.condsCTRL        = [0 0 0 0 0 0]; % boolean - which conditions are controls?
design.condsSize        = [1 3 5 3 5 20];    % how many tones in pool for the respective conditions
design.condsRand        = [0 0 0 1 1 1];    % which conditions are RAND sequences
design.condi            = [1 2 3 4 5 6]; % assign each condition with  unique number to use throughout
design.toneDur          = 50;          	% pip duration, ms
design.seqLength        = 60;           % number of pips in sequence

design.triglist         = [10 30 50 70 90 110];     	% trigger values (for EEG)
design.ISI              = 1100:1500;   	% ISI (ms)
design.fs               = 44100;      	% sampling freq audio
design.EEG              = 1;            % is this an EEG experiment (i.e. include trigger-channel?)
design.EEGfs            = 2048;         % EEG recording frequency
design.passive          = 1;            % get behavioural data (0) or passive listening (1)
design.freqPool         = [222;250;280;315;354;397;445;500;561;630;707;793;890;1000;1122;1259;1414;1587;1781;2000];
design.drawReplace      = 0; % draw the frequencies on each trial with (1) or without (0) replacement
design.noRep            = [0 0 0 0 0 1]; % allow adjacent tone repetitions in RAND sequences (0) or forbid (1)
design.seqRange         = 0; % select sub-pool ranging over x tones to make sequence portion from (0 = unrestricted)




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
        design.nBlocksRun=design.nBlocks-whichBlock+1;
        design.whichBlock=1; % technically start from block 1
        [design, stimuli] = fDesignStimuli(design);
        save([design.resultsDir 'design_sub' num2str(design.subnum) '.mat'],'design', 'stimuli');
        
    end
end

fExpMain(design,stimuli,0);