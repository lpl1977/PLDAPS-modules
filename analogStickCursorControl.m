function settings = analogStickCursorControl(p,state)
%analogStickCursorControl state dependent steps for initializing and
%displaying analog stick cursor.  Requires concurrent use of analogStick
%object.
%
%  settings = analogStickCursorControl
%
%  This is a PLDAPS module for the openreception branch.  The module
%  controls various actions related to display of the analog stick cursor
%  that would be done anytime the cursor is used, such as initialization
%  and display.  It depends on concurrent use of an analog stick object.
%
%  Returns the configuration settings for the module if called without an
%  argument; you can use this as an argument to createRigPrefs.
%
%  NB:  this module calls functions from the analogStick and or
%  analogStickCursor class.
%
%  NB:  the analog stick cursor should generally be the last thing drawn to
%  the screen except for the fixation dot, so its default order will be Inf
%  for now.
%
%  NB:  for now, the analog stick cursor takes screen position
%
%  Lee Lovejoy
%  January 2017
%  ll2833@columbia.edu

if(nargin==0)
    
    %  Generate settings structure
    stateFunction.order = Inf;
    stateFunction.acceptsLocationInput = false;
    filename = mfilename;
    stateFunction.name = filename;
    requestedStates = {'experimentPostOpenScreen'};    
    moduleName = strcat('module',strcat(upper(filename(1)),filename(2:end)));    
    settings.(moduleName).stateFunction = stateFunction;
    settings.(moduleName).use = true;
    settings.(moduleName).requestedStates = requestedStates;
else
    
    %  Execute the state dependent components
    switch state
        case p.trial.pldaps.trialStates.experimentPostOpenScreen
            
            %  Create the cursor object
            p.functionHandles.analogStickCursorObj = analogStickCursor(p.trial.display.ptr);
            fprintf(1,'****************************************************************\n');
            fprintf('Initialized cursor object for analog stick\n');
            fprintf(1,'****************************************************************\n');
    end
end