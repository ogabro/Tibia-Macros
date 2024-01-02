-- main tab

local walk_button = modules.game_luniabot.walkButton;

function hasEffect(tile, effect)
  for i, fx in ipairs(tile:getEffects()) do
    if fx:getId() == effect then
      return true
    end
  end
  return false
end


-- Gameplay macros

UI.Separator()
UI.Label("Imp Functions")

local toFollow = "Enter Char Name"
local toFollowPos = {}

local followMacro = macro(20, "Follow Player", function()
  local target = getCreatureByName(toFollow)
  if target then
    local tpos = target:getPosition()
    toFollowPos[tpos.z] = tpos
  end
  if player:isWalking() then return end
  local p = toFollowPos[posz()]
  if not p then return end
  if autoWalk(p, 20, { ignoreNonPathable = true, precision = 1 }) then
    delay(100)
  end
end)

onCreaturePositionChange(function(creature, oldPos, newPos)
  if creature:getName() == toFollow then
    toFollowPos[newPos.z] = newPos
  end
end)

-- Create a text input to change the followed player's name
local followTE = UI.TextEdit(toFollow, function(widget, newText)
  toFollow = newText
end)

followMacro:setOn(false)

-- Macro for healing a friend (ED only)

local friendName = "Kos Omac"  -- Default player name

macro(100, "Heal Friend", function()
    local friend = getPlayerByName(friendName)
    if friend and friend:getHealthPercent() < 95 then
		say("exura gran sio \"" .. friendName)
        delay(1000)
    end
end)

local friendTE = UI.TextEdit(friendName, function(widget, newText)
    friendName = newText
end)

-- Macro to Auto Haste

macro(500, "Auto Haste", function() 
  if hasHaste() then return end
  if TargetBot then 
    TargetBot.saySpell(storage.hasteSpell) -- sync spell with targetbot if available
  else
    say(storage.hasteSpell)
  end
end)

UI.TextEdit(storage.hasteSpell or "utani hur", function(widget, newText)
  storage.hasteSpell = newText
end)

-- Macro for Attack & Buff Spells

UI.Separator()

--Vocation Speller
addLabel("", "Spells")
local pvpspeller = macro(500, "PvP Speller", nil, function()
  if not g_game.isAttacking() then 
    return
  end
  say("exevo gran max frigo")
  say("exori max pura")
end)
local distance = 5
local amountOfMonsters = 2
local pvespeller = macro(500, "Monster Speller" ,  function()
    local specAmount = 0
    if not g_game.isAttacking() then
        return
    end
    for i,mob in ipairs(getSpectators()) do
        if (getDistanceBetween(player:getPosition(), mob:getPosition())  <= distance and mob:isMonster())  then
            specAmount = specAmount + 1
        end
    end
    if (specAmount >= amountOfMonsters) then
        say("exevo gran max frigo")
        say("exevo max frigo")
    else
        say("exevo gran max frigo")
        say("exori max pura")
    end
end)


local BuffSpell = 'utito gran mas frigo'

macro(1, "Utito gran mas frigo", function()
    if g_game.isAttacking() and not isInProtectionZone() then
        if not modules.game_cooldown.isGroupCooldownIconActive(group) and not modules.game_cooldown.isCooldownIconActive(121) then
            say('Utito gran mas frigo')
        end
      end
end)

UI.Separator()
UI.Label("Secondary Functions")

-- Macro to Auto Follow Monster

macro(1000, "Follow Monster", function() g_game.setChaseMode(1) end)

-- Macro to Hold Monster target

macro(100, "Hold Target",  function()
    if g_game.isAttacking() then
        oldTarget = g_game.getAttackingCreature()
    end
    if (oldTarget and oldTarget:getPosition()) then
      if (not g_game.isAttacking() and getDistanceBetween(pos(), oldTarget:getPosition()) <= 9) then
          g_game.attack(oldTarget)
      end
    end
end)

