local AceGUI = LibStub("AceGUI-3.0")
local Main = SCGComms
local Me = {}

SCGComms.UpdatePanel = Me

local w = {}
-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Events
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Frame Constructor
-------------------------------------------------------------------------------
function Me:Show()
  Me:UpdatePanel()
end

function Me:UpdatePanel()
  local my_key = "update_panel"
  w[my_key] = AceGUI:Create("Frame")

  w[my_key]:SetTitle("Quick Update")
  w[my_key]:SetWidth(200)
  w[my_key]:SetHeight(200)
  w[my_key]:SetLayout("List")

  Me:UpdateButton(my_key)
end

function Me:UpdateButton(parent_key)
  local my_key = "update_button"
  w[my_key] = AceGUI:Create("Button")

  w[my_key]:SetText("Update")

  w[my_key]:SetCallback("OnClick",
      function(button) Me:Test(button) end)

  w[parent_key]:AddChild(w[my_key])
end

function Me:Test(button)
  print(button)
end
