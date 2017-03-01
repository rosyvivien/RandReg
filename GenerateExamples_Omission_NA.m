%% generate tone sequence stimuli which are rand or reg but include aN OMSISION.
%
% REGULAR sequences are those which follow a cyclical pattern.
%
% RANDOM sequences are made to match each REG sequence, but with a shuffled
% order
%
% Omission is a gap of a whole-number of tones
%
% other parameters - cycle length, tone length, alphabet size, tone range
% _____________________________________________________________________________
% Rosy Southwell 02/2017

%% Parameters
clearvars;
design.nBlocks          = 1;
design.conds            = {'REG10', 'RAND10', 'REG10_gap1','RAND10_gap1','REG10_gap2','RAND10_gap2','REG10_gap3','RAND10_gap3','CTRL','CTRL_gap1','CTRL_gap2','CTRL_gap3'};   % condition labels
design.condsDeviant     = [0 0 1 1 1 1 1 1 0 1 1 1];    % which condition(s) require a button press i.e. contains a deviant
design.condsSize        = [10 10 10 10 10 10 10 10 1 1 1 1];    % how many tones in pool for the respective conditions
design.condsRand        = [0 1 0 1 0 1 0 1 0 0 0 0];    % which conditions are RAND sequences
design.omissionDur      = [0 0 1 1 2 2 3 3 0 1 2 3];
design.condi            = [1 2 3 4 5 6 7 8 9 10 11 12]; % assign each condition with  unique number to use throughout
design.condsCTRL        = [0 0 0 0 0 0 0 0 1 1 1 1];
design.stimPerBlock     = 16;
design.ctrlPerBlock     = 4;
design.nEachCond        = [2 2 2 2 2 2 2 2 1 1 1 1]; % porportions of stimul
design.fs               = 44100;      	% sampling freq hz
design.toneDur          = 50;          	% pip duration
design.seqLength        = 60;           % number of pips in sequence
design.freqPool         = [198;222;250;280;315;354;397;445;500;561;630;707;793;890;1000;1122;1259;1414;1587;1781;2000;2244;2519;2828;3174;3563];

design.devType          = 0; % 0: omission % 1: use any deviant // 2: deviant outside of range of sequence only

design.drawReplace      = 0; % 0: without replacement // 1: with replacement

design.noRep            = 1; % 0: allow adjacent tones to repeat // 1: no repetition
design.seqRange         = 13; % select sub-pool ranging over x tones to make sequence portion from (0 = unrestricted)
design.buffer           = 1 ; % tones in 'buffer zone' which can't be standard or deviant (0 - unrestricted)

design.dob              = rand(1);
design.whichBlock       = 1;
saveStim                = 1;
savePath                = 'sampleSounds/OmissionNA/';
vrs                     = '';   % string describing stimulus generation version
mkdir(savePath);

[design, stimuli] = fDesignStimuli(design);


% histograms of frequencies occurrence
% figure(1)
% clf;
% plotyy(design.freqPool,design.hist.stdfreq,design.freqPool,design.hist.devfreq,@semilogx)



if saveStim
    for c=1:length(stimuli)
        ns=length(stimuli(c).stimulus);
        for i=1:ns
            stim = [];
            freqpattern=stimuli(c).stimulus(i).sequence;
            
            for l=1:numel(freqpattern)
                tone = fgenTone(freqpattern(l), design.toneDur, design.fs);
                stim = [stim tone];
            end
            
            stim = [stim zeros(1,design.fs/4)]; % add 250 ms at end of stim
            
            
            stimName = [design.conds{c} '_' num2str(i) vrs '.wav'];
            audiowrite(fullfile(savePath,stimName),stim,design.fs);
            
        end
    end
    save(fullfile(savePath,['design_' vrs '.mat']),'design');
end