macro(100, "Low HP Target", function() 
  local battlelist = getSpectators();
  local closest = 10
  local lowesthpc = 101
  for key, val in pairs(battlelist) do
    if val:isMonster() then
      if getDistanceBetween(player:getPosition(), val:getPosition()) <= closest then
        closest = getDistanceBetween(player:getPosition(), val:getPosition())
        if val:getHealthPercent() < lowesthpc then
          lowesthpc = val:getHealthPercent()
        end
      end
    end
  end
  for key, val in pairs(battlelist) do
    if val:isMonster() then
      if getDistanceBetween(player:getPosition(), val:getPosition()) <= closest then
        if g_game.getAttackingCreature() ~= val and val:getHealthPercent() <= lowesthpc then 
          g_game.attack(val)
          break
        end
      end
    end
  end
end)

-- Macro for AutoMount

macro(5000, "Auto-Mount", function() 
  if isInPz() then return end
  if not player:isMounted() then player:mount() end
end)

-- Part of Macro for Auto Hur up/down, this identifies how the player is pressing the keystrokes

local usingWASD = false
local walkDir
onKeyDown(function(keys)
  if usingWASD then
    if keys == "D" or keys == "A" or keys == "S" or keys == "W" then
      walkDir = keys
    end
  else
    if keys == "Up" or keys == "Right" or keys == "Down" or keys == "Left" then
      walkDir = keys
    end
  end
end)

-- Macro for Auto Hur up/down

macro(100, "Auto Levitate", function()
  local playerPos = pos()
  local levitateTile
  if walkDir == "W" or walkDir == "Up" then -- north
    playerPos.y = playerPos.y - 1
    turn(0)
    levitateTile = g_map.getTile(playerPos)
  elseif walkDir == "D" or walkDir == "Right" then -- east
    playerPos.x = playerPos.x + 1
    turn(1)
    levitateTile = g_map.getTile(playerPos)
  elseif walkDir == "S" or walkDir == "Down" then -- south
    playerPos.y = playerPos.y + 1
    turn(2)
    levitateTile = g_map.getTile(playerPos)
  elseif walkDir == "A" or walkDir == "Left" then -- west
    playerPos.x = playerPos.x - 1
    turn(3)
    levitateTile = g_map.getTile(playerPos)
  end

  if levitateTile and not levitateTile:isWalkable() then
    if levitateTile:getGround() then
      say('exani hur "up')
      walkDir = nil
    else
      say('exani hur "down')
      walkDir = nil
    end
  end
  walkDir = nil
  end)
  
-- Macro for Private Messages

local privateTabs = addSwitch("openPMTabs", "Private Message Alert", function(widget) widget:setOn(not widget:isOn()) storage.OpenPrivateTabs = widget:isOn() end, parent)
privateTabs:setOn(storage.OpenPrivateTabs)

onTalk(function(name, level, mode, text, channelId, pos)
    if mode == 4 and privateTabs:isOn() then
        local g_console = modules.game_console
        local privateTab = g_console.getTab(name)
        if privateTab == nil then
            privateTab = g_console.addTab(name, true)
            g_console.addPrivateText(g_console.applyMessagePrefixies(name, level, text), g_console.SpeakTypesSettings['private'], name, false, name)
            playSound("/sounds/Private Message.ogg")
        end
        return
    end
end)

	addSeparator("separator")

-- Marco to open Backpacks & Containers

contPanelName = "renameContainers"
if type(storage[contPanelName]) ~= "table" then
    storage[contPanelName] = {
        enabled = false;
        purse = true;
        all = true;
        list = {
            {
                value = "Main Backpack",
                enabled = true,
                item = 9601,
                min = false,
            },
            {
                value = "Tokens",
                enabled = true,
                item = 10346,
                min = true,
            },
            {
                value = "Money",
                enabled = true,
                item = 2871,
                min = true,
            },
            {
                value = "Purse",
                enabled = true,
                item = 23396,
                min = true,
            },
        }
    }
end

local renameContui = setupUI([[
Panel
  height: 38

  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    !text: tr('Minimise Containers')

  Button
    id: editContList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

  Button
    id: reopenCont
    !text: tr('Reopen Containers')
    anchors.left: parent.left
    anchors.top: prev.bottom
    anchors.right: parent.right
    height: 17
    margin-top: 2

  ]])
