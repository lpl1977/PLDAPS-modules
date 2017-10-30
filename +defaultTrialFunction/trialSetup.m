function trialSetup(p)
%defaultTrialFunction.trialSetup initial steps to setup for the next trial.
%
%  trialSeup includes steps done at the beginning of a trial but before
%  truly time dependent steps are done in trialPrepare.  This function
%  extracts components from pldapsDefaultTrialFunction.  User steps may be
%  called in this state.
%
%  Lee Lovejoy
%  ll2833@columbia.edu
%  October 2017

%  Mainly timing and subunit setup here
p.trial.timing.flipTimes = zeros(5,p.trial.pldaps.maxFrames);
p.trial.timing.frameStateChangeTimes = NaN(9,p.trial.pldaps.maxFrames);

%  setup analog data collection from Datapixx
pds.datapixx.adc.trialSetup(p);

%  Call PsychDataPixx('GetPreciseTime').  Note that this is not the same as
%  the later call to Datapixx to get time immediately prior to trial start.
if p.trial.datapixx.use
    [getsecs, boxsecs, confidence] = PsychDataPixx('GetPreciseTime');
    p.trial.timing.datapixxPreciseTime(1:3) = [getsecs, boxsecs, confidence];
end

%  Setup fields for the keyboard data
p.trial.keyboard.samples = 0;
p.trial.keyboard.samplesTimes=zeros(1,round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.samplesFrames=zeros(1,round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.pressedSamples=false(1,round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.firstPressSamples = zeros(p.trial.keyboard.nCodes,round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.firstReleaseSamples = zeros(p.trial.keyboard.nCodes,round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.lastPressSamples = zeros(p.trial.keyboard.nCodes,round(p.trial.pldaps.maxFrames*1.1));
p.trial.keyboard.lastReleaseSamples = zeros(p.trial.keyboard.nCodes,round(p.trial.pldaps.maxFrames*1.1));

%  Setup fields for the mouse data
if p.trial.mouse.use
    [~,~,isMouseButtonDown] = GetMouse();
    p.trial.mouse.cursorSamples = zeros(2,round(round(p.trial.pldaps.maxFrames*1.1)));
    p.trial.mouse.buttonPressSamples = zeros(length(isMouseButtonDown),round(round(p.trial.pldaps.maxFrames*1.1)));
    p.trial.mouse.samplesTimes=zeros(1,round(round(p.trial.pldaps.maxFrames*1.1)));
    p.trial.mouse.samples = 0;
end

%  EyeLink Toolbox setup
pds.eyelink.startTrial(p);

%  Prepare reward system--this stores even manual rewards triggered from
%  keyboard
pds.behavior.reward.trialSetup(p);
            
end

