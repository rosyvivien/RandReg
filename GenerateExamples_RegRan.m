%% generate tone sequence stimuli which are REG or RAND of a given Rcyc
%
% REGULAR sequences are those which follow a cyclical pattern.
%
% RANDOM sequences are made to match each REG sequence, but with a shuffled
% order
%
% NOTE: if your sequence generation is taking too long to randomise
% - this is because if design.noRep ==1 the sequence is
% re-shuffled until no adjacent tones repeat, which may take a while for
% small Rcyc e.g. 5 or less. 
% You may prefer to set design.noRep = 0 for these cycle sizes
% _____________________________________________________________________________
% Rosy Southwell 02/2017

%% Parameters
clearvars;

design.conds            = {'REG5', 'RAND5', 'REG10' , 'RAND10'};   % condition labels, must have same dimensions as vectors below.
design.condsSize        = [5 5 10 10];    % how many tones in pool for the respective conditions
design.condsRand        = [0 1 0 1];    % which conditions are RAND sequences
design.condi            = [1 2 3 4]; % assign each condition with  unique number to use throughout
design.condsCTRL        = [0 0 0 0]; % which conditions are controls?
design.fs               = 44100;      	% sampling freq hz
design.toneDur          = 50;          	% pip duration, ms
design.seqLength        = 60;           % number of pips in sequence

design.nBlocks          = 1; % number of blocks total - needed for generating conditions
design.stimPerBlock     = 16; % number of stimuli per block
design.ctrlPerBlock     = 0;  % number of control stimuli per block
design.nEachCond        = [4 4 4 4];  % total repeats throughout experiment, must divide by n blocks!

% original poool of 20 frequencies used by NB:
%design.freqPool         = [222;250;280;315;354;397;445;500;561;630;707;793;890;1000;1122;1259;1414;1587;1781;2000];
% Rosy's increased pool size of 26: 
design.freqPool         = [198;222;250;280;315;354;397;445;500;561;630;707;793;890;1000;1122;1259;1414;1587;1781;2000;2244;2519;2828;3174;3563];

design.drawReplace      = 0; % 1: freqs drawn with replacement
% 0: freqs drawn without replacement
design.noRep            = [0 0 1 1]; % 0: allow adjacent tones to repeat
% 1: do not allow adjacent tones to repeat. 
% If numel(noRep) = nConds, apply separate criteria to each condition
design.seqRange         = 0; % select sub-pool ranging over x tones to make sequence portion from (0 = unrestricted)
design.dob              = rand(1); % for seeding random number generation
design.whichBlock       = 1; 
saveStim                = 1; % do you want to save some WAVs of the stimuli? Useful if you want some examples, or if you want to use offline stimulus generation
savePath                = 'sampleREGRAN'; mkdir(savePath);
vrs                     = '1';   % string describing stimulus generation version, useful for de-bugging / playing with parameters
mkdir(savePath);

[design, stimuli] = fDesignStimuli(design); % this simply generates a vector of tone pip frequencies, NOT an audio file

% this generates audio from the sequences generated above & saves in the
% specified directory
if saveStim
    for c=1:length(stimuli)
        ns=length(stimuli(c).stimulus); % number of tone pips
        for i=1:ns
            stim = [];
            freqpattern=stimuli(c).stimulus(i).sequence;
            
            for l=1:numel(freqpattern)
                tone = fgenTone(freqpattern(l), design.toneDur, design.fs);
                stim = [stim tone];
            end
            
            stim = [stim zeros(1,design.fs*0.25)]; % add 250 ms silence at end of stim
            
            stimName = [design.conds{c} '_' num2str(i) '_v' vrs '.wav'];
            audiowrite(fullfile(savePath,stimName),stim,design.fs);
            
        end
    end
    save(fullfile(savePath,['design_v' vrs '.mat']),'design'); % also saves a mat containing all the sequence info and the parameter settings
end