renameContui:setId(contPanelName)

g_ui.loadUIFromString([[
BackpackName < Label
  background-color: alpha
  text-offset: 18 0
  focusable: true
  height: 16

  CheckBox
    id: enabled
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: 15
    height: 15
    margin-top: 2
    margin-left: 3

  $focus:
    background-color: #00000055

  Button
    id: state
    !text: tr('M')
    anchors.right: remove.left
    margin-right: 5
    width: 15
    height: 15

  Button
    id: remove
    !text: tr('x')
    !tooltip: tr('Remove')
    anchors.right: parent.right
    margin-right: 15
    width: 15
    height: 15

ContListsWindow < MainWindow
  !text: tr('Container Names')
  size: 435 166
  @onEscape: self:hide()

  TextList
    id: itemList
    anchors.left: parent.left
    anchors.top: parent.top
    size: 180 83
    margin-top: 3
    margin-bottom: 3
    margin-left: 3
    vertical-scrollbar: itemListScrollBar

  VerticalScrollBar
    id: itemListScrollBar
    anchors.top: itemList.top
    anchors.bottom: itemList.bottom
    anchors.right: itemList.right
    step: 14
    pixels-scroll: true

  VerticalSeparator
    id: sep
    anchors.top: parent.top
    anchors.left: itemList.right
    anchors.bottom: separator.top
    margin-top: 3
    margin-bottom: 6
    margin-left: 10

  Label
    id: lblName
    anchors.left: sep.right
    anchors.top: sep.top
    width: 70
    text: Name:
    margin-left: 10
    margin-top: 3

  TextEdit
    id: contName
    anchors.left: lblName.right
    anchors.top: sep.top
    anchors.right: parent.right

  Label
    id: lblCont
    anchors.left: lblName.left
    anchors.top: contName.bottom
    width: 70
    text: Container:
    margin-top: 20

  BotItem
    id: contId
    anchors.left: lblCont.right
    anchors.top: contName.bottom
    margin-top: 12

  Button
    id: addItem
    anchors.right: contName.right
    anchors.top: contName.bottom
    margin-top: 5
    text: Add
    width: 40
    font: cipsoftFont

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 8

  CheckBox
    id: all
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    text: Open All
    tooltip: Opens all containers in main backpack.
    width: 90
    height: 15
    margin-top: 2
    margin-left: 3

  CheckBox
    id: purse
    anchors.left: prev.right
    anchors.bottom: parent.bottom
    text: Open Purse
    tooltip: Opens Store/Charm Purse
    width: 90
    height: 15
    margin-top: 2
    margin-left: 3

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
    margin-top: 15
]])

function findItemsInArray(t, tfind)
    local tArray = {}
    for x,v in pairs(t) do
        if type(v) == "table" then
            local aItem = t[x].item
            local aEnabled = t[x].enabled
                if aItem then
                    if tfind and aItem == tfind then
                        return x
                    elseif not tfind then
                        if aEnabled then
                            table.insert(tArray, aItem)
                        end
                    end
                end
            end
        end
    if not tfind then return tArray end
end

local lstBPs
function openBackpacks()
    if not storage[contPanelName].all then
         lstBPs = findItemsInArray(storage[contPanelName].list)
    end

    for _, container in pairs(g_game.getContainers()) do g_game.close(container) end
    schedule(1000, function()
        bpItem = getBack()
        if bpItem ~= nil then
            g_game.open(bpItem)
        end
    end)

    schedule(2000, function()
        local delay = 1

        local nextContainers = {}
        containers = getContainers()
        for i, container in pairs(g_game.getContainers()) do
            for i, item in ipairs(container:getItems()) do
                if item:isContainer() then
                    if item:isContainer() and storage[contPanelName].all or (lstBPs and table.contains(lstBPs,item:getId())) then
                        table.insert(nextContainers, item)
                    end
                end
            end
        end
        if #nextContainers > 0 then
            for i = 1, #nextContainers do
                schedule(delay, function()
                    g_game.open(nextContainers[i], nil)
                end)
                delay = delay + 250
            end
        end

        if storage[contPanelName].purse then
            schedule(delay+200, function()
                local item = getPurse()
                if item then
                    use(item)
                end
            end)
        end
    end)

