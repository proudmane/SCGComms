local AceGUI = LibStub("AceGUI-3.0")
local Main = SCGComms
local Me = {}

Main.CommPanel = Me

-------------------------------------------------------------------------------
-- attributes
-------------------------------------------------------------------------------
local pl_name
local patrol_type
local start_loc
local dest_loc

local w = {}

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
function Me:SendComm(comm_string)
  SendChatMessage(comm_string,"OFFICER" ,"COMMON")
end

function Me:OnUpdatePatrolClicked()
  local time_string = Me:BuildTimeString()
  local db = Main.db.char.patrol_comms
  local intro = string.gsub(db.patrolIntro, "%[name%]", pl_name)
  local clear = string.gsub(db.clearSignal, "%[start_loc%]", start_loc)
  local enroute = string.gsub(db.enrouteTo, "%[dest_loc%]", dest_loc)
  local comm = intro.." "..clear.." "..enroute.." "..time_string.." hours."
  if Main.debug == true then
    print("Comm String: "..comm)
  else
    Me:SendComm(comm)
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

function Me:OnClearChanged(val)
  if Main.debug == true then
    print("OnClearChanged called.")
  end

  for _, v in pairs(Me:GetControlGroups()) do
    w[v]:SetDisabled(val)
  end
end

function Me:OnClockwiseChanged(widget, val)
  if val == true and w["counter_clock_radio"]:GetValue() == true then
    w["counter_clock_radio"]:ToggleChecked()
  end
end

function Me:OnCounterChanged(widget, val)
  if val == true and w["clockwise_radio"]:GetValue() == true then
    w["clockwise_radio"]:ToggleChecked()
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
  w[my_key]:SetWidth(382)
  w[my_key]:SetHeight(365)
  w[my_key]:SetLayout("Fill")

  -- Me:ScrollFrameContainer(my_key)
  Me:ScrollFrame(my_key)
end

-- function Me:ScrollFrameContainer(parent_key)
--   local my_key = "scroll_frame_container"
--   w[my_key] = AceGUI:Create("SimpleGroup")
--   w[my_key]:SetFullWidth(true)
--   w[my_key]:SetFullHeight(true)
--   w[my_key]:SetLayout("Fill")
--
--   Me:ScrollFrame(my_key)
--
--   w[parent_key]:AddChild(w[my_key])
-- end

function Me:ScrollFrame(parent_key)
  local my_key = "scroll_frame"
  w[my_key] = AceGUI:Create("ScrollFrame")
  w[my_key]:SetLayout("Flow")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetFullHeight(true)

  Me:LeaderName(my_key)
  Me:StartPatrolGroup(my_key)
  Me:UpdatePatrolGroup(my_key)
  Me:DescribeGroup(my_key)
  Me:ResolveGroup(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:StartPatrolGroup(parent_key)
  local my_key = "start_patrol_group"
  w[my_key] = AceGUI:Create("InlineGroup")
  w[my_key]:SetTitle("Start Patrol")
  w[my_key]:SetLayout("List")
  w[my_key]:SetWidth(350)

  Me:ClockRadioGroup(my_key)
  Me:StartBtnGroup(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:UpdatePatrolGroup(parent_key)
  local my_key = "update_patrol_group"
  w[my_key] = AceGUI:Create("InlineGroup")
  w[my_key]:SetTitle("Update Patrol")
  w[my_key]:SetWidth(350)
  w[my_key]:SetLayout("Flow")

  Me:StartLocDropdown(my_key)
  Me:DestLocDropdown(my_key)
  Me:ClearCheckBox(my_key)
  Me:UpdatePatrolBtn(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:DescribeGroup(parent_key)
  local my_key = "describe_group"
  w[my_key] = AceGUI:Create("InlineGroup")
  w[my_key]:SetTitle("Describe the Situation")
  w[my_key]:SetWidth(350)
  w[my_key]:SetLayout("Flow")

  Me:OffenseDropdown(my_key)
  Me:AssistanceCheckBox(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:ResolveGroup(parent_key)
  local my_key = "resolve_group"
  w[my_key] = AceGUI:Create("InlineGroup")

  w[parent_key]:AddChild(w[my_key])
end

function Me:StartBtnGroup(parent_key)
  local my_key = "start_btn_group"
  w[my_key] = AceGUI:Create("SimpleGroup")
  w[my_key]:SetLayout("Flow")
  w[my_key]:SetFullWidth(true)

  Me:InitiateDropdown(my_key)
  Me:StartPatrolBtn(my_key)
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

function Me:LeaderName(parent_key) -- pl_name
  local my_key = "pl_name_editbox"
  w[my_key] = AceGUI:Create("EditBox")
  w[my_key]:SetLabel("Patrol Leader's Name:")
  w[my_key]:SetWidth(150)
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

function Me:InitiateDropdown(parent_key)
  local my_key = "initiate_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select Location")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Patrol Start Location")
  w[my_key]:SetWidth(135)

  w[parent_key]:AddChild(w[my_key])
end

function Me:StartPatrolBtn(parent_key)
  local my_key = "start_patrol_button"
  w[my_key] = AceGUI:Create("Button")
  w[my_key]:SetText("Start Patrol")
  w[my_key]:SetWidth(110)

  w[parent_key]:AddChild(w[my_key])
end

function Me:StartLocDropdown(parent_key)
  local my_key = "start_loc_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select Location")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Starting Location")
  w[my_key]:SetWidth(130)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) start_loc = LOCATIONS[value] end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:DestLocDropdown(parent_key)
  local my_key = "dest_loc_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select Location")
  w[my_key]:SetList(LOCATIONS)
  w[my_key]:SetLabel("Destination Location")
  w[my_key]:SetWidth(130)

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

  w[parent_key]:AddChild(w[my_key])
