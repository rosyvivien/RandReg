function [design, stimuli] = fDesignStimuli(design)
%% function to generate all tone-pip sequences for entire RR experiment
% Stimuli are designed at the start of the experiment, and
% the audio is generated at each trial.
%
% Depending on parameters in <design> this can be used for simple REG/RANd,
% deviant or omission experiments.
%
% Pre-generating the sequences allows matching of the specific tones used
% between instances of different conditions with the same cycle size -
% referred to here as a 'set'.
% i.e. one set for size 5 would use the same 5 tones and same additional
% deviant tone to generate the RAND, REG, RAND dev and REGdev variants.
%
% also generates tone sequences for the CTRL conditions, if any: these are
% simple oddball sequences with the same timings and tone pool as the main
% stimuli. i.e. effectively have a cycle size of 1.
%
% various options are available for constraining the choices of
% frequencies.
%
% -- design.devType
%       0: Omission
%       1: use any deviant
%       2: deviant outside of range of sequence only
% -- design.omissionDur
%        number of tones to omit (0 if not omission stimuli)
% -- design.drawReplace
%   choose sequence frequencies
%       0: without replacement
%       1: with replacement
% -- design.noRep
%       0: allow adjacent tones to repeat in RAND
%       1: do not allow (re-shuffle until condition satisfied)
% -- design.seqRange  = x;
%   select sub-pool ranging over x tones to make sequence portion from -
%   must be >Rcyc!
%       0: unrestricted
% -- design.buffer  = x;
%   tones in 'buffer zone' which can't be standard or deviant
%       0: unrestricted
%
%______________________________Rosy Southwell, last updated Feb 27th 2017

%% Check inputs & use defaults for missing fields in design structure
if isfield(design,'ctrlPerBlock')
    nCTRLstim = design.nBlocks * design.ctrlPerBlock;
else
    design.ctrlPerBlock = 0;
    design.condsCTRL = zeros(size(design.condi));
    nCTRLstim = 0;
end
nStim = design.nBlocks * design.stimPerBlock;
sizes = unique(design.condsSize(~design.condsCTRL)); % how many different cycle sizes
nSets = nStim/sum(~design.condsCTRL); % how many sets of stimuli needed generating together
stimuli = struct;
rng(now + design.whichBlock,'twister');    % based on subject's DOB + block number

% initialise empty vector for storing frequency histogram!
design.hist.devfreq=zeros(size(design.freqPool));
design.hist.stdfreq=zeros(size(design.freqPool));

