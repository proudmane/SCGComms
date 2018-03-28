local AceGUI = LibStub("AceGUI-3.0")
local Main = SCGComms
local Me = {}

Main.CommPanel = Me

-------------------------------------------------------------------------------
-- attributes
-------------------------------------------------------------------------------
local pl_name = ""
local rank = ""
local patrol_type = "clockwise"
local start_loc = ""
local end_loc = ""
local dest_loc = ""
local current_loc = ""
local offense = ""
local enabled = true

local w = {}

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
function Me:SendComm(comm_string)
  if enabled == true then
    SendChatMessage(comm_string,"OFFICER" ,"COMMON")
  else
    print("Comm String: "..comm_string)
  end
end

function Me:BuildTimeString()
  local db = Main.db.char.patrolComms
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
  comm_string = comm_string:gsub("%[rank%]", rank)
  comm_string = comm_string:gsub("%[patrol_direction%]", patrol_type)
  comm_string = comm_string:gsub("%[start_location%]", start_loc)
  comm_string = comm_string:gsub("%[end_location%]", end_loc)
  comm_string = comm_string:gsub("%[next_location%]", dest_loc)
  comm_string = comm_string:gsub("%[offense%]", offense)
  comm_string = comm_string:gsub("%[current_location%]", current_loc)
  comm_string = comm_string:gsub("%[time%]", time_string)

  return comm_string
end

function Me:ToggleGroups(group, val)
  for _, v in pairs(group) do
    w[v]:SetDisabled(val)
  end
end

function Me:ClearAttrs()
  pl_name = ""
  rank = ""
  start_loc = ""
  end_loc = ""
  dest_loc = ""
  current_loc = ""
  offense = ""

  local dropdowns = {
    "start_loc_dropdown", "end_loc_dropdown",
    "current_loc_dropdown", "next_loc_dropdown", "offense_dropdown",
    "current_loc_dropdown_desc", "rank_dropdown"
  }
  for _, v in pairs(dropdowns) do
    w[v]:SetValue(nil)
    w[v]:SetText("Select...")
  end
  w["pl_name_editbox"]:SetText(pl_name)
end

function Me:ToggleComms(value)
  enabled = value
  if value == true then
    w["comm_frame"]:SetStatusText("SWCG Comm Unit Enabled")
  else
    w["comm_frame"]:SetStatusText("SWCG Comm Unit Disabled.")
  end
end
-------------------------------------------------------------------------------
-- Events
-------------------------------------------------------------------------------
function Me:OnStartPatrolClicked(widget)
  if pl_name == "" then
    w["comm_frame"]:SetStatusText("Please enter a vlid PL name.")
  elseif start_loc == "" then
    w["comm_frame"]:SetStatusText("Please enter your starting location.")
  else
    local db = Main.db.char.patrolComms
    local comm_string = Me:SubValues(db.startPatrol)

    if Main.debug == true then
      print("Comm String: "..comm_string)
    else
      Me:SendComm(comm_string)
    end
    local start_group = {
      "start_patrol_button", "start_loc_dropdown",
    }
    local end_group = {
      "end_patrol_button", "end_loc_dropdown", "current_loc_dropdown",
      "next_loc_dropdown", "update_patrol_button_update", "clear_checkbox"
    }
    if patrol_type == "clockwise" then
      w["current_loc_dropdown"]:SetValue(w["start_loc_dropdown"]:GetValue())
      current_loc = start_loc
      local loc_value = (w["current_loc_dropdown"]:GetValue() + 1)
      w["next_loc_dropdown"]:SetValue(loc_value)
      dest_loc = LOCATIONS[loc_value]
    elseif patrol_type == "counter-clockwise" then
      w["current_loc_dropdown"]:SetValue(w["start_loc_dropdown"]:GetValue())
      current_loc = start_loc
      local loc_value = (w["current_loc_dropdown"]:GetValue() - 1)
      if loc_value == 0 then
        loc_value = NUM_LOCATIONS
      end
      w["next_loc_dropdown"]:SetValue(loc_value)
      dest_loc = LOCATIONS[loc_value]
    end

    w["end_loc_dropdown"]:SetValue(w["start_loc_dropdown"]:GetValue())
    w["end_loc_dropdown"]:SetText(start_loc)
    Me:ToggleGroups(start_group, true)
    Me:ToggleGroups(end_group, false)
  end
