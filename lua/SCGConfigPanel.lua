local AceGUI = LibStub("AceGUI-3.0")
local Main = SCGComms
local Me = {}

SCGComms.ConfigPanel = Me

-------------------------------------------------------------------------------
-- attributes
-------------------------------------------------------------------------------
local w = {}
local defaults = SCGComms_defaults

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
function Me:Show()
  Me:ConfigFrame()
end

function Me:Hide()
  w["config_frame"]:Hide()
end

function Me:ResetAccent()
  for k, v in pairs(Main.db.char.patrolComms) do
    Main.db.char.patrolComms[k] = defaults.char.patrolComms[k]
  end

  w["start_patrol_config"]:SetText(Main.db.char.patrolComms.startPatrol)
  w["update_patrol_clear_config"]:SetText(Main.db.char.patrolComms.updatePatrolClear)
  w["update_patrol_offense_config"]:SetText(Main.db.char.patrolComms.updatePatrolOffense)
  w["update_patrol_asst_config"]:SetText(Main.db.char.patrolComms.updatePatrolAsst)
  w["end_patrol_config"]:SetText(Main.db.char.patrolComms.endPatrol)
  w["emote_config"]:SetText(Main.db.char.patrolComms.emote)
end

function Me:OpenDebugger()
  if Main.DebugPanel.GetOpen() == false then
    Main.DebugPanel.Show()
    w["config_frame"]:SetStatusText("Debugger Opened.")
  else
    w["config_frame"]:SetStatusText("Debugger Panel Already Open!")
  end
end

-------------------------------------------------------------------------------
-- Constructor Functions
-------------------------------------------------------------------------------
function Me:ConfigFrame()
  local my_key = "config_frame"
  w[my_key] = AceGUI:Create("Frame")
  w[my_key]:SetTitle("SWCG Comms Config")
  w[my_key]:SetWidth(420)
  w[my_key]:SetHeight(530)
  w[my_key]:SetLayout("List")

  Main.ConfigFrame = w[my_key]
  Me:ScrollFrame(my_key)

  w[my_key]:SetCallback("OnClose", function() Main.ConfigFrame = nil end)
end

