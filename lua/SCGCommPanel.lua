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
local panel

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
function Me:SendComm()
  local db = Main.db.char
  local comm = pl_name..db.patrol_comms.patrolIntro.." "..start_loc.." "..
    db.patrol_comms.clearSignal.." "..db.patrol_comms.enrouteTo.." "..dest_loc
  if Main.debug == true then
    print(comm)
  else
    SendChatMessage(comm,"PARTY" ,"COMMON")
  end
end

function Me:OnClearChanged(val)
  if val == true then
    problems_group:Release()
  else
    panel:AddChild(problems_group, send_comm_button)
  end
end

-------------------------------------------------------------------------------
-- Frame declarations
-- Wrap in BuildPanel Method for toggling
-------------------------------------------------------------------------------
function Me:Show()
  Me:BuildPanel()
end

function Me:Hide()
  panel:Hide()
end

function Me:BuildPanel()
  -- frame and widget declarations
  frame = AceGUI:Create("Frame")
  pl_name_editbox = AceGUI:Create("EditBox")
  location_group = AceGUI:Create("SimpleGroup")
  start_loc_dropdown = AceGUI:Create("Dropdown")
  dest_loc_dropdown = AceGUI:Create("Dropdown")
  dest_loc_dropdown = AceGUI:Create("Dropdown")
  clear_checkbox = AceGUI:Create("CheckBox")
  problems_group = AceGUI:Create("InlineGroup")
  level_one_dropdown = AceGUI:Create("Dropdown")
  send_comm_button = AceGUI:Create("Button")

  -- layouts and sizing
  frame:SetTitle("SWCG Comms")
  frame:SetWidth(400)
  frame:SetLayout("List")

  pl_name_editbox:SetLabel("Patrol Leader's Name:")
  pl_name_editbox:SetWidth(150)
  pl_name_editbox:DisableButton(true)

  location_group:SetWidth(400)
  location_group:SetLayout("Flow")

  start_loc_dropdown:SetText("Select Location")
  start_loc_dropdown:SetList(LOCATIONS)
  start_loc_dropdown:SetLabel("Starting Location")
  start_loc_dropdown:SetWidth(125)

  dest_loc_dropdown:SetText("Select Location")
  dest_loc_dropdown:SetList(LOCATIONS)
  dest_loc_dropdown:SetLabel("Destination Location")
  dest_loc_dropdown:SetWidth(125)

  clear_checkbox:SetLabel("Clear?")
  clear_checkbox:SetWidth(75)
  clear_checkbox:SetType("checkbox")
  clear_checkbox:ToggleChecked(true)

  problems_group:SetTitle("Describe the Situation")
  problems_group:SetWidth(350)
  problems_group:SetLayout("Flow")

  level_one_dropdown:SetText("Select...")
  level_one_dropdown:SetList(LEVEL_ONE_PROBLEMS)
  level_one_dropdown:SetLabel("What level of offense?")

  send_comm_button:SetText("Send Comm")
  send_comm_button:SetWidth(120)

  -- establish parent-child
  frame:AddChild(pl_name_editbox)
  frame:AddChild(location_group)
  location_group:AddChild(start_loc_dropdown)
  location_group:AddChild(dest_loc_dropdown)
  location_group:AddChild(clear_checkbox)
  frame:AddChild(send_comm_button)
  problems_group:AddChild(level_one_dropdown)

  -- register callbacks
  frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
  pl_name_editbox:SetCallback("OnTextChanged",
      function(widget, event, text) pl_name = text end)
  start_loc_dropdown:SetCallback("OnValueChanged",
      function(widget, event, value) start_loc = LOCATIONS[value] end)
  dest_loc_dropdown:SetCallback("OnValueChanged",
      function(widget, event, value) dest_loc = LOCATIONS[value] end)
  clear_checkbox:SetCallback("OnValueChanged",
      function(widget, event, value) Me:OnClearChanged(value) end)
  send_comm_button:SetCallback("OnClick",
      function(widget, event, value) Me:SendComm() end)

    panel = frame
end
