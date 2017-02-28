function[list, dev_i] = fGenSeq(design,nTones,seqLength,rnd,freqSet,dev,dev_f,omDur,noRep)
%% This function generates a vector representing frequency sequence in a single trial
%
% INPUTS
% -- design: a structure of parameters describing the entire experiment

% parameters for THIS trial:
% -- nTones: how many unique frequencies in the sequence
% -- seqLength: how many tone pips in a stimulus
% -- rnd
%       0: sequences are those which follow a cyclical pattern.
%       1: sequences are made to match each REG sequence, but with a shuffled
%           order
% -- freqSet: the exact frequencies to use in the sequence this trial
% -- dev
%       0: simple REG or RAND
%       1: break the sequence with a DEVIANT tone or an OMISSION
% -- dev_f: frequency to use as deviant (0 if omission or no deviant)
% -- omDur
%       0: if dev, we use a deviant frequency dev_f
%       > 0: we insert a gap
%
%
%
% -- noRep: determines the shuffle type for RAND
%       0: allow adjacent repeats
%       1: re-shuffle until no adjacent repeats
%
% OUTPUTS
% -- list: list of frequencies for the sequence
% -- dev_i: sequence position of deviant

%______________________________Rosy Southwell, last updated Feb 27th 2017



%% Generate sequence
list = [];
freqSetShuf = freqSet(randperm(length(freqSet)));
% generate regular sequence
counter =0;
while (counter<seqLength)
    Nloop = mod(counter,nTones)+1;
    list = [list freqSetShuf(Nloop)];
    counter=counter+1;
end

% choose where dev will be if applicable
if dev
    dev_i = randi(round([seqLength*0.5 seqLength*11/12]),1);
end

% randomize tones if rnd
if rnd
    listshf = ones(length(list),1);
    if noRep % do not allow adjacent tone repeats
        shcount = 0;
        while sum(diff(listshf)==0)>0
            shcount=shcount+1;
            disp(['repeated tones, reshuffling ' num2str(shcount)])
            switch dev
                case 0
                    o = randperm(length(list));
                case 1
                    o1 = randperm(dev_i-1); % randomise before dev
                    o2 = randperm(length(list)-dev_i+1)+dev_i-1; %randomise from dev_i to end
                    o=[o1 o2];
            end
            listshf=list(o);
        end
    else
        switch dev
            case 0 % shuffle whole sequence
                o = randperm(length(list));
            case 1 % shuffle separately before and after the deviant
                o1 = randperm(dev_i-1); % randomise before dev
                o2 = randperm(length(list)-dev_i+1)+dev_i-1; %randomise from dev_i to end
                o=[o1 o2];
        end
        listshf=list(o);
    end
    list=listshf;
end

%% insert deviant
if dev
    if design.devType == 0
        list(dev_i : dev_i + omDur-1) = 0;
    else
        list(dev_i) = dev_f;
    end
else
    dev_i = 0;
end
end