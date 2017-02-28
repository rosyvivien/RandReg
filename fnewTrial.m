function [trial, res] = fnewTrial(res,design,trial,stimuli)
condShuf=design.condShuf{trial.currBlock};
stimShuf=design.stimShuf{trial.currBlock};
ctype = condShuf(trial.trialNum); % numeric code for condition

% Find which condition it is and extract stimulus properties
trial.condLabel = design.conds{ctype};
trial.size = design.condsSize(ctype);  %# Get the numeric characters
trial.dev = design.condsDeviant(ctype);
trial.rnd = design.condsRand(ctype);
trial.respond = trial.dev; % should there be a button press?

trial.condLabel = design.conds{ctype};
trial.freqpattern = stimuli(ctype).stimulus(stimShuf(trial.trialNum)).sequence;
trial.dev_i = stimuli(ctype).stimulus(stimShuf(trial.trialNum)).dev_i;
trial.condi = ctype;
trial.setID = stimuli(ctype).stimulus(stimShuf(trial.trialNum)).setID;

% Put lists of stimulus frequencies in results structure
res.freqlist{trial.trialNum} = trial.freqpattern;
res.dev_i(trial.trialNum) = trial.dev_i;
res.condi(trial.trialNum) = ctype;

% Now generate list of tones
trial.stim = [];

    for l=1:numel(trial.freqpattern)
        tone = fgenTone(trial.freqpattern(l), design.toneDur, design.fs);
        trial.stim = [trial.stim tone];
    end

trial.stim = [trial.stim zeros(1,design.fs/4)]; % add 250 ms at end of stim

% End condition
if trial.trialNum == (design.stimPerBlock * design.nBlocks)
    trial.done = 1;
end

end
