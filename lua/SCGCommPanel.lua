local AceGUI = LibStub("AceGUI-3.0")
local Main = SCGComms
local Me = {}

Main.CommPanel = Me

-------------------------------------------------------------------------------
-- attributes
-------------------------------------------------------------------------------
local pl_name
local start_loc
local dest_loc

local w

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
  if val == true then
    w["counter_clock_radio"]:ToggleChecked()
  end
end

function Me:OnCounterChanged(widget, val)
  -- if val == true then
  --   w["clockwise_radio"]:ToggleChecked()
  -- end
end
-------------------------------------------------------------------------------
-- Frame Constructor
-------------------------------------------------------------------------------
function Me:Show()
  Me:BuildPanel()
end

function Me:Hide()
  w["key_comm_frame"]:Hide()
end

function Me:BuildPanel()
  Me:CreateFrames()
  Me:SetLayouts()
  Me:AddChildren()
  Me:RegisterCallbacks()
end


function Me:CreateFrames()
  local w_group = {
    comm_frame = AceGUI:Create("Frame"),
    pl_name_editbox = AceGUI:Create("EditBox"),
    start_patrol_group = AceGUI:Create("InlineGroup"),
    clock_radio_group = AceGUI:Create("SimpleGroup"),
    patrol_type = AceGUI:Create("Label"),
    counter_clock_radio = AceGUI:Create("CheckBox"),
    clockwise_radio = AceGUI:Create("CheckBox"),
    start_btn_group = AceGUI:Create("SimpleGroup"),
    initiate_dropdown = AceGUI:Create("Dropdown"),
    start_patrol_button = AceGUI:Create("Button"),
    location_group = AceGUI:Create("SimpleGroup"),
    start_loc_dropdown = AceGUI:Create("Dropdown"),
    dest_loc_dropdown = AceGUI:Create("Dropdown"),
    clear_checkbox = AceGUI:Create("CheckBox"),
    problems_group = AceGUI:Create("InlineGroup"),
    offense_dropdown = AceGUI:Create("Dropdown"),
    assistance_checkbox = AceGUI:Create("CheckBox"),
    resolve_group = AceGUI:Create("InlineGroup"),
    update_patrol_button = AceGUI:Create("Button")
  }

  w = w_group
end

function Me:GetControlGroups()
  return {"offense_dropdown", "assistance_checkbox"}
end


function Me:SetLayouts()
  w["comm_frame"]:SetTitle("SWCG Comms")
  w["comm_frame"]:SetWidth(382)
  w["comm_frame"]:SetLayout("List")

  w["start_patrol_group"]:SetTitle("Start Patrol")
  w["start_patrol_group"]:SetLayout("List")
  w["start_patrol_group"]:SetFullWidth(true)

  w["pl_name_editbox"]:SetLabel("Patrol Leader's Name:")
  w["pl_name_editbox"]:SetWidth(150)
  w["pl_name_editbox"]:DisableButton(true)

  w["clock_radio_group"]:SetLayout("Flow")
  w["clock_radio_group"]:SetFullWidth(true)

  w["patrol_type"]:SetText("Select Patrol Type:")
  w["patrol_type"]:SetFullWidth(true)

  w["clockwise_radio"]:SetLabel("Clockwise")
  w["clockwise_radio"]:SetType("radio")
  w["clockwise_radio"]:SetWidth(100)

  w["counter_clock_radio"]:SetLabel("Counter")
  w["counter_clock_radio"]:SetType("radio")
  w["counter_clock_radio"]:SetWidth(100)

  w["start_btn_group"]:SetLayout("Flow")
  w["start_btn_group"]:SetFullWidth(true)

  w["initiate_dropdown"]:SetText("Select Location")
  w["initiate_dropdown"]:SetList(LOCATIONS)
  w["initiate_dropdown"]:SetLabel("Patrol Start Location")
  w["initiate_dropdown"]:SetWidth(135)

  w["start_patrol_button"]:SetText("Start Patrol")
  w["start_patrol_button"]:SetWidth(110)

  w["location_group"]:SetFullWidth(350)
  w["location_group"]:SetLayout("Flow")

  w["start_loc_dropdown"]:SetText("Select Location")
  w["start_loc_dropdown"]:SetList(LOCATIONS)
  w["start_loc_dropdown"]:SetLabel("Starting Location")
  w["start_loc_dropdown"]:SetWidth(135)

  w["dest_loc_dropdown"]:SetText("Select Location")
  w["dest_loc_dropdown"]:SetList(LOCATIONS)
  w["dest_loc_dropdown"]:SetLabel("Destination Location")
  w["dest_loc_dropdown"]:SetWidth(135)

  w["clear_checkbox"]:SetLabel("Clear?")
  w["clear_checkbox"]:SetWidth(75)
  w["clear_checkbox"]:SetType("checkbox")
  w["clear_checkbox"]:ToggleChecked(true)

  w["problems_group"]:SetTitle("Describe the Situation")
  w["problems_group"]:SetWidth(350)
  w["problems_group"]:SetLayout("Flow")

  w["offense_dropdown"]:SetText("Select Offense")
  w["offense_dropdown"]:SetList(PROBLEMS)
  w["offense_dropdown"]:SetLabel("What offense are you investigating")
  w["offense_dropdown"]:SetDisabled(true)

  w["assistance_checkbox"]:SetLabel("Do You Require Assistance?")
  w["assistance_checkbox"]:SetType("checkbox")
  w["assistance_checkbox"]:SetDisabled(true)

  w["resolve_group"]:SetTitle("Resolve the Situation")
  w["resolve_group"]:SetWidth(350)
  w["resolve_group"]:SetLayout("List")

  w["update_patrol_button"]:SetText("Update Patrol")
  w["update_patrol_button"]:SetWidth(110)
