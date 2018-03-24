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
function Me:SendComm()
  local comm_string = Me:BuildCommString()
  if Main.debug == true then
    print(comm_string)
  else
    SendChatMessage(comm_string,"OFFICER" ,"COMMON")
  end
end

function Me:BuildCommString()
  local time_string = Me:BuildTimeString()
  local db = Main.db.char.patrol_comms
  local intro = string.gsub(db.patrolIntro, "%[name%]", pl_name)
  local clear = string.gsub(db.clearSignal, "%[start_loc%]", start_loc)
  local enroute = string.gsub(db.enrouteTo, "%[dest_loc%]", dest_loc)
  local comm = intro.." "..clear.." "..enroute.." "..time_string.." hours."

  return comm
end

function Me:BuildTimeString()
  local hours, minutes = GetGameTime();
  local time_string = hours..":"..minutes

  if hours < 10 then
    time_string = string.gsub(time_string, hours..":", "0"..hours..":")
  end

  if minutes < 10 then
     time_string = string.gsub(time_string, ":"..minutes, ":0"..minutes)
  end

  return time_string
end

function Me:OnClearChanged(val)
  for _, v in pairs(Me:GetControlGroups()) do
    w[v]:SetDisabled(val)
  end
  -- if val == true then
  --   w["key_problems_group"]:Release()
  -- else
  --   w["key_comm_frame"]:AddChild(w["key_problems_group"], w["send_comm_button"])
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
    location_group = AceGUI:Create("SimpleGroup"),
    start_loc_dropdown = AceGUI:Create("Dropdown"),
    dest_loc_dropdown = AceGUI:Create("Dropdown"),
    clear_checkbox = AceGUI:Create("CheckBox"),
    problems_group = AceGUI:Create("InlineGroup"),
    offense_dropdown = AceGUI:Create("Dropdown"),
    assistance_checkbox = AceGUI:Create("CheckBox"),
    resolve_group = AceGUI:Create("InlineGroup"),
    send_comm_button = AceGUI:Create("Button")
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

  w["pl_name_editbox"]:SetLabel("Patrol Leader's Name:")
  w["pl_name_editbox"]:SetWidth(150)
  w["pl_name_editbox"]:DisableButton(true)

  w["location_group"]:SetWidth(350)
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

  w["send_comm_button"]:SetText("Send Comm")
  w["send_comm_button"]:SetWidth(120)
end

function Me:AddChildren()
  w["comm_frame"]:AddChild(w["pl_name_editbox"])
  w["comm_frame"]:AddChild(w["location_group"])
  w["location_group"]:AddChild(w["start_loc_dropdown"])
  w["location_group"]:AddChild(w["dest_loc_dropdown"])
  w["location_group"]:AddChild(w["clear_checkbox"])
  w["problems_group"]:AddChild(w["assistance_checkbox"])
  w["comm_frame"]:AddChild(w["problems_group"])
  w["comm_frame"]:AddChild(w["resolve_group"])
  w["comm_frame"]:AddChild(w["send_comm_button"])
  w["problems_group"]:AddChild(w["offense_dropdown"])
end

function Me:RegisterCallbacks()
  -- register callbacks
  w["pl_name_editbox"]:SetCallback("OnTextChanged",
      function(widget, event, text) pl_name = text end)
  w["start_loc_dropdown"]:SetCallback("OnValueChanged",
      function(widget, event, value) start_loc = LOCATIONS[value] end)
  w["dest_loc_dropdown"]:SetCallback("OnValueChanged",
      function(widget, event, value) dest_loc = LOCATIONS[value] end)
  w["clear_checkbox"]:SetCallback("OnValueChanged",
      function(widget, event, value) Me:OnClearChanged(value) end)
  w["send_comm_button"]:SetCallback("OnClick",
      function(widget, event, value) Me:SendComm() end)
end
