--Name Space
QuickSlash = {}
local QS = QuickSlash

--Basic Info
QS.Name = "QuickSlash"
QS.Author = "@MelanAster"
QS.Version = "0.10"

--Setting
QS.Default = {
  CV = false,
  Command = {
    [HOTBAR_CATEGORY_QUICKSLOT_WHEEL] = {},
    [HOTBAR_CATEGORY_ALLY_WHEEL] = {},
    [HOTBAR_CATEGORY_MEMENTO_WHEEL] = {},
    [HOTBAR_CATEGORY_TOOL_WHEEL] = {},
    [HOTBAR_CATEGORY_EMOTE_WHEEL] = {},
  },
}

--[[ Structure
  [EntryIndex] = {
    name = "",
    icon = "",
    slash = "",
  }
--]]

--When Loaded
local function OnAddOnLoaded(eventCode, addonName)
  if addonName ~= QS.Name then return end
	EVENT_MANAGER:UnregisterForEvent(QS.Name, EVENT_ADD_ON_LOADED)
  
  --Get Account/Character Setting
  QS.AV = ZO_SavedVars:NewAccountWide("QuickSlash_Vars", 1, nil, QS.Default, GetWorldName())
  QS.CV = ZO_SavedVars:NewCharacterIdSettings("QuickSlash_Vars", 1, nil, QS.Default, GetWorldName())
  QS.SwitchSV()
  
  --Hook Wheels
  QS.HookWheel()
  
  --Menu
  QS.BuildMenu()
end

--Account/Character Setting
function QS.SwitchSV()
  if QS.CV.CV then
    QS.SV = QS.CV
  else
    QS.SV = QS.AV
  end
end

function QS.HookWheel()
  --PC Part
  local OldF = ZO_UtilityWheel_Shared.PopulateMenu
  ZO_UtilityWheel_Shared.PopulateMenu = function(Self)
    local Result = OldF(Self)
    local Category = QS.SV.Command[Self:GetHotbarCategory()]
    if Category then
      for EntryIndex, Content in ipairs(Category) do
        UTILITY_WHEEL_KEYBOARD.menu.entries[EntryIndex] = {
          name = Content.name,
          date = {name = Content.name, slotNum = EntryIndex},
          activeIcon = Content.icon,
          inactiveIcon = Content.icon,
          callback = function() QS.Execute(Content.slash) end,
        }
      end
    end
  end
  
  --Gamepad Part
end

-- /script QuickSlash.Execute()
function QS.Execute(Text)
  --Pretreatment
  Text = tostring(Text)
  local Args = {}
  string.gsub(Text, "[^%s]+", function(tep) table.insert(Args, tep) end)
  local Command = Args[1]
  table.remove(Args, 1)
  
  --Do
  if SLASH_COMMANDS[Command] then
    if Args[1] then
      SLASH_COMMANDS[Command](unpack(Args))
    else
      SLASH_COMMANDS[Command]("")
    end
  end
end

--Icon
QS.IconList = {
  
}

function QS.Icon2Text(Table)
  local Tep = {}
  for i = 1, #Table do
    Tep[i] = "|t32:32:"..Table[i].."|t"
  end
  return Tep
end

--Menu Part
local LAM = LibAddonMenu2
function QS.BuildMenu()
  --Panel Part
  local panelData = {
    type = "panel",
    name = QS.Name,
    displayName = QS.Name,
    author = QS.Author,
    version = QS.Version,
	}
	LAM:RegisterAddonPanel(QS.Name.."_Options", panelData)
  
  --Option Part
  local Category, EntryIndex, Icon
  local options = {
    {
    type = "checkbox",
    name = "",
    getFunc = function() return QS.CV.CV end,
    setFunc = function(var)
      QS.CV.CV = var
      QS.SwitchSV()
      
    end
    width = "full",
    },
    --Create QuickSlot
    {
    type = "header",
    name = "",
    },
    --Category
    {
    type = "dropdown",
    name = "",
    choices = {
      GetString(SI_HOTBARCATEGORY10),
      GetString(SI_HOTBARCATEGORY13),
      GetString(SI_HOTBARCATEGORY12),
      GetString(SI_HOTBARCATEGORY14),
      GetString(SI_HOTBARCATEGORY11),
    },
    choicesValues = {
      HOTBAR_CATEGORY_QUICKSLOT_WHEEL,
      HOTBAR_CATEGORY_ALLY_WHEEL,
      HOTBAR_CATEGORY_MEMENTO_WHEEL,
      HOTBAR_CATEGORY_TOOL_WHEEL,
      HOTBAR_CATEGORY_EMOTE_WHEEL,
    },
    getFunc = function() return HOTBAR_CATEGORY_QUICKSLOT_WHEEL end,
    setFunc = function(var) Category = var end,
    width = "half",
    },
    --Index
    {
    type = "dropdown",
    name = "",
    choices = {"↑", "↗", "→", "↘", "↓", "↙", "←", "↖"},
    choicesValues = {1, 2, 3, 4, 5, 6, 7, 8},
    getFunc = function() return 1 end,
    setFunc = function(var) EntryIndex = var end,
    width = "half",
    },
    --Icon Select
    {
    type = "dropdown",
    name = "",
    choices = QS.Icon2Text(QS.IconList),
    choicesValues = QS.IconList,
    getFunc = function() return end,
    setFunc = function(var) Icon = var end,
    width = "half",
    },
    
    --Icon Custom
    --Name
    --Slash
    --Check
    --Apply
    
    --Description
    --Delete 
    --Category
    --Index
    --Empty
    --Delete
  }
  LAM:RegisterOptionControls(QS.Name.."_Options", options)
end

-- Start Here
EVENT_MANAGER:RegisterForEvent(QS.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)