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
local gender
local all_loc_dropdowns = {
  "start_loc_dropdown", "end_loc_dropdown", "current_loc_dropdown",
  "next_loc_dropdown", "current_loc_dropdown_desc"
}

if UnitSex("player") == 2 then
  gender = "his"
else
  gender = "her"
end

local w = {}

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
function Me:SendComm(comm_string)
  if enabled == true then
    local emote = Me:SubValues(Main.db.char.patrolComms.emote)
    C_Club.SendMessage("345393461", "1", comm_string)
    SendChatMessage(emote, "EMOTE", nil, nil)
  else
    print("Comm String: "..comm_string)
  end
end

function Me:BuildTimeString()
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

  comm_string = comm_string:gsub("%[name%]", Main.db.char.patrolInfo.pl_name)
  comm_string = comm_string:gsub("%[rank%]", Main.db.char.patrolInfo.rank)
  comm_string = comm_string:gsub("%[patrol_direction%]", Main.db.char.patrolInfo.patrol_type)
  comm_string = comm_string:gsub("%[start_location%]", Main.db.char.patrolInfo.start_loc)
  comm_string = comm_string:gsub("%[end_location%]", Main.db.char.patrolInfo.end_loc)
  comm_string = comm_string:gsub("%[next_location%]", Main.db.char.patrolInfo.dest_loc)
  comm_string = comm_string:gsub("%[offense%]", Main.db.char.patrolInfo.offense)
  comm_string = comm_string:gsub("%[current_location%]", Main.db.char.patrolInfo.current_loc)
  comm_string = comm_string:gsub("%[time%]", time_string)
  comm_string = comm_string:gsub("%[gender%]", gender)

  return comm_string
end

function Me:ToggleGroups(group, val)
  for _, v in pairs(group) do
    w[v]:SetDisabled(val)
  end
end

function Me:ClearAttrs()
  Main.db.char.patrolInfo = SCGComms_defaults.char.patrolInfo

  LOCATIONS = ORIG_LOCATIONS

  local dropdowns = {
    "start_loc_dropdown", "end_loc_dropdown",
    "current_loc_dropdown", "next_loc_dropdown", "offense_dropdown",
    "current_loc_dropdown_desc", "rank_dropdown"
  }
  for _, v in pairs(dropdowns) do
    w[v]:SetValue(nil)
    w[v]:SetText("Select...")
    if v ~= "rank_dropdown" then
      w[v]:SetList(LOCATIONS)
    end
  end
  w["pl_name_editbox"]:SetText(Main.db.char.patrolInfo.pl_name)
  w["optional_lamb_check"]:SetValue(Main.db.char.patrolInfo.optional_locs["lamb"])
  w["optional_harbor_check"]:SetValue(Main.db.char.patrolInfo.optional_locs["harbor"])
  w["optional_graveyard_check"]:SetValue(Main.db.char.patrolInfo.optional_locs["gy"])
end

function Me:ToggleComms(value)
  enabled = value
  if value == true then
    w["comm_frame"]:SetStatusText("SWCG Comm Unit Enabled")
  else
    w["comm_frame"]:SetStatusText("SWCG Comm Unit Disabled.")
  end
end

function Me:AddLamb()
  local index = SCGComms:LocationsIndex()
  table.insert(LOCATIONS, index["Blue Recluse"] + 1, "Slaughtered Lamb")
  Main.db.char.patrolInfo.optional_locs["lamb"] = true
  for _, v in pairs(all_loc_dropdowns) do
    w[v]:SetList(LOCATIONS)
  end
end

function Me:RemoveLamb()
  local index = SCGComms:LocationsIndex()
  table.remove(LOCATIONS, index["Slaughtered Lamb"])
  Main.db.char.patrolInfo.optional_locs["lamb"] = false
  for _, v in pairs(all_loc_dropdowns) do
    w[v]:SetList(LOCATIONS)
  end
end

function Me:AddHarbor()
  local index = SCGComms:LocationsIndex()
  table.insert(LOCATIONS, index["Lion's Rest"] + 1, "Harbor")
  Main.db.char.patrolInfo.optional_locs["harbor"] = true
  for _, v in pairs(all_loc_dropdowns) do
    w[v]:SetList(LOCATIONS)
  end
end

