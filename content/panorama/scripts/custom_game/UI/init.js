$.Msg("!!!!!!!!");

const EMPTY_FUNC = function () {};

const disableTalentTree = () => {
    const UI = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("StatBranch");

    UI.visible = false;
    UI.SetPanelEvent("onmouseover", EMPTY_FUNC);
    UI.SetPanelEvent("onactivate", EMPTY_FUNC);

    UI.FindChildTraverse('StatBranchBG').visible = false;
    UI.FindChildTraverse('StatBranchGraphics').visible = false;
};

const disableAghsStatus = () => {
    const UI = $.GetContextPanel().GetParent().GetParent().FindChildTraverse('AghsStatusContainer');
    UI.visible = false;
}

disableTalentTree();
disableAghsStatus();
