function trialPrepare(p)
%defaultTrialFunction.trialPrepare PLDAPS time dependent steps
%
%  trialPrepare follows trialSetup and contains more timing specific steps
%  without user interference; these steps mostly inform all subunits that
%  the trial is about to start and are more time sensitive than steps done
%  in trialSetup.
%
%  Lee Lovejoy
%  ll2833@columbia.edu
%  October 2017

%  PsychPortAudio
pds.audio.clearBuffer(p)

% Ensure anything in the datapixx buffer has been pushed/updated
if p.trial.datapixx.use
    Datapixx RegWrRd;
end

%  Initalize Keyboard
pds.keyboard.clearBuffer(p);

%  Eyelink Toolbox Setup
pds.eyelink.startTrialPrepare(p);

%  START TRIAL TIMING
%
%  Record current time and obtain current time from Datapixx; clocktime is
%  a unique trial identifier and so we can also strobe this to the neural
%  data acquisition system.  However we are not yet using a data
%  acquisition system so those parts are commented out for now.
p.trial.unique_number = fix(clock);
if p.trial.datapixx.use
    %                 for ii = 1:6
    %                     p.trial.datapixx.unique_number_time(ii,:)=pds.datapixx.strobe(p.trial.unique_number(ii));
    %                 end
    p.trial.timing.datapixxStartTime = Datapixx('Gettime');
    %                 p.trial.timing.datapixxTRIALSTART = pds.datapixx.flipBit(p.trial.event.TRIALSTART,p.trial.pldaps.iTrial);  % start of trial (Plexon)
end

% These params are all predetermined, so just set them equal to 0,
% and keep any code post-vblsync to an absolute minimum!  (...yes, even just touching p.trial)
p.trial.stimulus.timeLastFrame = 0;     % formerly:  vblTime-p.trial.trstart;
p.trial.ttime  = 0;                     % formerly:  GetSecs - p.trial.trstart;
p.trial.timing.syncTimeDuration = 0;    % formerly:  p.trial.ttime;

% Sync up with screen refresh before jumping into actual trial
%   ** this also ensures that the async flip scheduled at the end of the last trial
%      has had time to complete & won't interfere with future draws/flips
p.trial.timing.itiFrameCount = Screen('WaitBlanking', p.trial.display.ptr);
p.trial.trstart = GetSecs;
end

