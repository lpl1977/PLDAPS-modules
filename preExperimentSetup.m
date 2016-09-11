function preExperimentSetup(p,state)
%PRE EXPERIMENT SETUP Steps prior to openScreen in PLDAPS on astaroth
%
%  preExperimentSetup(p,state)
%
%  This is a PLDAPS module for the openReception branch.  Prior to
%  openScreen I need to set the head to the Datapixx screen so that the
%  beam position queries are directed there.

switch state
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        disp('****************************************************************')
        disp('Executing module preExperimentSetup at state experimentPreOpenScreen');
        disp('Setting which screen receives beam position queries')
        disp('****************************************************************')        
        Screen('Preference','ScreenToHead', p.trial.display.scrnNum, 0, 0);
end
end