end

function Me:OffenseDropdown(parent_key)
  local my_key = "offense_dropdown"
  w[my_key] = AceGUI:Create("Dropdown")
  w[my_key]:SetText("Select Offense")
  w[my_key]:SetList(PROBLEMS)
  w[my_key]:SetLabel("What offense are you investigating")
  w[my_key]:SetDisabled(true)

  w[my_key]:SetCallback("OnValueChanged",
      function(widget, event, value) Me:OnClearChanged(value) end)

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

function Me:UpdatePatrolBtn(parent_key)
  local my_key = "update_patrol_button"
  w[my_key] = AceGUI:Create("Button")
  w[my_key]:SetText("Update Patrol")
  w[my_key]:SetWidth(110)

  w[my_key]:SetCallback("OnClick",
      function(widget, event, value) Me:OnUpdatePatrolClicked() end)

  w[parent_key]:AddChild(w[my_key])
end

-- function Me:CreateFrames()
--   local w_group = {
--     comm_frame = AceGUI:Create("Frame"),
--     pl_name_editbox = AceGUI:Create("EditBox"),
--     start_patrol_group = AceGUI:Create("InlineGroup"),
--     clock_radio_group = AceGUI:Create("SimpleGroup"),
--     patrol_type = AceGUI:Create("Label"),
--     counter_clock_radio = AceGUI:Create("CheckBox"),
--     clockwise_radio = AceGUI:Create("CheckBox"),
--     start_btn_group = AceGUI:Create("SimpleGroup"),
--     initiate_dropdown = AceGUI:Create("Dropdown"),
--     start_patrol_button = AceGUI:Create("Button"),
--     location_group = AceGUI:Create("SimpleGroup"),
--     start_loc_dropdown = AceGUI:Create("Dropdown"),
--     dest_loc_dropdown = AceGUI:Create("Dropdown"),
--     clear_checkbox = AceGUI:Create("CheckBox"),
--     problems_group = AceGUI:Create("InlineGroup"),
--     offense_dropdown = AceGUI:Create("Dropdown"),
--     assistance_checkbox = AceGUI:Create("CheckBox"),
--     resolve_group = AceGUI:Create("InlineGroup"),
--     update_patrol_button = AceGUI:Create("Button")
--   }
--
--   w = w_group
-- end

function Me:GetControlGroups()
  return {"offense_dropdown", "assistance_checkbox"}
end

-- function Me:AddChildren()
--
--   w["start_patrol_group"]:AddChild(w["clock_radio_group"])
--   w["clock_radio_group"]:AddChild(w["patrol_type"])
--   w["clock_radio_group"]:AddChild(w["clockwise_radio"])
--   w["clock_radio_group"]:AddChild(w["counter_clock_radio"])
--   w["start_patrol_group"]:AddChild(w["start_btn_group"])
--   w["start_btn_group"]:AddChild(w["initiate_dropdown"])
--   w["start_btn_group"]:AddChild(w["start_patrol_button"])
--   w["comm_frame"]:AddChild(w["start_patrol_group"])
--   w["comm_frame"]:AddChild(w["location_group"])
--   w["location_group"]:AddChild(w["start_loc_dropdown"])
--   w["location_group"]:AddChild(w["dest_loc_dropdown"])
--   w["location_group"]:AddChild(w["clear_checkbox"])
--   w["problems_group"]:AddChild(w["assistance_checkbox"])
--   w["comm_frame"]:AddChild(w["problems_group"])
--   w["comm_frame"]:AddChild(w["resolve_group"])
--   w["comm_frame"]:AddChild(w["update_patrol_button"])
--   w["problems_group"]:AddChild(w["offense_dropdown"])
-- end
--
-- function Me:RegisterCallbacks()
--   -- register callbacks
--
--
--
--
--
--
--
-- end
