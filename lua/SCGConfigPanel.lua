local AceGUI = LibStub("AceGUI-3.0")
local Main = SCGComms
local Me = {}

SCGComms.ConfigPanel = Me

-------------------------------------------------------------------------------
-- attributes
-------------------------------------------------------------------------------
local db = Main.db
local SCGConfig_widgets


function Me:Show()
  Me:BuildPanel()
end

function Me:Hide()
  SCGConfig_widgets["config_frame"]:Hide()
end

function Me:BuildPanel()
  Me:CreateFrames()
  Me:SetLayouts()
  Me:AddChildren()
  Me:RegisterCallbacks()
end

function Me:CreateFrames()
  local widgets_group = {
    config_frame = AceGUI:Create("Frame"),
    patrol_config_group = AceGui:Create("InlineGroup")
  }

  SCGConfig_widgets = widgets_group
end

function Me:SetLayouts()
  SCGConfig_widgets["config_frame"]:SetTitle("SWCG Comms Config")
  SCGConfig_widgets["config_frame"]:SetWidth(400)
  SCGConfig_widgets["config_frame"]:SetLayout("List")

  SCGConfig_widgets["patrol_config_group"]:SetTitle("")
end

function Me:AddChildren()

end

function Me:RegisterCallbacks()

end
