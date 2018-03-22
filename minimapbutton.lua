local Main = SCGComms
local Me = {}
Main.MinimapButton = Me
print("testing 12")
local LDB    = LibStub:GetLibrary("LibDataBroker-1.1")
local DBIcon = LibStub:GetLibrary("LibDBIcon-1.0")

function Me.Init()
  print("init called")
  Me.data = LDB:NewDataObject("SCGComms", {
    type = "data source";
    text = "SCGComms";
    icon = "Interface\\Icons\\Inv_Misc_Tournaments_banner_Human";
    OnClick = function(...) Me.OnClick(...) end;
    OnEnter = function(...) Me.OnEnter(...) end;
    OnLeave = function(...) Me.OnLeave(...) end;
  })

end

function Me.OnLoad()
  DBIcon:Register("SCGComms", Me.data, Main.db.char.minimapicon)
end

function Me.OnClick(frame, button)
  if button == "LeftButton" then
    Main.Show()
  end
end

function Me.OnEnter(frame)
-- Section the screen into 6 sextants and define the tooltip
-- anchor position based on which sextant the cursor is in.
-- Code taken from WeakAuras.
--
  local max_x = 768 * GetMonitorAspectRatio()
  local max_y = 768
  local x, y = GetCursorPosition()

  local horizontal = (x < (max_x/3) and "LEFT") or ((x >= (max_x/3) and x < ((max_x/3)*2)) and "") or "RIGHT"
  local tooltip_vertical = (y < (max_y/2) and "BOTTOM") or "TOP"
  local anchor_vertical = (y < (max_y/2) and "TOP") or "BOTTOM"
  GameTooltip:SetOwner( frame, "ANCHOR_NONE" )
  GameTooltip:SetPoint( tooltip_vertical..horizontal, frame, anchor_vertical..horizontal )
  GameTooltip:AddLine("SCG Comms")
  GameTooltip:AddLine("Left click to open comm system.")
	GameTooltip:Show()
end

function Me.OnLeave( frame )
	GameTooltip:Hide()
end