function Me:RemoveHarbor()
  local index = SCGComms:LocationsIndex()
  table.remove(LOCATIONS, index["Harbor"])
  Main.db.char.patrolInfo.optional_locs["harbor"] = false
  for _, v in pairs(all_loc_dropdowns) do
    w[v]:SetList(LOCATIONS)
  end
end

function Me:AddGraveyard()
  local index = SCGComms:LocationsIndex()
  table.insert(LOCATIONS, index["Cathedral Square"], "Graveyard")
  Main.db.char.patrolInfo.optional_locs["gy"] = true
  for _, v in pairs(all_loc_dropdowns) do
    w[v]:SetList(LOCATIONS)
  end
end

function Me:RemoveGraveyard()
  local index = SCGComms:LocationsIndex()
  table.remove(LOCATIONS, index["Graveyard"])
  Main.db.char.patrolInfo.optional_locs["gy"] = false
  for _, v in pairs(all_loc_dropdowns) do
    w[v]:SetList(LOCATIONS)
  end
end
-------------------------------------------------------------------------------
-- Events
-------------------------------------------------------------------------------
function Me:OnStartPatrolClicked(widget)
  if Main.db.char.patrolInfo.pl_name == "" then
    w["comm_frame"]:SetStatusText("Please enter a valid PL name.")
  elseif Main.db.char.patrolInfo.start_loc == "" then
    w["comm_frame"]:SetStatusText("Please enter your starting location.")
  else
    w["comm_frame"]:SetStatusText("Comm Sent Successfully!")
    local comm_string = Me:SubValues(Main.db.char.patrolComms.startPatrol)
    Main.db.char.patrolInfo.inProgress = true;

    if Main.debug == true then
      print("Comm String: "..comm_string)
    else
      Me:SendComm(comm_string)
    end

    local start_group = {
      "start_patrol_button", "start_loc_dropdown",
    }
    local end_group = {
      "end_patrol_button", "end_loc_dropdown",
    }

    if Main.db.char.patrolInfo.patrol_type == "clockwise" then
      w["current_loc_dropdown"]:SetValue(w["start_loc_dropdown"]:GetValue())
      Main.db.char.patrolInfo.current_loc = Main.db.char.patrolInfo.start_loc
      local loc_value = (w["current_loc_dropdown"]:GetValue() + 1)
      w["next_loc_dropdown"]:SetValue(loc_value)
      Main.db.char.patrolInfo.dest_loc = LOCATIONS[loc_value]
    elseif Main.db.char.patrolInfo.patrol_type == "counter-clockwise" then
      w["current_loc_dropdown"]:SetValue(w["start_loc_dropdown"]:GetValue())
      Main.db.char.patrolInfo.current_loc = Main.db.char.patrolInfo.start_loc
      local loc_value = (w["current_loc_dropdown"]:GetValue() - 1)
      if loc_value == 0 then
        loc_value = SCGComms:NumLocations()
      end
      w["next_loc_dropdown"]:SetValue(loc_value)
      Main.db.char.patrolInfo.dest_loc = LOCATIONS[loc_value]
    end

    w["end_loc_dropdown"]:SetValue(w["start_loc_dropdown"]:GetValue())
    w["end_loc_dropdown"]:SetText(Main.db.char.patrolInfo.start_loc)
    Main.db.char.patrolInfo.end_loc = Main.db.char.patrolInfo.start_loc
  end
end

