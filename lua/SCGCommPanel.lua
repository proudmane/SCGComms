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

local SCGComms_widgets

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
function Me:SendComm()
  local hours, minutes = GetGameTime();
  local time_string = hours..":"..minutes
  if hours < 10 then
    time_string = string.gsub(time_string, hours, "0"..hours)
  end
  --
  if minutes < 10 then
     time_string = string.gsub(time_string, minutes, "0"..minutes)
  end

  local db = Main.db.char
  local comm = pl_name..db.patrol_comms.patrolIntro.." "..start_loc.." "..
    db.patrol_comms.clearSignal.." "..db.patrol_comms.enrouteTo.." "..dest_loc..
    " "..time_string.." hours."
  if Main.debug == true then
    print(comm)
  else
    SendChatMessage(comm,"OFFICER" ,"COMMON")
  end
end

function Me:OnClearChanged(val)
  for _, v in pairs(Me:GetControlGroups()) do
    SCGComms_widgets[v]:SetDisabled(val)
  end
  -- if val == true then
  --   SCGComms_widgets["key_problems_group"]:Release()
  -- else
  --   SCGComms_widgets["key_comm_frame"]:AddChild(SCGComms_widgets["key_problems_group"], SCGComms_widgets["send_comm_button"])
  -- end
end

-------------------------------------------------------------------------------
-- Frame Constructor
-------------------------------------------------------------------------------
function Me:Show()
  Me:BuildPanel()
end

function Me:Hide()
  SCGComms_widgets["key_comm_frame"]:Hide()
end

function Me:BuildPanel()
  Me:CreateFrames()
  Me:SetLayouts()
  Me:AddChildren()
  Me:RegisterCallbacks()
end


function Me:CreateFrames()
  local widgets_group = {
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

  SCGComms_widgets = widgets_group
end

function Me:GetControlGroups()
  return {"offense_dropdown", "assistance_checkbox"}
end


function Me:SetLayouts()
  SCGComms_widgets["comm_frame"]:SetTitle("SWCG Comms")
  SCGComms_widgets["comm_frame"]:SetWidth(382)
  SCGComms_widgets["comm_frame"]:SetLayout("List")

  SCGComms_widgets["pl_name_editbox"]:SetLabel("Patrol Leader's Name:")
  SCGComms_widgets["pl_name_editbox"]:SetWidth(150)
  SCGComms_widgets["pl_name_editbox"]:DisableButton(true)

  SCGComms_widgets["location_group"]:SetWidth(350)
  SCGComms_widgets["location_group"]:SetLayout("Flow")

  SCGComms_widgets["start_loc_dropdown"]:SetText("Select Location")
  SCGComms_widgets["start_loc_dropdown"]:SetList(LOCATIONS)
  SCGComms_widgets["start_loc_dropdown"]:SetLabel("Starting Location")
  SCGComms_widgets["start_loc_dropdown"]:SetWidth(135)

  SCGComms_widgets["dest_loc_dropdown"]:SetText("Select Location")
  SCGComms_widgets["dest_loc_dropdown"]:SetList(LOCATIONS)
  SCGComms_widgets["dest_loc_dropdown"]:SetLabel("Destination Location")
  SCGComms_widgets["dest_loc_dropdown"]:SetWidth(135)

  SCGComms_widgets["clear_checkbox"]:SetLabel("Clear?")
  SCGComms_widgets["clear_checkbox"]:SetWidth(75)
  SCGComms_widgets["clear_checkbox"]:SetType("checkbox")
  SCGComms_widgets["clear_checkbox"]:ToggleChecked(true)

  SCGComms_widgets["problems_group"]:SetTitle("Describe the Situation")
  SCGComms_widgets["problems_group"]:SetWidth(350)
  SCGComms_widgets["problems_group"]:SetLayout("Flow")

  SCGComms_widgets["offense_dropdown"]:SetText("Select Offense")
  SCGComms_widgets["offense_dropdown"]:SetList(PROBLEMS)
  SCGComms_widgets["offense_dropdown"]:SetLabel("What offense are you investigating")
  SCGComms_widgets["offense_dropdown"]:SetDisabled(true)

  SCGComms_widgets["assistance_checkbox"]:SetLabel("Do You Require Assistance?")
  SCGComms_widgets["assistance_checkbox"]:SetType("checkbox")
  SCGComms_widgets["assistance_checkbox"]:SetDisabled(true)

  SCGComms_widgets["resolve_group"]:SetTitle("Resolve the Situation")
  SCGComms_widgets["resolve_group"]:SetWidth(350)
  SCGComms_widgets["resolve_group"]:SetLayout("List")

  SCGComms_widgets["send_comm_button"]:SetText("Send Comm")
  SCGComms_widgets["send_comm_button"]:SetWidth(120)
end

function Me:AddChildren()
  SCGComms_widgets["comm_frame"]:AddChild(SCGComms_widgets["pl_name_editbox"])
  SCGComms_widgets["comm_frame"]:AddChild(SCGComms_widgets["location_group"])
  SCGComms_widgets["location_group"]:AddChild(SCGComms_widgets["start_loc_dropdown"])
  SCGComms_widgets["location_group"]:AddChild(SCGComms_widgets["dest_loc_dropdown"])
  SCGComms_widgets["location_group"]:AddChild(SCGComms_widgets["clear_checkbox"])
  SCGComms_widgets["problems_group"]:AddChild(SCGComms_widgets["assistance_checkbox"])
  SCGComms_widgets["comm_frame"]:AddChild(SCGComms_widgets["problems_group"])
  SCGComms_widgets["comm_frame"]:AddChild(SCGComms_widgets["resolve_group"])
  SCGComms_widgets["comm_frame"]:AddChild(SCGComms_widgets["send_comm_button"])
  SCGComms_widgets["problems_group"]:AddChild(SCGComms_widgets["offense_dropdown"])
end

function Me:RegisterCallbacks()
  -- register callbacks
  SCGComms_widgets["key_pl_name_editbox"]:SetCallback("OnTextChanged",
      function(widget, event, text) pl_name = text end)
  SCGComms_widgets["key_start_loc_dropdown"]:SetCallback("OnValueChanged",
      function(widget, event, value) start_loc = LOCATIONS[value] end)
  SCGComms_widgets["key_dest_loc_dropdown"]:SetCallback("OnValueChanged",
      function(widget, event, value) dest_loc = LOCATIONS[value] end)
  SCGComms_widgets["key_clear_checkbox"]:SetCallback("OnValueChanged",
      function(widget, event, value) Me:OnClearChanged(value) end)
  SCGComms_widgets["key_send_comm_button"]:SetCallback("OnClick",
      function(widget, event, value) Me:SendComm() end)
end