end

rootWidget = g_ui.getRootWidget()
if rootWidget then
    contListWindow = UI.createWindow('ContListsWindow', rootWidget)
    contListWindow:hide()

    renameContui.editContList.onClick = function(widget)
        contListWindow:show()
        contListWindow:raise()
        contListWindow:focus()
    end

    renameContui.reopenCont.onClick = function(widget)
        openBackpacks()
    end

    renameContui.title:setOn(storage[contPanelName].enabled)
    renameContui.title.onClick = function(widget)
        storage[contPanelName].enabled = not storage[contPanelName].enabled
        widget:setOn(storage[contPanelName].enabled)
    end

    contListWindow.closeButton.onClick = function(widget)
        contListWindow:hide()
    end

    contListWindow.purse.onClick = function(widget)
        storage[contPanelName].purse = not storage[contPanelName].purse
        contListWindow.purse:setChecked(storage[contPanelName].purse)
    end
    contListWindow.purse:setChecked(storage[contPanelName].purse)

    contListWindow.all.onClick = function(widget)
        storage[contPanelName].all = not storage[contPanelName].all
        contListWindow.all:setChecked(storage[contPanelName].all)
        label.enabled:setTooltip(storage[contPanelName].all and 'Opens all containers in main backpack.' or 'Opens listed containers from main backpack.')
    end
    contListWindow.all:setChecked(storage[contPanelName].all)

    local refreshContNames = function(tFocus)
        local storageVal = storage[contPanelName].list
        if storageVal and #storageVal > 0 then
            for i, child in pairs(contListWindow.itemList:getChildren()) do
                child:destroy()
            end
            for _, entry in pairs(storageVal) do
                local label = g_ui.createWidget("BackpackName", contListWindow.itemList)
                label.onMouseRelease = function()
                    contListWindow.contId:setItemId(entry.item)
                    contListWindow.contName:setText(entry.value)
                end
                label.enabled.onClick = function(widget)
                    entry.enabled = not entry.enabled
                    label.enabled:setChecked(entry.enabled)
                    label.enabled:setTooltip(entry.enabled and 'Disable' or 'Enable')
                    label.enabled:setImageColor(entry.enabled and '#00FF00' or '#FF0000')
                end
                label.remove.onClick = function(widget)
                    table.removevalue(storage[contPanelName].list, entry)
                    label:destroy()
                end
                label.state:setChecked(entry.min)
                label.state.onClick = function(widget)
                    entry.min = not entry.min
                    label.state:setChecked(entry.min)
                    label.state:setColor(entry.min and '#00FF00' or '#FF0000')
                    label.state:setTooltip(entry.min and 'Open Minimised' or 'Do not minimise')
                end

                label:setText(entry.value)
                label.enabled:setChecked(entry.enabled)
                label.enabled:setTooltip(entry.enabled and 'Disable' or 'Enable')
                label.enabled:setImageColor(entry.enabled and '#00FF00' or '#FF0000')
                label.state:setColor(entry.min and '#00FF00' or '#FF0000')
                label.state:setTooltip(entry.min and 'Open Minimised' or 'Do not minimise')

                if tFocus and entry.item == tFocus then
                    tFocus = label
                end
            end
            if tFocus then contListWindow.itemList:focusChild(tFocus) end
        end
    end
    contListWindow.addItem.onClick = function(widget)
        local id = contListWindow.contId:getItemId()
        local trigger = contListWindow.contName:getText()

        if id > 100 and trigger:len() > 0 then
            local ifind = findItemsInArray(storage[contPanelName].list, id)
            if ifind then
                storage[contPanelName].list[ifind] = { item = id, value = trigger, enabled = storage[contPanelName].list[ifind].enabled, min = storage[contPanelName].list[ifind].min}
            else
                table.insert(storage[contPanelName].list, { item = id, value = trigger, enabled = true, min = false })
            end
            contListWindow.contId:setItemId(0)
            contListWindow.contName:setText('')
            contListWindow.contName:setColor('white')
            contListWindow.contName:setImageColor('#ffffff')
            contListWindow.contId:setImageColor('#ffffff')
            refreshContNames(id)
        else
            contListWindow.contId:setImageColor('red')
            contListWindow.contName:setImageColor('red')
            contListWindow.contName:setColor('red')
        end
    end
    refreshContNames()