function Me:OnUpdatePatrolClicked()
  if Main.db.char.patrolInfo.pl_name == "" then
    w["comm_frame"]:SetStatusText("Please enter a valid PL name.")
  elseif Main.db.char.patrolInfo.current_loc == "" then
    w["comm_frame"]:SetStatusText("Please enter your current location.")
  elseif Main.db.char.patrolInfo.dest_loc == "" then
    w["comm_frame"]:SetStatusText("Please enter your next location.")
  else
    local clear_value = w["clear_checkbox"]:GetValue()
    local asst_value = w["assistance_checkbox"]:GetValue()
    local comm_string

    if clear_value == true then
      comm_string = Me:SubValues(Main.db.char.patrolComms.updatePatrolClear)
    elseif asst_value == true then
      comm_string = Me:SubValues(Main.db.char.patrolComms.updatePatrolAsst)
    else
      comm_string = Me:SubValues(Main.db.char.patrolComms.updatePatrolOffense)
    end

    if Main.debug == true then
      print("Comm String: "..comm_string)
    else
      Me:SendComm(comm_string)
    end
    if Main.db.char.patrolInfo.patrol_type == "clockwise" then
      local current_value = w["next_loc_dropdown"]:GetValue()
      local next_value = w["next_loc_dropdown"]:GetValue() + 1
      if current_value == SCGComms:NumLocations() then
        next_value = 1
      end
      w["current_loc_dropdown"]:SetValue(current_value)
      Main.db.char.patrolInfo.current_loc = LOCATIONS[current_value]
      w["next_loc_dropdown"]:SetValue(next_value)
      Main.db.char.patrolInfo.dest_loc = LOCATIONS[next_value]
    elseif Main.db.char.patrolInfo.patrol_type == "counter-clockwise" then
      local current_value = w["current_loc_dropdown"]:GetValue() - 1
      local next_value = current_value - 1
      if w["current_loc_dropdown"]:GetValue() == 1 then
        current_value = SCGComms:NumLocations()
        next_value = SCGComms:NumLocations() - 1
      end
      if current_value == 1 then
        next_value = SCGComms:NumLocations()
      end
      w["current_loc_dropdown"]:SetValue(current_value)
      Main.db.char.patrolInfo.current_loc = LOCATIONS[current_value]
      w["next_loc_dropdown"]:SetValue(next_value)
      Main.db.char.patrolInfo.dest_loc = LOCATIONS[next_value]
    end
    w["end_loc_dropdown"]:SetValue(w["current_loc_dropdown"]:GetValue())
    w["end_loc_dropdown"]:SetText(Main.db.char.patrolInfo.current_loc)
    Main.db.char.patrolInfo.end_loc = Main.db.char.patrolInfo.current_loc
  end
end

function Me:OnUpdatePatrolDescribeClicked()
  if Main.db.char.patrolInfo.pl_name == "" then
    w["comm_frame"]:SetStatusText("Please enter a valid PL name.")
  elseif Main.db.char.patrolInfo.current_loc == "" then
    w["comm_frame"]:SetStatusText("Please enter your current location.")
  elseif Main.db.char.patrolInfo.offense == "" then
    w["comm_frame"]:SetStatusText("Please enter your the offense you're handling.")
  else
    local clear_value = w["clear_checkbox"]:GetValue()
    local asst_value = w["assistance_checkbox"]:GetValue()
    local comm_string

    if clear_value == true then
      comm_string = Me:SubValues(Main.db.char.patrolComms.updatePatrolClear)
    elseif asst_value == true then
      comm_string = Me:SubValues(Main.db.char.patrolComms.updatePatrolAsst)
    else
      comm_string = Me:SubValues(Main.db.char.patrolComms.updatePatrolOffense)
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
  if Main.db.char.patrolInfo.pl_name == "" then
    w["comm_frame"]:SetStatusText("Please enter a valid PL name.")
  elseif Main.db.char.patrolInfo.end_loc == "" then
    w["comm_frame"]:SetStatusText("Please enter your ending location.")
  else
    Main.db.char.patrolInfo.inProgress = false
    local comm_string = Me:SubValues(Main.db.char.patrolComms.endPatrol)
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
      "end_patrol_button", "end_loc_dropdown", "offense_dropdown",
      "assistance_checkbox", "update_patrol_button_describe",
      "current_loc_dropdown_desc"
    }
    Me:ClearAttrs()
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
    w["current_loc_dropdown_desc"]:SetText(Main.db.char.patrolInfo.current_loc)
  end
end

function Me:OnClockwiseChanged(widget, val)
  if val == true and w["counter_clock_radio"]:GetValue() == true then
    w["counter_clock_radio"]:SetValue(false)
    Main.db.char.patrolInfo.patrol_type = "clockwise"
  end
end