end

function Me:AddChildren()
  w["comm_frame"]:AddChild(w["pl_name_editbox"])
  w["start_patrol_group"]:AddChild(w["clock_radio_group"])
  w["clock_radio_group"]:AddChild(w["patrol_type"])
  w["clock_radio_group"]:AddChild(w["clockwise_radio"])
  w["clock_radio_group"]:AddChild(w["counter_clock_radio"])
  w["start_patrol_group"]:AddChild(w["start_btn_group"])
  w["start_btn_group"]:AddChild(w["initiate_dropdown"])
  w["start_btn_group"]:AddChild(w["start_patrol_button"])
  w["comm_frame"]:AddChild(w["start_patrol_group"])
  w["comm_frame"]:AddChild(w["location_group"])
  w["location_group"]:AddChild(w["start_loc_dropdown"])
  w["location_group"]:AddChild(w["dest_loc_dropdown"])
  w["location_group"]:AddChild(w["clear_checkbox"])
  w["problems_group"]:AddChild(w["assistance_checkbox"])
  w["comm_frame"]:AddChild(w["problems_group"])
  w["comm_frame"]:AddChild(w["resolve_group"])
  w["comm_frame"]:AddChild(w["update_patrol_button"])
  w["problems_group"]:AddChild(w["offense_dropdown"])
end

function Me:RegisterCallbacks()
  -- register callbacks
  w["pl_name_editbox"]:SetCallback("OnTextChanged",
      function(widget, event, text) pl_name = text end)
  w["clockwise_radio"]:SetCallback("OnValueChanged",
      function(widget, event, value) Me:OnClockwiseChanged(widget, value) end)
  w["counter_clock_radio"]:SetCallback("OnValueChanged",
      function(widget, event, value) Me:OnCounterChanged(widget, value) end)
  w["start_loc_dropdown"]:SetCallback("OnValueChanged",
      function(widget, event, value) start_loc = LOCATIONS[value] end)
  w["dest_loc_dropdown"]:SetCallback("OnValueChanged",
      function(widget, event, value) dest_loc = LOCATIONS[value] end)
  w["clear_checkbox"]:SetCallback("OnValueChanged",
      function(widget, event, value) Me:OnClearChanged(value) end)
  w["update_patrol_button"]:SetCallback("OnClick",
      function(widget, event, value) Me:OnUpdatePatrolClicked() end)
end