end

onContainerOpen(function(container, previousContainer)
    if renameContui.title:isOn() then
        if not previousContainer then
            if not container.window then return end
            containerWindow = container.window
            containerWindow:setContentHeight(34)
            local storageVal = storage[contPanelName].list
            if storageVal and #storageVal > 0 then
                for _, entry in pairs(storageVal) do
                    if entry.enabled and string.find(container:getContainerItem():getId(), entry.item) then
                        if entry.min then
                            containerWindow:minimize()
                        end
                        containerWindow:setText(entry.value)
                    end
                end
            end
        end
    end
end)

openBackpacks()

-- Marcro for auto party, it seems it doesn't auto-invite on its own now.

addSeparator("separator")

local panelName = "autoParty"
local autopartyui = setupUI([[
Panel
  height: 38

  BotSwitch
    id: status
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    height: 18
    !text: tr('Auto Party')

  Button
    id: editPlayerList
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup

  Button
    id: ptLeave
    !text: tr('Leave Party')
    anchors.left: parent.left
    anchors.top: prev.bottom
    width: 86
    height: 17
    margin-top: 3
    color: #ee0000

  Button
    id: ptShare
    !text: tr('Share XP')
    anchors.left: prev.right
    anchors.top: prev.top
    margin-left: 5
    height: 17
    width: 86

  ]], parent)

g_ui.loadUIFromString([[
AutoPartyName < Label
  background-color: alpha
  text-offset: 2 0
  focusable: true
  height: 16

  $focus:
    background-color: #00000055

  Button
    id: remove
    !text: tr('x')
    anchors.right: parent.right
    margin-right: 15
    width: 15
    height: 15

AutoPartyListWindow < MainWindow
  !text: tr('Auto Party')
  size: 180 250
  @onEscape: self:hide()

  Label
    id: lblLeader
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.right: parent.right
    text-align: center
    !text: tr('Leader Name')

  TextEdit
    id: txtLeader
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: prev.bottom
    margin-top: 5

  Label
    id: lblParty
    anchors.left: parent.left
    anchors.top: prev.bottom
    anchors.right: parent.right
    margin-top: 5
    text-align: center
    !text: tr('Party List')

  TextList
    id: lstAutoParty
    anchors.top: prev.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 5
    margin-bottom: 5
    padding: 1
    height: 83
    vertical-scrollbar: AutoPartyListListScrollBar

  VerticalScrollBar
    id: AutoPartyListListScrollBar
    anchors.top: lstAutoParty.top
    anchors.bottom: lstAutoParty.bottom
    anchors.right: lstAutoParty.right
    step: 14
    pixels-scroll: true

  TextEdit
    id: playerName
    anchors.left: parent.left
    anchors.top: lstAutoParty.bottom
    margin-top: 5
    width: 120

  Button
    id: addPlayer
    !text: tr('+')
    anchors.right: parent.right
    anchors.left: prev.right
    anchors.top: prev.top
    margin-left: 3

  HorizontalSeparator
    id: separator
    anchors.right: parent.right
    anchors.left: parent.left
    anchors.bottom: closeButton.top
    margin-bottom: 8

  Button
    id: closeButton
    !text: tr('Close')
    font: cipsoftFont
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    size: 45 21
]])

if not storage[panelName] then
    storage[panelName] = {
        leaderName = 'Leader',
        autoPartyList = {},
        enabled = true,
    }
end