end

function Me:OnUpdatePatrolClicked()
  if pl_name == "" then
    w["comm_frame"]:SetStatusText("Please enter a vlid PL name.")
  elseif current_loc == "" then
    w["comm_frame"]:SetStatusText("Please enter your current location.")
  elseif dest_loc == "" then
    w["comm_frame"]:SetStatusText("Please enter your next location.")
  else
    local db = Main.db.char.patrolComms
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
    if patrol_type == "clockwise" then
      local current_value = w["next_loc_dropdown"]:GetValue()
      local next_value = w["next_loc_dropdown"]:GetValue() + 1
      if current_value == NUM_LOCATIONS then
        next_value = 1
      end
      w["current_loc_dropdown"]:SetValue(current_value)
      current_loc = LOCATIONS[current_value]
      w["next_loc_dropdown"]:SetValue(next_value)
      dest_loc = LOCATIONS[next_value]
    elseif patrol_type == "counter-clockwise" then
      local current_value = w["current_loc_dropdown"]:GetValue() - 1
      local next_value = current_value - 1
      if w["current_loc_dropdown"]:GetValue() == 1 then
        current_value = NUM_LOCATIONS
        next_value = NUM_LOCATIONS - 1
      end
      if current_value == 1 then
        next_value = NUM_LOCATIONS
      end
      w["current_loc_dropdown"]:SetValue(current_value)
      current_loc = LOCATIONS[current_value]
      w["next_loc_dropdown"]:SetValue(next_value)
      dest_loc = LOCATIONS[next_value]
    end
    w["end_loc_dropdown"]:SetValue(w["current_loc_dropdown"]:GetValue())
    w["end_loc_dropdown"]:SetText(current_loc)
  end
end

function Me:OnUpdatePatrolDescribeClicked()
  if pl_name == "" then
    w["comm_frame"]:SetStatusText("Please enter a vlid PL name.")
  elseif current_loc == "" then
    w["comm_frame"]:SetStatusText("Please enter your current location.")
  elseif offense == "" then
    w["comm_frame"]:SetStatusText("Please enter your the offense you're handling.")
  else
    local db = Main.db.char.patrolComms
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
    w["comm_frame"]:SetStatusText("")
  end
end

function Me:OnEndPatrolClicked()
  if pl_name == "" then
    w["comm_frame"]:SetStatusText("Please enter a vlid PL name.")
  elseif end_loc == "" then
    w["comm_frame"]:SetStatusText("Please enter your ending location.")
  else
    local db = Main.db.char.patrolComms
    local comm_string = Me:SubValues(db.endPatrol)
    w["assistance_checkbox"]:SetValue(false)
    w["clear_checkbox"]:SetValue(true)

    if Main.debug == true then
      print("Comm String: "..comm_string)
    else
      Me:SendComm(comm_string)
    end
    local start_group = {
      "start_patrol_button", "start_loc_dropdown", "pl_name_editbox",
      "rank_dropdown"
    }
    local end_group = {
      "end_patrol_button", "end_loc_dropdown", "current_loc_dropdown",
      "next_loc_dropdown", "update_patrol_button_update", "clear_checkbox",
      "offense_dropdown", "assistance_checkbox", "update_patrol_button_describe",
      "current_loc_dropdown_desc"
    }
    Me:ClearAttrs()
    Me:ToggleGroups(start_group, false)
    Me:ToggleGroups(end_group, true)
  end
end

