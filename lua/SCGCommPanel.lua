local AceGUI = LibStub("AceGUI-3.0")
local Main = SCGComms
local Me = {}

Main.CommPanel = Me

-------------------------------------------------------------------------------
-- attributes
-------------------------------------------------------------------------------
local pl_name = ""
local patrol_type = "clockwise"
local start_loc = ""
local dest_loc = ""
local current_loc = ""
local offense = ""

local w = {}

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
function Me:SendComm(comm_string)
  SendChatMessage(comm_string,"OFFICER" ,"COMMON")
end

function Me:BuildTimeString()
  local db = Main.db.char.patrol_comms
  local hours, minutes = GetGameTime();
  local time_string = hours..":"..minutes

  if Main.debug == true then
    print("Hours String Before 0: "..hours)
    print("Minutes String Before 0: "..minutes)
  end

  if hours < 10 then
    time_string = string.gsub(time_string, hours..":", "0"..hours..":")
  end

  if minutes < 10 then
     time_string = string.gsub(time_string, ":"..minutes, ":0"..minutes)
  end

  if Main.debug == true then
    print("Hours String After 0: "..hours)
    print("Minutes String After 0: "..minutes)
  end

  return time_string
end

function Me:SubValues(comm_string)
  time_string = Me:BuildTimeString()

  comm_string = comm_string:gsub("%[name%]", pl_name)
  comm_string = comm_string:gsub("%[patrol_direction%]", patrol_type)
  comm_string = comm_string:gsub("%[start_location%]", start_loc)
  comm_string = comm_string:gsub("%[dest_location%]", dest_loc)
  comm_string = comm_string:gsub("%[offense%]", offense)
  comm_string = comm_string:gsub("%[current_location%]", current_loc)
  comm_string = comm_string:gsub("%[time%]", time_string)

  return comm_string
end

function Me:ToggleGroups(flag, val)
  local enabled_group, disabled_group = Me:GetControlGroups(flag, val)

  for _, v in pairs(enabled_group) do
    w[v]:SetDisabled(false)
  end
  for _, v in pairs(disabled_group) do
    w[v]:SetDisabled(true)
  end
end

function Me:GetControlGroups(flag, val)
  local update_group = {
    "start_loc_dropdown_update",
    "dest_loc_dropdown_update",
    "update_patrol_button_update"
  }
  local describe_group = {
    "offense_dropdown",
    "assistance_checkbox",
    "update_patrol_button_describe",
    "current_loc_dropdown"
  }
  local start_group = {
    "start_patrol_button",
    "start_loc_dropdown_start"
  }
  local end_group = {
    "end_patrol_button",
    "dest_loc_dropdown_start",
    "clear_checkbox"
  }

  if flag == "clear_check" then
    if val == true then
      return update_group, describe_group
    else
      return describe_group, update_group
    end
  elseif flag == "start_end" then
    if val == true then
      for _, v in pairs(update_group) do
        table.insert(start_group, v)
      end
      return end_group, start_group
    else
      for _, v in pairs(update_group) do
        table.insert(end_group, v)
      end
      return start_group, end_group
    end
  end
end
-------------------------------------------------------------------------------
-- Events
-------------------------------------------------------------------------------
function Me:OnStartPatrolClicked()
  local db = Main.db.char.patrol_comms
  local comm_string = Me:SubValues(db.startPatrol)

  if Main.debug == true then
    print("Comm String: "..comm_string)
  else
    Me:SendComm(comm_string)
  end
  Me:ToggleGroups("start_end", true)
end

function Me:OnUpdatePatrolClicked()
  local db = Main.db.char.patrol_comms
  local clear_value = w["clear_checkbox"]:GetValue()
  local asst_value = w["assistance_checkbox"]:GetValue()
  local comm_string

  if clear_value == true then
    comm_string = Me:SubValues(db.updatePatrolClear)
  elseif asst_value == true then
    comm_string = Me:SubValues(db.updatePatrolAsst)
  else
    comm_string = Me:SubValues(db.updatePatrolOffense)
  end

  if Main.debug == true then
    print("Comm String: "..comm_string)
  else
    Me:SendComm(comm_string)
  end
end

function Me:OnEndPatrolClicked()
  local db = Main.db.char.patrol_comms
  local comm_string = Me:SubValues(db.endPatrol)
  w["assistance_checkbox"]:SetValue(false)
  w["clear_checkbox"]:SetValue(true)

  if Main.debug == true then
    print("Comm String: "..comm_string)
  else
    Me:SendComm(comm_string)
  end
  Me:ToggleGroups("start_end", false)