rootWidget = g_ui.getRootWidget()
if rootWidget then
    tcAutoParty = autopartyui.status

    autoPartyListWindow = UI.createWindow('AutoPartyListWindow', rootWidget)
    autoPartyListWindow:hide()

    autopartyui.editPlayerList.onClick = function(widget)
        autoPartyListWindow:show()
        autoPartyListWindow:raise()
        autoPartyListWindow:focus()
    end

    autopartyui.ptShare.onClick = function(widget)
        g_game.partyShareExperience(not player:isPartySharedExperienceActive())
    end

    autopartyui.ptLeave.onClick = function(widget)
        g_game.partyLeave()
    end

    autoPartyListWindow.closeButton.onClick = function(widget)
        autoPartyListWindow:hide()
    end

    if storage[panelName].autoPartyList and #storage[panelName].autoPartyList > 0 then
        for _, pName in ipairs(storage[panelName].autoPartyList) do
            local label = g_ui.createWidget("AutoPartyName", autoPartyListWindow.lstAutoParty)
            label.remove.onClick = function(widget)
                table.removevalue(storage[panelName].autoPartyList, label:getText())
                label:destroy()
            end
            label:setText(pName)
        end
    end
    autoPartyListWindow.addPlayer.onClick = function(widget)
        local playerName = autoPartyListWindow.playerName:getText()
        if playerName:len() > 0 and not (table.contains(storage[panelName].autoPartyList, playerName, true)
                or storage[panelName].leaderName == playerName) then
            table.insert(storage[panelName].autoPartyList, playerName)
            local label = g_ui.createWidget("AutoPartyName", autoPartyListWindow.lstAutoParty)
            label.remove.onClick = function(widget)
                table.removevalue(storage[panelName].autoPartyList, label:getText())
                label:destroy()
            end
            label:setText(playerName)
            autoPartyListWindow.playerName:setText('')
        end
    end

    autopartyui.status:setOn(storage[panelName].enabled)
    autopartyui.status.onClick = function(widget)
        storage[panelName].enabled = not storage[panelName].enabled
        widget:setOn(storage[panelName].enabled)
    end

    autoPartyListWindow.playerName.onKeyPress = function(self, keyCode, keyboardModifiers)
        if not (keyCode == 5) then
            return false
        end
        autoPartyListWindow.addPlayer.onClick()
        return true
    end

    autoPartyListWindow.playerName.onTextChange = function(widget, text)
        if table.contains(storage[panelName].autoPartyList, text, true) then
            autoPartyListWindow.addPlayer:setColor("#FF0000")
        else
            autoPartyListWindow.addPlayer:setColor("#FFFFFF")
        end
    end

    autoPartyListWindow.txtLeader.onTextChange = function(widget, text)
        storage[panelName].leaderName = text
    end
    autoPartyListWindow.txtLeader:setText(storage[panelName].leaderName)

    onTextMessage(function(mode, text)
        if tcAutoParty:isOn() then
            if mode == 20 then
                if text:find("has joined the party") then
                    local data = regexMatch(text, "([a-z A-Z-]*) has joined the party")[1][2]
                    if data then
                        if table.contains(storage[panelName].autoPartyList, data, true) then
                            if not player:isPartySharedExperienceActive() then
                                g_game.partyShareExperience(true)
                            end
                        end
                    end
                elseif text:find("has invited you") then
                    if player:getName():lower() == storage[panelName].leaderName:lower() then
                        return
                    end
                    local data = regexMatch(text, "([a-z A-Z-]*) has invited you")[1][2]
                    if data then
                        if storage[panelName].leaderName:lower() == data:lower() then
                            local leader = getCreatureByName(data, true)
                            if leader then
                                g_game.partyJoin(leader:getId())
                                return
                            end
                        end
                    end
                end
            end
        end
    end)

    onCreatureAppear(function(creature)
        if tcAutoParty:isOn() then
            if not creature:isPlayer() or creature == player then return end
            if creature:getName():lower() == storage[panelName].leaderName:lower() then
                if creature:getShield() == 1 then
                    g_game.partyJoin(creature:getId())
                    return
                end
            end
            if player:getName():lower() ~= storage[panelName].leaderName:lower() then return end
            if not table.contains(storage[panelName].autoPartyList, creature:getName(), true) then return end
            if creature:isPartyMember() or creature:getShield() == 2 then return end
            g_game.partyInvite(creature:getId())
        end
    end)
end

UI.Separator()
