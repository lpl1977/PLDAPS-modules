function frameFlip(p)
%defaultTrialFunction.frameFlip flip the frame and record the time.
%
%  Last event of the frame cycle is frameFlip.  Here the frame is flipped
%  and some timestamps are recorded.  This function extracts components
%  from pldapsDefaultTrialFunction.
%
%  Lee Lovejoy
%  ll2833@columbia.edu
%  October 2017

ft=cell(5,1);
[ft{:}] = Screen('Flip', p.trial.display.ptr, p.trial.nextFrameTime + p.trial.trstart);
p.trial.timing.flipTimes(:,p.trial.iFrame)=[ft{:}];

% The overlay screen always needs to be initialized with a FillRect call
if p.trial.display.overlayptr ~= p.trial.display.ptr
    Screen('FillRect', p.trial.display.overlayptr,0);
end
p.trial.stimulus.timeLastFrame = p.trial.timing.flipTimes(1,p.trial.iFrame)-p.trial.trstart;
end