function Me:OnCounterChanged(widget, val)
  if val == true and w["clockwise_radio"]:GetValue() == true then
    w["clockwise_radio"]:SetValue(false)
    Main.db.char.patrolInfo.patrol_type = "counter-clockwise"
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
  w[my_key]:SetHeight(300)
  w[my_key]:SetLayout("Fill")
  if Main.db.char.patrolInfo.inProgress == true then
    w[my_key]:SetStatusText("Patrol in Progress. Current Location: "..
      Main.db.char.patrolInfo.current_loc..". Click 'End Patrol' to end "..
    "the patrol.")
  else
    w[my_key]:SetStatusText("No patrol currently in progress. "..
    "Click 'Start Patrol' to start a patrol.")
  end

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
  Me:OptionalLocGroup(my_key)
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

  Me:CurrentLocDropdown(my_key)
  Me:NextLocDropdown(my_key)
  Me:ClearCheckBox(my_key)
  Me:UpdatePatrolBtnUpdate(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:DescribePatrolGroup(parent_key)
  local my_key = "describe_group"
  w[my_key] = AceGUI:Create("InlineGroup")
  w[my_key]:SetTitle("Describe the Situation")

  w[my_key]:SetFullWidth(true)
  w[my_key]:SetLayout("Flow")

  Me:OffenseDropdown(my_key)
  Me:CurrentLocDropdownDescribe(my_key)
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

function Me:OptionalLocGroup(parent_key)
  local my_key = "optional_loc_group"
  w[my_key] = AceGUI:Create("InlineGroup")

  w[my_key]:SetTitle("Optional Locations")
  w[my_key]:SetLayout("Flow")
  w[my_key]:SetFullWidth(true)

  Me:OptionalLambCheck(my_key)
  Me:OptionalHarborCheck(my_key)
  Me:OptionalGraveyardCheck(my_key)
  w[parent_key]:AddChild(w[my_key])
end

function Me:LeaderName(parent_key) -- pl_name
  local my_key = "pl_name_editbox"
  w[my_key] = AceGUI:Create("EditBox")

  w[my_key]:SetLabel("Leader Name")
  w[my_key]:SetWidth(530 - 100)
  w[my_key]:SetText(Main.db.char.patrolInfo.pl_name)
  w[my_key]:DisableButton(true)
  w[my_key]:SetCallback("OnTextChanged",
      function(widget, event, text) Main.db.char.patrolInfo.pl_name = text end)
  w[parent_key]:AddChild(w[my_key])
end

function Me:RankDropdown(parent_key)
  local my_key = "rank_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")

  w[my_key]:SetWidth(130)
  w[my_key]:SetText("Select...")
  w[my_key]:SetList(RANKS)
  w[my_key]:SetLabel("Leader Rank")

  if Main.db.char.patrolInfo.inProgress == true then
    local index = SCGComms:RanksIndex()
    w[my_key]:SetValue(index[Main.db.char.patrolInfo.rank])
  end

  w[my_key]:SetCallback("OnValueChanged",
    function(widget, event, value) Main.db.char.patrolInfo.rank = RANKS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:OptionalLambCheck(parent_key)
  local my_key = "optional_lamb_check"
  w[my_key] = AceGUI:Create("CheckBox")

  w[my_key]:SetValue(Main.db.char.patrolInfo.optional_locs["lamb"])
  w[my_key]:SetType("checkbox")
  w[my_key]:SetLabel("Lamb")
  w[my_key]:SetWidth(100)

  w[my_key]:SetCallback("OnValueChanged", function(widget, event, value)
      if value == true then
        Me:AddLamb()
      else
        Me:RemoveLamb()
      end
  end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:OptionalHarborCheck(parent_key)
  local my_key = "optional_harbor_check"
  w[my_key] = AceGUI:Create("CheckBox")

  w[my_key]:SetValue(Main.db.char.patrolInfo.optional_locs["harbor"])
  w[my_key]:SetType("checkbox")
  w[my_key]:SetLabel("Harbor")
  w[my_key]:SetWidth(100)

  w[my_key]:SetCallback("OnValueChanged", function(widget, event, value)
    if value == true then
      Me:AddHarbor()
    else
      Me:RemoveHarbor()
    end
  end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:OptionalGraveyardCheck(parent_key)
  local my_key = "optional_graveyard_check"
  w[my_key] = AceGUI:Create("CheckBox")

  w[my_key]:SetValue(Main.db.char.patrolInfo.optional_locs["gy"])
  w[my_key]:SetType("checkbox")
  w[my_key]:SetLabel("Graveyard")
  w[my_key]:SetWidth(100)

  w[my_key]:SetCallback("OnValueChanged", function(widget, event, value)
    if value == true then
      Me:AddGraveyard()
    else
      Me:RemoveGraveyard()
    end
  end)

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
  if Main.db.char.patrolInfo.patrol_type == "clockwise" then
    w[my_key]:SetValue(true)
  else
    w[my_key]:SetValue(false)
  end

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
  if Main.db.char.patrolInfo.patrol_type == "counter-clockwise" then
    w[my_key]:SetValue(true)
  else
    w[my_key]:SetValue(false)
  end

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

  if Main.db.char.patrolInfo.inProgress == true then
    local index = SCGComms:LocationsIndex()
    w[my_key]:SetValue(index[Main.db.char.patrolInfo.start_loc])
  end

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) Main.db.char.patrolInfo.start_loc =
        LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:NextLocDropdown(parent_key)
  local my_key = "next_loc_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")

  w[my_key]:SetText("Select...")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Next Location")
  w[my_key]:SetWidth(130)

  if Main.db.char.patrolInfo.inProgress == true then
    local index = SCGComms:LocationsIndex()
    w[my_key]:SetValue(index[Main.db.char.patrolInfo.dest_loc])
  end

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) Main.db.char.patrolInfo.dest_loc =
        LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:EndLocDropdown(parent_key)
  local my_key = "end_loc_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")

  w[my_key]:SetText("Select...")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("End Location")
  w[my_key]:SetWidth(130)

  if Main.db.char.patrolInfo.inProgress == true then
    local index = SCGComms:LocationsIndex()
    w[my_key]:SetValue(index[Main.db.char.patrolInfo.end_loc])
  end

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) Main.db.char.patrolInfo.end_loc =
        LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:ClearCheckBox(parent_key)
  local my_key = "clear_checkbox"
  w[my_key] = AceGUI:Create("CheckBox")

  w[my_key]:SetLabel("Clear?")
  w[my_key]:SetWidth(75)
  w[my_key]:SetType("checkbox")
  w[my_key]:ToggleChecked(true)

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
      function(widget, event, value) Main.db.char.patrolInfo.offense =
        OFFENSES[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:CurrentLocDropdown(parent_key)
  local my_key = "current_loc_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")

  w[my_key]:SetText("Select...")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Current Location")
  w[my_key]:SetWidth(130)

  if Main.db.char.patrolInfo.inProgress == true then
    local index = SCGComms:LocationsIndex()
    w[my_key]:SetValue(index[Main.db.char.patrolInfo.current_loc])
  end

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) Main.db.char.patrolInfo.current_loc =
        LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:CurrentLocDropdownDescribe(parent_key)
  local my_key = "current_loc_dropdown_desc"
  w[my_key] = AceGUI:Create("Dropdown")

  w[my_key]:SetText("Select...")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Current Location")
  w[my_key]:SetWidth(130)
  w[my_key]:SetDisabled(true)

  if Main.db.char.patrolInfo.inProgress == true then
    local index = SCGComms:LocationsIndex()
    w[my_key]:SetValue(index[Main.db.char.patrolInfo.current_loc])
  end

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) Main.db.char.patrolInfo.current_loc =
        LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:AssistanceCheckBox(parent_key)
  local my_key = "assistance_checkbox"
  w[my_key] = AceGUI:Create("CheckBox")

  w[my_key]:SetLabel("Do You Require Assistance?")
  w[my_key]:SetType("checkbox")

  w[parent_key]:AddChild(w[my_key])
end

function Me:UpdatePatrolBtnUpdate(parent_key)
  local my_key = "update_patrol_button_update"
  w[my_key] = AceGUI:Create("Button")

  w[my_key]:SetText("Update Patrol")
  w[my_key]:SetWidth(130)

  w[my_key]:SetCallback("OnClick",
      function(widget, event, value) Me:OnUpdatePatrolClicked() end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:UpdatePatrolBtnDescribe(parent_key)
  local my_key = "update_patrol_button_describe"
  w[my_key] = AceGUI:Create("Button")

  w[my_key]:SetText("Update Patrol")
  w[my_key]:SetWidth(130)
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnClick",
      function(widget, event, value) Me:OnUpdatePatrolDescribeClicked() end)

  w[parent_key]:AddChild(w[my_key])
end
