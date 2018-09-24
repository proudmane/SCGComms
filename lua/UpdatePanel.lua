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
  w[my_key] = AceGUI:Create("SimpleGroup")

  -- w[my_key]:SetTitle("Quick Update")
  w[my_key]:SetWidth(200)
  w[my_key]:SetHeight(200)
end

-- function
