function settings = module(p,state)
%defaultTrialFunction.module manage frame cycle state dependent actions
%
%  settings = defaultTrialFunction.module
%
%  This is a PLDAPS module for the openreception branch.  This module is
%  based on the pldapsDefaultTrialFunction and substitutes for it.  Note
%  that the trial master function (p.trial.pldaps.trialFunction), if
%  defined, is called at order NaN, after Inf.  Be careful!
%
%  Returns the configuration settings for the module if called without an
%  argument; you can use this as an argument to createRigPrefs.
%
%  Sequence of states in FRAME CYCLE:
%
%  frameUpdate--harvest data from last frame cycle.  User-defined data
%  harvesting may happen in this state but no user-defined task control
%  should occur here.  Any user-defined data harvesting should be
%  independent of default data harvesting! User interactive control such as
%  manual rewards or pauses is processed here.  (order Inf)
%
%  framePrepareDrawing--user defined drawing and task control.  By design
%  no default events should occur here.
%
%  frameDraw--all calls to Screen go here.  Some optional default draws
%  could be done here or in other modules.
%
%  frameDrawingFinished--steps immediately prior to flip and alert to PTB
%  (order Inf).
%
%  frameFlip--execute the flip (order Inf).
%
%  Sequence of states in TRIAL LOOP:
%
%  trialSetup--first state executed in a trial loop; any steps that
%  need to be done before a trial is started, for example preparing
%  stimulus parameters, should be done here.
%
%  trialPrepare--second state executed in a trial loop and immediately
%  before frame cycle, so PLDAPS timing dependent steps go here.
%
%  trialItiDraw--penultimate state executed in the trial loop; good for
%  preparing to display to screen anything which would be shown during
%  a pause.
%
%  trialCleanUpandSave--last state executed; post trial management
%
%  Sequence of states in EXPERIMENT LOOP:
%
%  Before any trials these states are called:
%
%  experimentPreOpenScreen--executed once immediately before openScreen
%
%  experimentPostOpenScreen--executed once immediately after openScreen
%
%  Following the trial loop a last state can be called:
%
%  experimentAfterTrials--executed after each trial
%
%  After all trials completed and experiment is about to conclude:
%
%  experimentCleanUp--very last state executed prior to exit
%
%  Lee Lovejoy
%  October 2017
%  ll2833@columbia.edu


if(nargin==0)
    
    %  Generate the settings structure
    stateFunction.order = Inf;
    stateFunction.acceptsLocationInput = false;
    stateFunction.name = 'defaultTrialFunction.module';
    requestedStates = {'frameUpdate' 'frameDrawingFinished' 'frameFlip' 'experimentPostOpenScreen'};
    moduleName = 'moduleDefaultTrialFunction';
    settings.(moduleName).stateFunction = stateFunction;
    settings.(moduleName).use = true;
    settings.(moduleName).requestedStates = requestedStates;
else
    
    switch state
        
        %  FRAME CYCLE
        
        case p.trial.pldaps.trialStates.frameUpdate
            defaultTrialFunction.frameUpdate(p);
            
        case p.trial.pldaps.trialStates.frameDrawingFinished;
            defaultTrialFunction.frameDrawingFinished(p);
            
        case p.trial.pldaps.trialStates.frameFlip;
            defaultTrialFunction.frameFlip(p);
            
            %  EXPERIMENT LOOP
            
        case p.trial.pldaps.trialStates.experimentPostOpenScreen
            
            %  Write status to stdout
            fprintf('****************************************************************\n');
            fprintf('defaultTrialFunction will be called at priority Inf\n');
            fprintf('****************************************************************\n');
            
            %  Set default colors
            defaultColors(p);
            LovejoyDefaultColors(p);            
            
            %  TRIAL LOOP
            
        case p.trial.pldaps.trialStates.trialSetup
            defaultTrialFunction.trialSetup(p);
            
        case p.trial.pldaps.trialStates.trialPrepare
            defaultTrialFunction.trialPrepare(p);
            
        case p.trial.pdlaps.trialStates.trialCleanUpandSave
            defaultTrialFunction.trialCleanUpandSave(p);
    end
end
end

