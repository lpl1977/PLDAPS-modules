function frameUpdate(p)
%defaultTrialFunction.frameUpdate steps for data harvesting.
%
%  frameUpdate is the state at the top of the frame cycle and occurs during
%  or after the most recent frame has been displayed.  During this state we
%  harvest data such as eye position or key presses that correspond to the
%  time interval covered by the most recent frame cycle.  This function 
%  extracts components from the pldapsDefaultTrialFunction.
%
%  Lee Lovejoy
%  ll2833@columbia.edu
%  October 2017

% Check keyboard
[p.trial.keyboard.pressedQ, p.trial.keyboard.firstPressQ, firstRelease, lastPress, lastRelease]=KbQueueCheck(); % fast

if p.trial.keyboard.pressedQ || any(firstRelease)
    p.trial.keyboard.samples = p.trial.keyboard.samples+1;
    p.trial.keyboard.samplesTimes(p.trial.keyboard.samples) = GetSecs;
    p.trial.keyboard.samplesFrames(p.trial.keyboard.samples) = p.trial.iFrame;
    p.trial.keyboard.pressedSamples(:,p.trial.keyboard.samples) = p.trial.keyboard.pressedQ;
    p.trial.keyboard.firstPressSamples(:,p.trial.keyboard.samples) = p.trial.keyboard.firstPressQ;
    p.trial.keyboard.firstReleaseSamples(:,p.trial.keyboard.samples) = firstRelease;
    p.trial.keyboard.lastPressSamples(:,p.trial.keyboard.samples) = lastPress;
    p.trial.keyboard.lastReleaseSamples(:,p.trial.keyboard.samples) = lastRelease;
end

% Some standard PLDAPS key functions
if any(p.trial.keyboard.firstPressQ)
    
    % [M]anual reward
    if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.mKey)
        pds.behavior.reward.give(p);
        
        % [P]ause
    elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.pKey)
        p.trial.pldaps.quit = 1;
        ShowCursor;
        
        % [Q]uit
    elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.qKey)
        p.trial.pldaps.quit = 2;
        ShowCursor;
        
        % [D]ebug mode   (...like pause, but does not leave workspace of currently executing trial)
    elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.dKey)
        disp('stepped into debugger. Type dbcont to start first trial...')
        keyboard %#ok<MCKBD>
    end
end

% Poll mouse
if p.trial.mouse.use
    [cursorX,cursorY,isMouseButtonDown] = GetMouse(p.trial.mouse.windowPtr);
    % Return data in trial struct
    p.trial.mouse.samples = p.trial.mouse.samples+1;
    p.trial.mouse.samplesTimes(p.trial.mouse.samples)=GetSecs;
    p.trial.mouse.cursorSamples(1:2,p.trial.mouse.samples) = [cursorX;cursorY];
    p.trial.mouse.buttonPressSamples(:,p.trial.mouse.samples) = isMouseButtonDown';
    % Use as eyepos if requested
    if(p.trial.mouse.useAsEyepos)
        if p.trial.pldaps.eyeposMovAv==1
            p.trial.eyeX = p.trial.mouse.cursorSamples(1,p.trial.mouse.samples);
            p.trial.eyeY = p.trial.mouse.cursorSamples(2,p.trial.mouse.samples);
        else
            mInds=(p.trial.mouse.samples-p.trial.pldaps.eyeposMovAv+1):p.trial.mouse.samples;
            p.trial.eyeX = mean(p.trial.mouse.cursorSamples(1,mInds));
            p.trial.eyeY = mean(p.trial.mouse.cursorSamples(2,mInds));
        end
    end
end

%get analogData from Datapixx
pds.datapixx.adc.getData(p);

%get eyelink data
pds.eyelink.getQueue(p);

end

