local AceGUI = LibStub("AceGUI-3.0")
local Main = SCGComms
local Me = {}

SCGComms.ConfigPanel = Me

-------------------------------------------------------------------------------
-- attributes
-------------------------------------------------------------------------------
local w
local defaults = SCGComms_defaults

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
function Me:Show()
  Me:BuildPanel()
end

function Me:Hide()
  w["config_frame"]:Hide()
end

function Me:UpdateDB(widget)
  text = widget:GetText()
  if string.match(text, "%[name%]") then
    Main.db.char.patrol_comms.patrolIntro = text
    w["config_frame"]:SetStatusText("Patrol Name updated successfully!")
  elseif string.match(text, "%[start_loc%]") then
    Main.db.char.patrol_comms.clearSignal = text
    w["config_frame"]:SetStatusText("Clear Signal updated successfully!")
  elseif string.match(text, "%[dest_loc%]") then
    Main.db.char.patrol_comms.enrouteTo = text
    w["config_frame"]:SetStatusText("Destination updated successfully!")
  else
    w["config_frame"]:SetStatusText("Problem updating. Be sure to include the [] brackets.")
  end
end

function Me:ResetAccent()
  for k, v in pairs(Main.db.char.patrol_comms) do
    Main.db.char.patrol_comms[k] = defaults.char.patrol_comms[k]
  end

  w["pl_config_editbox"]:SetText(Main.db.char.patrol_comms.patrolIntro)
  w["clear_config_editbox"]:SetText(Main.db.char.patrol_comms.clearSignal)
  w["enrouteto_config_editbox"]:SetText(Main.db.char.patrol_comms.enrouteTo)
end
-------------------------------------------------------------------------------
-- Constructor Functions
-------------------------------------------------------------------------------
function Me:BuildPanel()
  Me:CreateFrames()
  Me:SetLayouts()
  Me:AddChildren()
  Me:RegisterCallbacks()
end

function Me:CreateFrames()
  local w_group = {
    config_frame = AceGUI:Create("Frame"),
    patrol_config_group = AceGUI:Create("InlineGroup"),
    patrol_config_string = AceGUI:Create("Label"),
    pl_config_editbox = AceGUI:Create("EditBox"),
    clear_config_editbox = AceGUI:Create("EditBox"),
    enrouteto_config_editbox = AceGUI:Create("EditBox"),
    reset_accent_button = AceGUI:Create("Button")
  }

  w = w_group
end

function Me:SetLayouts()
  w["config_frame"]:SetTitle("SWCG Comms Config")
  w["config_frame"]:SetWidth(400)
  w["config_frame"]:SetLayout("List")

  w["patrol_config_string"]:SetText(
  "This is an area for you to customize SWCG Comms to how your character ICly"..
  " speaks. you may use brackets: [] to include what would be in the comm,"..
  " As in: \"[name]'s patrol.\" or \"[start_loc] clear\". The values"..
  "for each are shown in the field itself."
  )
  w["patrol_config_string"]:SetFullWidth(true)

  w["patrol_config_group"]:SetTitle("General Patrol Accent")
  w["patrol_config_group"]:SetFullWidth(true)

  w["pl_config_editbox"]:SetLabel("Patrol Name:")
  w["pl_config_editbox"]:SetText(Main.db.char.patrol_comms.patrolIntro)
  w["pl_config_editbox"]:SetFullWidth(true)

  w["clear_config_editbox"]:SetLabel("Clear Signal:")
  w["clear_config_editbox"]:SetText(Main.db.char.patrol_comms.clearSignal)
  w["clear_config_editbox"]:SetFullWidth(true)

  w["enrouteto_config_editbox"]:SetLabel("Destination:")
  w["enrouteto_config_editbox"]:SetText(Main.db.char.patrol_comms.enrouteTo)
  w["enrouteto_config_editbox"]:SetFullWidth(true)

  w["reset_accent_button"]:SetText("Reset Accent")

end

function Me:AddChildren()
  w["config_frame"]:AddChild(w["patrol_config_string"])
  w["config_frame"]:AddChild(w["patrol_config_group"])
  w["patrol_config_group"]:AddChild(w["pl_config_editbox"])
  w["patrol_config_group"]:AddChild(w["clear_config_editbox"])
  w["patrol_config_group"]:AddChild(w["enrouteto_config_editbox"])
  w["patrol_config_group"]:AddChild(w["reset_accent_button"])
end

function Me:RegisterCallbacks()
  w["pl_config_editbox"]:SetCallback("OnEnterPressed",
    function(widget) Me:UpdateDB(widget) end)
  w["clear_config_editbox"]:SetCallback("OnEnterPressed",
    function(widget) Me:UpdateDB(widget) end)
  w["enrouteto_config_editbox"]:SetCallback("OnEnterPressed",
    function(widget) Me:UpdateDB(widget) end)
  w["reset_accent_button"]:SetCallback("OnClick",
    function() Me:ResetAccent() end)
end