function Me:OnClearChanged(val)
  if Main.debug == true then
    print("OnClearChanged called.")
  end

  local update_group = {
    "current_loc_dropdown",
    "next_loc_dropdown",
    "update_patrol_button_update"
  }
  local describe_group = {
    "offense_dropdown",
    "assistance_checkbox",
    "update_patrol_button_describe",
    "current_loc_dropdown_desc"
  }

  if val == true then
    Me:ToggleGroups(update_group, false)
    Me:ToggleGroups(describe_group, true)
    w["current_loc_dropdown_desc"]:SetValue(nil)
    w["current_loc_dropdown_desc"]:SetText("Select...")
  else
    Me:ToggleGroups(update_group, true)
    Me:ToggleGroups(describe_group, false)
    w["current_loc_dropdown_desc"]:SetValue(w["current_loc_dropdown"]:GetValue())
  end
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
  w[my_key]:SetWidth(Main.db.char.commPanelDimensions.x)
  w[my_key]:SetHeight(Main.db.char.commPanelDimensions.y)
  w[my_key]:SetLayout("Fill")

  w[my_key]:SetCallback("OnClose", function() Main.CommFrame = nil end)

  Main.CommFrame = w[my_key]
  Me:ScrollFrame(my_key)
end

function Me:ScrollFrame(parent_key)
  local my_key = "scroll_frame"
  w[my_key] = AceGUI:Create("ScrollFrame")
  w[my_key]:SetLayout("Flow")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetFullHeight(true)

  Me:NameRankGroup(my_key)
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

  Me:CurrentLocationDropdown(my_key)
  Me:NextLocDropdown(my_key)
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
  Me:CurrentLocationDropdownDescribe(my_key)
  Me:UpdatePatrolBtnGroup(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:StartBtnGroup(parent_key)
  local my_key = "start_btn_group"
  w[my_key] = AceGUI:Create("SimpleGroup")
  w[my_key]:SetLayout("Flow")
  w[my_key]:SetFullWidth(true)

  Me:StartLocDropdown(my_key)
  Me:EndLocDropdown(my_key)
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
  Me:EnableCommCheck(my_key)

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

function Me:NameRankGroup(parent_key)
  local my_key = "name_rank_group"
  w[my_key] = AceGUI:Create("SimpleGroup")

  w[my_key]:SetLayout("Flow")
  w[my_key]:SetFullWidth(true)

  Me:RankDropdown(my_key)
  Me:LeaderName(my_key)
  w[parent_key]:AddChild(w[my_key])
end

function Me:LeaderName(parent_key) -- pl_name
  local my_key = "pl_name_editbox"
  w[my_key] = AceGUI:Create("EditBox")
  w[my_key]:SetLabel("Leader Name")
  w[my_key]:SetWidth(Main.db.char.commPanelDimensions.x - 210)
  w[my_key]:DisableButton(true)
  w[my_key]:SetCallback("OnTextChanged",
      function(widget, event, text) pl_name = text end)
  w[parent_key]:AddChild(w[my_key])
end

function Me:RankDropdown(parent_key)
  local my_key = "rank_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetWidth(130)
  w[my_key]:SetText("Select...")
  w[my_key]:SetList(RANKS)
  w[my_key]:SetLabel("Leader Rank")

  w[my_key]:SetCallback("OnValueChanged",
    function(widget, event, value) rank = RANKS[value] end)

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
      function(widget) Me:OnStartPatrolClicked(widget) end)

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

function Me:EnableCommCheck(parent_key)
  local my_key = "enable_comm_checkbox"
  w[my_key] = AceGUI:Create("CheckBox")
  w[my_key]:SetLabel("Enable Comms")
  w[my_key]:SetWidth(120)
  w[my_key]:ToggleChecked(Main.db.char.patrolComms.enabled)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) Me:ToggleComms(value) end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:StartLocDropdown(parent_key)
  local my_key = "start_loc_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select...")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Start Location")
  w[my_key]:SetWidth(130)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) start_loc = LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:NextLocDropdown(parent_key)
  local my_key = "next_loc_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select...")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Next Location")
  w[my_key]:SetWidth(130)
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) dest_loc = LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:EndLocDropdown(parent_key)
  local my_key = "end_loc_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select...")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("End Location")
  w[my_key]:SetWidth(130)
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) end_loc = LOCATIONS[value] end)

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
  w[my_key]:SetText("Select...")
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
  w[my_key]:SetText("Select...")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Current Location")
  w[my_key]:SetWidth(130)
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) current_loc = LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:CurrentLocationDropdownDescribe(parent_key)
  local my_key = "current_loc_dropdown_desc"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select...")
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
      function(widget, event, value) Me:OnUpdatePatrolDescribeClicked() end)

  w[parent_key]:AddChild(w[my_key])
end
