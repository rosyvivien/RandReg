function y=fOutliers(x,criterion)
%[idx,d,mn,idx_unsorted]=nt_find_outlier_trials(x,criterion) - find outlier trials
%
%  idx: indices of trials to keep
%  d: relative deviations from mean
%  
%  x: data vector
%  criterion: keep trials less than criterion from mean
%
%  For example criterion=2 rejects trials that deviate from the mean by
%  more than twice the average deviation from the mean.

if nargin<2; criterion=inf; end
if nargin<3; mn=[]; end

[m,n]=size(x); % time * subjects
x=reshape(x,m*n,1); % concatenate over subjects (if provided a matrix)

if isempty(mn); mn=nanmean(x); end

d=x-mn; % difference from mean

d=abs(d/nanstd(x));

% dbis = d.^2/sum(d.^2) * numel(d);
% idx2=find(dbis>criterion^2);

idx=find(d>criterion);
x(idx) = NaN;
y=x;

disp(['Removing ' num2str(numel(idx)) ' outlier(s)... '])

% [dd,idx]=sort(d,'ascend');
% idx=idx(find(dd<criterion));
% idx_unsorted=idx;
% idx=sort(idx); % put them back in natural order
% mn=mean(x(:,idx),2);

end
