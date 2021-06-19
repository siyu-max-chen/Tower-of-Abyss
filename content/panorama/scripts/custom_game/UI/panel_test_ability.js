$.Msg("!!!!!!!!");
$.Msg("!!!!!!!!");

let TEST_ABILITY_PANEL = null;

const ABILITY_Q = 'AbilityQ';
const ABILITY_W = 'AbilityW';
const ABILITY_E = 'AbilityE';
const ABILITY_CANCEL = 'ability_cancel';

const abilityInfo = [
    { id: 'ability_chain_lightning', type: ABILITY_Q, text: '闪电链', pos: 0 },
    { id: 'ability_curse_pulse', type: ABILITY_Q, text: '诅咒炮', pos: 0 }, 
    { id: 'ability_fist_of_storm', type: ABILITY_Q, text: '风暴重击', pos: 0 },
    { id: 'ability_flaming_slash', type: ABILITY_Q, text: '吹焰斩', pos: 0 },
    { id: 'ability_frost_blast', type: ABILITY_Q, text: '连环霜爆', pos: 0 }, 
    { id: 'ability_ignite', type: ABILITY_Q, text: '点燃术', pos: 0 },
    { id: 'ability_spear_of_frozen_wind', type: ABILITY_Q, text: '寒风之枪', pos: 0 },
    { id: 'ability_stomp_of_pyro_wrath', type: ABILITY_W, text: '焦焰怒击', pos: 1 },
    { id: 'ability_blizzard', type: ABILITY_W, text: '暴风雪', pos: 1 },
];

const deltaX = 180, deltaY = 90;
const MAX_COL = 5, MAX_ROW = 4;

const closeTestAbilityPanel = () => {
    TEST_ABILITY_PANEL.visible = false;
};

const clickAbilityButton = (index) => {
    GameEvents.SendCustomGameEventToServer('event_test_ability_select', {
        abilityId: abilityInfo[index].id,
        text: abilityInfo[index].text,
        pos: abilityInfo[index].pos
    });

    $.Msg(abilityInfo[index].text);
};

const _callPanelTestAbility = () => {
    TEST_ABILITY_PANEL.visible = !TEST_ABILITY_PANEL.visible;
};

const createAbilityPanel = (index, panel) => {
    const background = $.CreatePanel( 'Panel', panel, 'id_ability_panel' + index );
    const row = Math.floor(index / MAX_COL);
    const col = index % MAX_COL;
    
    background.SetHasClass('AbilityBox', true);
    background.SetPositionInPixels(col * deltaX, row * deltaY, 0);

    const button = $.CreatePanel( 'Button', background, 'id_ability_button' + index );
    button.SetHasClass('AbilityButton', true);
    button.SetHasClass(abilityInfo[index].type, true);

    button.SetPanelEvent('ondblclick', () => clickAbilityButton(index));

    const label = $.CreatePanel( 'Label', button, 'id_ability_label' + index );
    label.SetHasClass('AbilityLabel', true);
    label.text = abilityInfo[index].text;
};

const initAbilityPanel = () => {
    const UI = $.GetContextPanel().GetParent().GetParent();
    const panel = UI.FindChildTraverse('id_test_ability_board_panel');
    TEST_ABILITY_PANEL = panel.GetParent();

    abilityInfo.forEach((e, idx) => {
        createAbilityPanel(idx, panel);
    });

    TEST_ABILITY_PANEL.visible = false;
};

initAbilityPanel();

GameEvents.Subscribe('event_call_panel_test_ability', _callPanelTestAbility);