end

function Me:OnClearChanged(val)
  if Main.debug == true then
    print("OnClearChanged called.")
  end
  Me:ToggleGroups("clear_check", val)
end

function Me:OnClockwiseChanged(widget, val)
  if val == true and w["counter_clock_radio"]:GetValue() == true then
    w["counter_clock_radio"]:ToggleChecked()
    patrol_type = "clockwise"
  end
end

function Me:OnCounterChanged(widget, val)
  if val == true and w["clockwise_radio"]:GetValue() == true then
    w["clockwise_radio"]:ToggleChecked()
    patrol_type = "counter-clockwise"
  end
end
-------------------------------------------------------------------------------
-- Frame Constructor
-------------------------------------------------------------------------------
function Me:Show()
  Me:CommFrame()
end

function Me:CommFrame()
  local my_key = "comm_frame"
  w[my_key] = AceGUI:Create("Frame")
  w[my_key]:SetTitle("SWCG Comms")
  w[my_key]:SetWidth(420)
  w[my_key]:SetHeight(365)
  w[my_key]:SetLayout("Fill")
  Me:ScrollFrame(my_key)
end

function Me:ScrollFrame(parent_key)
  local my_key = "scroll_frame"
  w[my_key] = AceGUI:Create("ScrollFrame")
  w[my_key]:SetLayout("Flow")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetFullHeight(true)

  Me:LeaderName(my_key)
  Me:StartPatrolGroup(my_key)
  Me:UpdatePatrolGroup(my_key)
  Me:DescribePatrolGroup(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:StartPatrolGroup(parent_key)
  local my_key = "start_patrol_group"
  w[my_key] = AceGUI:Create("InlineGroup")
  w[my_key]:SetTitle("Start Patrol")
  w[my_key]:SetLayout("List")
  w[my_key]:SetFullWidth(true)

  Me:ClockRadioGroup(my_key)
  Me:StartBtnGroup(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:UpdatePatrolGroup(parent_key)
  local my_key = "update_patrol_group"
  w[my_key] = AceGUI:Create("InlineGroup")
  w[my_key]:SetTitle("Update Patrol")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetLayout("Flow")

  Me:StartLocDropdownUpdate(my_key)
  Me:DestLocDropdownUpdate(my_key)
  Me:ClearCheckBox(my_key)
  Me:UpdatePatrolBtnUpdate(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:DescribePatrolGroup(parent_key)
  local my_key = "describe_group"
  w[my_key] = AceGUI:Create("InlineGroup")
  w[my_key]:SetTitle("Describe the Situation")
  -- w[my_key]:SetWidth(350)
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetLayout("Flow")

  Me:OffenseDropdown(my_key)
  Me:CurrentLocationDropdown(my_key)
  Me:UpdatePatrolBtnGroup(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:StartBtnGroup(parent_key)
  local my_key = "start_btn_group"
  w[my_key] = AceGUI:Create("SimpleGroup")
  w[my_key]:SetLayout("Flow")
  w[my_key]:SetFullWidth(true)

  Me:StartLocDropdownStart(my_key)
  Me:DestLocDropdownStart(my_key)
  Me:StartPatrolBtn(my_key)
  Me:EndPatrolBtn(my_key)
  w[parent_key]:AddChild(w[my_key])
end

function Me:ClockRadioGroup(parent_key)
  local my_key = "clock_radio_group"
  w[my_key] = AceGUI:Create("SimpleGroup")
  w[my_key]:SetLayout("Flow")
  w[my_key]:SetFullWidth(true)

  Me:PatrolTypeText(my_key)
  Me:ClockwiseRadio(my_key)
  Me:CounterRadio(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:UpdatePatrolBtnGroup(parent_key)
  local my_key ="update_patrol_button_group"
  w[my_key] = AceGUI:Create("SimpleGroup")

  w[my_key]:SetLayout("Flow")
  w[my_key]:SetFullWidth(true)

  Me:UpdatePatrolBtnDescribe(my_key)
  Me:AssistanceCheckBox(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:LeaderName(parent_key) -- pl_name
  local my_key = "pl_name_editbox"
  w[my_key] = AceGUI:Create("EditBox")
  w[my_key]:SetLabel("Patrol Leader's Name:")
  w[my_key]:SetFullWidth(true)
  w[my_key]:DisableButton(true)
  w[my_key]:SetCallback("OnTextChanged",
      function(widget, event, text) pl_name = text end)
  w[parent_key]:AddChild(w[my_key])
end


function Me:PatrolTypeText(parent_key) -- label
  local my_key = "patrol_type_text"
  w[my_key] = AceGUI:Create("Label")
  w[my_key]:SetText("Select Patrol Type:")
  w[my_key]:SetFullWidth(true)

  w[parent_key]:AddChild(w[my_key])
end

function Me:ClockwiseRadio(parent_key)
  local my_key = "clockwise_radio"
  w[my_key] = AceGUI:Create("CheckBox")
  w[my_key]:SetLabel("Clockwise")
  w[my_key]:SetType("radio")
  w[my_key]:SetWidth(100)
  w[my_key]:ToggleChecked(true)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) Me:OnClockwiseChanged(widget, value) end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:CounterRadio(parent_key)
  local my_key = "counter_clock_radio"
  w[my_key] = AceGUI:Create("CheckBox")
  w[my_key]:SetLabel("Counter")
  w[my_key]:SetType("radio")
  w[my_key]:SetWidth(100)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) Me:OnCounterChanged(widget, value) end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:StartPatrolBtn(parent_key)
  local my_key = "start_patrol_button"
  w[my_key] = AceGUI:Create("Button")
  w[my_key]:SetText("Start Patrol")
  w[my_key]:SetWidth(110)

  w[my_key]:SetCallback("OnClick",
      function() Me:OnStartPatrolClicked() end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:EndPatrolBtn(parent_key)
  local my_key = "end_patrol_button"
  w[my_key] = AceGUI:Create("Button")
  w[my_key]:SetText("End Patrol")
  w[my_key]:SetWidth(110)
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnClick",
      function() Me:OnEndPatrolClicked() end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:StartLocDropdownUpdate(parent_key)
  local my_key = "start_loc_dropdown_update"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select Location")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Starting Location")
  w[my_key]:SetWidth(130)
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) start_loc = LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:StartLocDropdownStart(parent_key)
  local my_key = "start_loc_dropdown_start"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select Location")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Starting Location")
  w[my_key]:SetWidth(130)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) start_loc = LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:DestLocDropdownUpdate(parent_key)
  local my_key = "dest_loc_dropdown_update"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select Location")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Destination Location")
  w[my_key]:SetWidth(130)
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) dest_loc = LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:DestLocDropdownStart(parent_key)
  local my_key = "dest_loc_dropdown_start"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select Location")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Destination Location")
  w[my_key]:SetWidth(130)
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) dest_loc = LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:ClearCheckBox(parent_key)
  local my_key = "clear_checkbox"
  w[my_key] = AceGUI:Create("CheckBox")
  w[my_key]:SetLabel("Clear?")
  w[my_key]:SetWidth(75)
  w[my_key]:SetType("checkbox")
  w[my_key]:ToggleChecked(true)
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnValueChanged",
  function(widget, event, value) Me:OnClearChanged(value) end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:OffenseDropdown(parent_key)
  local my_key = "offense_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select Offense")
  w[my_key]:SetList(OFFENSES)
  w[my_key]:SetLabel("What offense are you investigating")
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) offense = OFFENSES[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:CurrentLocationDropdown(parent_key)
  local my_key = "current_loc_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select Location")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Current Location")
  w[my_key]:SetWidth(130)
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) current_loc = LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:AssistanceCheckBox(parent_key)
  local my_key = "assistance_checkbox"
  w[my_key] = AceGUI:Create("CheckBox")
  w[my_key]:SetLabel("Do You Require Assistance?")
  w[my_key]:SetType("checkbox")
  w[my_key]:SetDisabled(true)

  w[parent_key]:AddChild(w[my_key])
end

function Me:UpdatePatrolBtnUpdate(parent_key)
  local my_key = "update_patrol_button_update"
  w[my_key] = AceGUI:Create("Button")
  w[my_key]:SetText("Update Patrol")
  w[my_key]:SetWidth(110)
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnClick",
      function(widget, event, value) Me:OnUpdatePatrolClicked() end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:UpdatePatrolBtnDescribe(parent_key)
  local my_key = "update_patrol_button_describe"
  w[my_key] = AceGUI:Create("Button")
  w[my_key]:SetText("Update Patrol")
  w[my_key]:SetWidth(110)
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnClick",
      function(widget, event, value) Me:OnUpdatePatrolClicked() end)

  w[parent_key]:AddChild(w[my_key])
end