function Me:ScrollFrame(parent_key)
  local my_key = "scroll_frame"
  w[my_key] = AceGUI:Create("ScrollFrame")
  w[my_key]:SetLayout("Flow")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetFullHeight(true)

  Me:ConfigTextGroup(my_key)
  Me:ConfigBoxGroup(my_key)
  Me:ResetAccentButton(my_key)
  Me:DebuggerButton(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:ConfigTextGroup(parent_key)
  local my_key = "config_text_group"
  w[my_key] = AceGUI:Create("InlineGroup")
  w[my_key]:SetTitle("How to Use:")
  w[my_key]:SetFullWidth(true)

  Me:ConfigText(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:ConfigBoxGroup(parent_key)
  local my_key = "config_box_group"
  w[my_key] = AceGUI:Create("InlineGroup")
  w[my_key]:SetTitle("Character Accents:")
  w[my_key]:SetFullWidth(true)

  Me:StartPatrolConfig(my_key)
  Me:UpdatePatrolClearConfig(my_key)
  Me:UpdatePatrolOffenseConfig(my_key)
  Me:UpdatePatrolAsstConfig(my_key)
  Me:EndPatrolConfig(my_key)
  Me:EmoteConfig(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:ConfigText(parent_key)
  local my_key = "config_text"
  w[my_key] = AceGUI:Create("Label")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetText(
  "This panel lets you change how your character ICly speaks over the comms."..
  " ".."There are five messages: Starting a patrol; ending a patrol;".." "..
  "updating that the patrol has cleared a location; updating that the".." "..
  "patrol is handling an offense, with no backup required; and updating".." "..
  "that the patrol requires backup while handling an offense. You may".." "..
  "use the following tags to customize each response:\n\n"..
  "[rank] [name] [patrol_direction] [start_location] [end_location]".." "..
  "[current_location] [next_location] and [time]\n\n"..
  "Also, there is a checkbox for you to disable the comm so you".." "..
  "may test your responses without spamming the comm with actual messages."
  )

  w[parent_key]:AddChild(w[my_key])
end

function Me:StartPatrolConfig(parent_key)
  local my_key = "start_patrol_config"
  w[my_key] = AceGUI:Create("EditBox")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetLabel("Start Patrol")
  w[my_key]:SetText(Main.db.char.patrolComms.startPatrol)

  w[my_key]:SetCallback("OnEnterPressed",
      function(widget, event, text)
        Main.db.char.patrolComms.startPatrol = text
        w["config_frame"]:SetStatusText("Start Patrol updated successfully.")
      end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:UpdatePatrolClearConfig(parent_key)
  local my_key = "update_patrol_clear_config"
  w[my_key] = AceGUI:Create("EditBox")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetLabel("Update Patrol is clear:")
  w[my_key]:SetText(Main.db.char.patrolComms.updatePatrolClear)

  w[my_key]:SetCallback("OnEnterPressed",
      function(widget, event, text)
        Main.db.char.patrolComms.updatePatrolClear = text
        w["config_frame"]:SetStatusText("Update Patrol clear updated successfully.")
      end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:UpdatePatrolOffenseConfig(parent_key)
  local my_key = "update_patrol_offense_config"
  w[my_key] = AceGUI:Create("EditBox")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetLabel("Update Patrol handling a situation, assistance not required:")
  w[my_key]:SetText(Main.db.char.patrolComms.updatePatrolOffense)

  w[my_key]:SetCallback("OnEnterPressed",
      function(widget, event, text)
        Main.db.char.patrolComms.updatePatrolOffense = text
        w["config_frame"]:SetStatusText("Update Patrol w/ offense updated successfully.")
      end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:UpdatePatrolAsstConfig(parent_key)
  local my_key = "update_patrol_asst_config"
  w[my_key] = AceGUI:Create("EditBox")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetLabel("Update Patrol handling a situation, assistance required:")
  w[my_key]:SetText(Main.db.char.patrolComms.updatePatrolAsst)

  w[my_key]:SetCallback("OnEnterPressed",
      function(widget, event, text)
        Main.db.char.patrolComms.updatePatrolAsst = text
        w["config_frame"]:SetStatusText("Update Patrol w/ assistance updated successfully.")
      end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:EndPatrolConfig(parent_key)
  local my_key = "end_patrol_config"
  w[my_key] = AceGUI:Create("EditBox")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetLabel("End patrol:")
  w[my_key]:SetText(Main.db.char.patrolComms.endPatrol)

  w[my_key]:SetCallback("OnEnterPressed",
      function(widget, event, text)
        Main.db.char.patrolComms.endPatrol = text
        w["config_frame"]:SetStatusText("End Patrol updated successfully.")
      end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:EnableCommCheck(parent_key)
  local my_key = "enable_comm_checkbox"
  w[my_key] = AceGUI:Create("CheckBox")
  w[my_key]:SetLabel("Enable Comms")
  w[my_key]:ToggleChecked(Main.db.char.patrolComms.enabled)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) Me:ToggleComms(value) end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:EmoteConfig(parent_key)
  local my_key = "emote_config"
  w[my_key] = AceGUI:Create("EditBox")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetLabel("/e emote when updating patrol")
  w[my_key]:SetText(Main.db.char.patrolComms.emote)

  w[my_key]:SetCallback("OnEnterPressed",
      function(widget, event, text)
        Main.db.char.patrolComms.emote = text
        w["config_frame"]:SetStatusText("Emote updated successfully.")
      end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:ResetAccentButton(parent_key)
  local my_key = "reset_accent_button"
  w[my_key] = AceGUI:Create("Button")
  w[my_key]:SetText("Reset Accent")
  w[my_key]:SetWidth(130)

  w[my_key]:SetCallback("OnClick",
      function() Me:ResetAccent() end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:DebuggerButton(parent_key)
  local my_key = "debugger_button"
  w[my_key] = AceGUI:Create("Button")
  w[my_key]:SetText("Open Debugger")
  w[my_key]:SetWidth(130)

  w[my_key]:SetCallback("OnClick",
      function() Me:OpenDebugger() end)

  w[parent_key]:AddChild(w[my_key])
end
