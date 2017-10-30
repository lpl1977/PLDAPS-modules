function trialCleanUpandSave(p)
%TRIALCLEANUPANDSAVE Summary of this function goes here
%   Detailed explanation goes here
%  Schedule a screen flip; this would be whatever was specified
%  in trialItiDraw (blank if nothing specified)
Screen('Flip', p.trial.display.ptr, 0, [], 1);

% Execute all time-sesitive tasks first
if p.trial.datapixx.use
    p.trial.datapixx.datapixxstoptime = Datapixx('GetTime');
end
p.trial.trialend = GetSecs- p.trial.trstart;

%clean up analogData collection from Datapixx
pds.datapixx.adc.cleanUpandSave(p);
%             if p.trial.datapixx.use
%                 p.trial.timing.datapixxTRIALEND = pds.datapixx.flipBit(p.trial.event.TRIALEND,p.trial.pldaps.iTrial);  % start of trial (Plexon)
%             end

p.trial.trialnumber   = p.trial.pldaps.iTrial;
p.trial.timing.flipTimes      = p.trial.timing.flipTimes(:,1:p.trial.iFrame);
p.trial.timing.frameStateChangeTimes    = p.trial.timing.frameStateChangeTimes(:,1:p.trial.iFrame);

%do a last frameUpdate   (checks & refreshes keyboard/mouse/analog/eye data)
defaultTrialFunction.frameUpdate(p)

% Flush KbQueue
KbQueueStop();
KbQueueFlush();

%will this crash when more samples where created than preallocated?
% mouse input
if p.trial.mouse.use
    i0 = p.trial.mouse.samples+1;
    p.trial.mouse.cursorSamples(:,i0:end) = [];
    p.trial.mouse.buttonPressSamples(:,i0:end) = [];
    p.trial.mouse.samplesTimes(:,i0:end) = [];
end

i0 = p.trial.keyboard.samples+1;
p.trial.keyboard.samplesTimes(:,i0:end) = [];
p.trial.keyboard.samplesFrames(:,i0:end) = [];
p.trial.keyboard.pressedSamples(:,i0:end) = [];
p.trial.keyboard.firstPressSamples(:,i0:end) = [];
p.trial.keyboard.firstReleaseSamples(:,i0:end) = [];
p.trial.keyboard.lastPressSamples(:,i0:end) = [];
p.trial.keyboard.lastReleaseSamples(:,i0:end) = [];

% Eyelink specific:
if p.trial.eyelink.use
    [Q, rowId] = pds.eyelink.saveQueue(p);
    p.trial.eyelink.samples = Q;
    p.trial.eyelink.sampleIds = rowId; % I overwrite everytime because PDStrialTemps get saved after every trial if we for some unforseen reason ever need this for each trial
    p.trial.eyelink.events = p.trial.eyelink.events(:,~isnan(p.trial.eyelink.events(1,:)));
end

% reward system
pds.behavior.reward.cleanUpandSave(p);


end

