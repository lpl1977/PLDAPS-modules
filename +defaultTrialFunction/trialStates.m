function settings = trialStates(p,state)
%defaultTrialFunction.trialStates manage default trial state dependent actions
%
%  settings = defaultTrialFunction.trialStates
%
%  This is a PLDAPS module for the openreception branch.  This module is
%  based on the pldapsDefaultTrialFunction and substitutes for it.  Note
%  that the trial master function (p.trial.pldaps.trialFunction), if
%  defined, is called at order NaN, after Inf.  Be careful!
%
%  Returns the configuration settings for the module if called without an
%  argument; you can use this as an argument to createRigPrefs.
%
%  Sequence of states in trial:
%
%  trialSetup
%
%  trialPrepare
%
%  trialItiDraw
%
%  trialCleanUpandSave
%
%  Lee Lovejoy
%  October 2017
%  ll2833@columbia.edu


if(nargin==0)
    
    %  Generate the settings structure
    stateFunction.order = Inf;
    stateFunction.acceptsLocationInput = false;
    filename = mfilename;
    stateFunction.name = 'defaultTrialFunction.frameStates';
    requestedStates = {'frameUpdate' 'frameDrawingFinished' 'frameFlip'};
    moduleName = strcat('module',strcat(upper(filename(1)),filename(2:end)));
    settings.(moduleName).stateFunction = stateFunction;
    settings.(moduleName).use = true;
    settings.(moduleName).requestedStates = requestedStates;    
else
    
    %  FRAME STATES
    
    switch state
        case p.trial.pldaps.trialStates.frameUpdate
            defaultTrialFunction.frameUpdate(p);            
        
        case p.trial.pldaps.trialStates.frameDrawingFinished;
            defaultTrialFunction.frameDrawingFinished(p);
        
        case p.trial.pldaps.trialStates.frameFlip;
            defaultTrialFunction.frameFlip(p);
    end

    
    
    %  TRIAL STATES
    %  State dependent execution for trial states
    %
    %  Before any trials these states are called:
    %
    %  experimentPreOpenScreen--executed once immediately before openScreen
    %
    %  experimentPostOpenScreen--executed once immediately after openScreen
    %
    %  The trial loop includes:
    %
    %  trialSetup--first state executed in a trial loop; any steps that
    %  need to be done before a trial is started, for example preparing
    %  stimulus parameters, should be done here.
    %
    %  trialPrepare--second state executed in a trial loop and immediately
    %  before frame cycle, so PLDAPS timing dependent steps go here.
    %
    %  **frame states executed**
    %
    %  trialItiDraw--penultimate state executed in the trial loop; good for
    %  preparing to display to screen anything which would be shown during
    %  a pause.
    %
    %  trialCleanUpandSave--last state executed; post trial management
    %
    %  Following the trial loop a last state can be called:
    %
    %  experimentAfterTrials--executed after each trial
    %
    %  After all trials completed and experiment is about to conclude:
    %
    %  experimentCleanUp--very last state executed prior to exit
    
    switch state
        
        case p.trial.pldaps.trialStates.experimentPreOpenScreen
            
            %  Currently nothing to do here
            
        case p.trial.pldaps.trialStates.experimentPostOpenScreen
            
            %  Write status to stdout
            filename = mfilename;
            moduleName = strcat('module',strcat(upper(filename(1)),filename(2:end)));
            fprintf('****************************************************************\n');
            fprintf('universalTrialFunction will be called at priority %d\n',...
                p.trial.(moduleName).stateFunction.order);
            fprintf('****************************************************************\n');
            
            %  Here would be a good place to call for default colors,
            %  bitnames, etc.
            
            
        case p.trial.pldaps.trialStates.trialSetup
            
            %  Mainly timing and subunit setup here
            p.trial.timing.flipTimes = zeros(5,p.trial.pldaps.maxFrames);
            p.trial.timing.frameStateChangeTimes = NaN(9,p.trial.pldaps.maxFrames);
            
            %  setup analogData collection from Datapixx
            pds.datapixx.adc.trialSetup(p);
            
            %  Call PsychDataPixx('GetPreciseTime') to make sure the clocks
            %  stay synced.  Note this is not the same as the later call to
            %  Datapixx to get time immediately prior to trial start.
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
            
            %  Prepare reward system--this stores even manual rewards
            %  triggered from keyboard
            pds.behavior.reward.trialSetup(p);
            
        case p.trial.pldaps.trialStates.trialPrepare
            
            %  Some more timing specific steps without user interference;
            %  these steps mostly inform all subunits that the trial is
            %  about to start and are more time sensitive than steps done
            %  in trialSetup.
            
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
            %  Record current time and obtain current time from Datapixx;
            %  clocktime is a unique trial identifier and so we can also
            %  strobe this to the neural data acquisition system.  However
            %  we are not yet using a data acquisition system so those
            %  parts are commented out for now.
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
            
        case p.trial.pldaps.trialStates.trialItiDraw
            
            %  Currently nothing to do here.
            
        case p.trial.pdlaps.trialStates.trialCleanUpandSave
            
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
            if p.trial.datapixx.use
                p.trial.timing.datapixxTRIALEND = pds.datapixx.flipBit(p.trial.event.TRIALEND,p.trial.pldaps.iTrial);  % start of trial (Plexon)
            end
            
            if(p.trial.pldaps.draw.photodiode.use)
                p.trial.timing.photodiodeTimes(:,p.trial.pldaps.draw.photodiode.dataEnd:end)=[];
            end
            
            p.trial.trialnumber   = p.trial.pldaps.iTrial;
            p.trial.timing.flipTimes      = p.trial.timing.flipTimes(:,1:p.trial.iFrame);
            p.trial.timing.frameStateChangeTimes    = p.trial.timing.frameStateChangeTimes(:,1:p.trial.iFrame);
            
            %do a last frameUpdate   (checks & refreshes keyboard/mouse/analog/eye data)
            frameUpdate(p)
            
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
            
        case p.trial.pldaps.trialStates.experimentAfterTrials
            
            %  For now, nothing to do here
            
    end
    
    
    
    
    %  Execute pldapsDefaultTrialFunction for all states
    pldapsDefaultTrialFunction(p,state);
end
end