for i = 1:length(sizes)
    nTones = sizes(i);
    condsThisSize = find(design.condsSize == nTones); % indices of conditions of same size in design.conds
    
    for s=1:nSets  % make one of each ocndition per loop, with matched freq content
        freqPool = design.freqPool; % master frequency pool for whole expt
        nTot = length(freqPool);
        
        if ~isfield(design,'seqRange') || design.seqRange == 0
            % ensure that the range of standards doesn't cover whole
            % range - to leave some frequencies for deviants!
            bla=0;
            while ~bla
                pool = randperm(nTot,nTones); % select nTones at random
                if isfield(design,'devType') % if deviant condition
                    if design.devType == 2 && min(pool)==1 && max(pool)==nTot 
                        % if the selected frequencies span all possible, need to re-select pool
                    bla=0;
                    end
                else
                    bla=1;
                end
            end
            
        elseif design.seqRange < nTones
            disp '***ERROR*** design.seqRange must be > nTones'
            break
        else
            pool=randperm(design.seqRange,nTones) + randi([0 nTot-design.seqRange]);
        end
        freqSet = freqPool(pool);% select out the actual frequencies this corresponds to
        
        
        %% choose a frequency to use for the deviant conditions
        if isfield(design,'devType')  % check if there are any deviant conditions
            switch design.devType
                case 0
                    dev_f = 0; % i.e. no tone - omission
                    
                case 1
                    % ----simply choose a tone from the pool that isnt
                    % in sequence
                    alt = setdiff(freqPool, freqSet);
                    dev_f = alt(randi(length(alt),1));
                    
                case 2
                    % ----type 2: choose tone from pool but make sure tone is outside of the
                    % range used in the rest of the stimulus
                    if ~isfield(design,'buffer') || design.buffer == 0
                        % ---deviants can be adjacent frequency
                        alt = [freqPool(1:(find(freqPool==min(freqSet)))-1);...
                            freqPool(find((freqPool==max(freqSet)))+1:end)];
                        dev_f = alt(randi(length(alt),1));
                    else
                        % ---- minimum distance for deviants set by buffer size
                        try
                            alt = [freqPool(1:(find(freqPool==min(freqSet)))-1-design.buffer);...
                                freqPool(find((freqPool==max(freqSet)))+1+design.buffer : end)];
                        catch
                            disp '***ERROR*** constraints too tight, no possible deviants remain'
                            break
                        end
                    end
                    dev_f = alt(randi(length(alt),1));
            end
        else
            dev_f = 0;
        end
        
        %% Generate sequence for a single trial
        for ci = 1:length(condsThisSize)
            c = condsThisSize(ci);
            rnd = design.condsRand(c); % logical for REG (0) or RAND(1)
            try
            dev = design.condsDeviant(c); % logical for inclusion of deviant (dev=1)
            catch
                dev = 0;
                dev_f = 0;
            end
            try
                omDur = design.omissionDur(c);
            catch
                omDur = 0; %i.e. if this isnt an omission experiment
            end
            if numel(design.noRep) == 1
            noRep = design.noRep;
            else
                noRep = design.noRep(c);
            end
            [freqPattern,dev_i] = fGenSeq(design,nTones,design.seqLength,rnd,freqSet,dev,dev_f,omDur,noRep);
            
            % save sequence and info
            stimuli(c).condLabel = design.conds{c};
            stimuli(c).rnd = rnd;
            stimuli(c).dev = dev;
            stimuli(c).dev_f = dev_f;
            stimuli(c).stimulus(s).sequence = freqPattern;
            stimuli(c).stimulus(s).dev_i = dev_i;
            stimuli(c).stimulus(s).setID = s;
            stimuli(c).ctrl = 0;
            stimuli(c).omDur = omDur;
            % save frequency occurrence frequency info
            for t = 1:length(freqPattern)
                if t == dev_i
                    design.hist.devfreq(find(freqPool == dev_f)) = 1 + design.hist.devfreq(find(freqPool == dev_f));
                else
                    design.hist.stdfreq(find(freqPool == freqPattern(t))) = 1 + design.hist.stdfreq(find(freqPool == freqPattern(t)));
                end
            end
        end
    end
end

%% Generate a shuffled order of stimulus instances within each condition
for ci=1:length(stimuli)
    stimuli(ci).order = randperm(nSets);
end
%% now generate control stimuli
for s=1:nCTRLstim/2
    freqPool = design.freqPool; % master frequency pool for whole expt
    nTot = length(freqPool);
    pool = randperm(nTot,2); % select 2 Tones at random
    freqSet = freqPool(pool);% select out the actual frequencies this corresponds to
    
    std_f = freqSet(1);
    dev_f = freqSet(2);
    
    for ci=find(design.condsCTRL)
        try
        dev = design.condsDeviant(ci); % logical for inclusion of deviant (dev=1)
        catch
            dev = 0;
            dev_f = 0;
        end
        try
            omDur = design.omissionDur(ci);
        catch
            omDur = 0; %i.e. if this isnt an omission experiment
        end
        [freqPattern,dev_i] = fGenSeq(design,1,design.seqLength,0,std_f,dev,dev_f,omDur, 0);
        
        % save sequence and info
        stimuli(ci).condLabel = design.conds{ci};
        stimuli(ci).rnd = 0;
        stimuli(ci).ctrl = 1;
        stimuli(ci).dev = dev;
        stimuli(ci).dev_f = dev_f;
        stimuli(ci).omDur = omDur;
        stimuli(ci).stimulus(s).sequence = freqPattern;
        stimuli(ci).stimulus(s).dev_i = dev_i;
        stimuli(ci).stimulus(s).setID = s;
        
    end
    
end

for ci=find(design.condsCTRL)
    stimuli(ci).order = randperm(s);
end
