-------------------------------------------------------------------------------
-- Stormwind City Guard Comms
-- For the Stormwind City Guard Guild - Moon Guard
-- Special thanks to Tammya-MoonGuard
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Includes, libs, etc.
-------------------------------------------------------------------------------
local Main      = LibStub("AceAddon-3.0"):NewAddon( "SCGComms",
                    "AceHook-3.0", "AceEvent-3.0" )
local AceConfig = LibStub("AceConfig-3.0")
Main.debug = true

SCGComms = Main

-------------------------------------------------------------------------------
-- Database defaults
-------------------------------------------------------------------------------
local defaults = {
  char = {
    patrol_comms = {
      patrolIntro = "[name]'s patrol.",
      clearSignal = "[start_loc] clear.",
      enrouteTo = "Enroute to [dest_loc]."
    },
    minimapicon = {
      hide = false
    }
  }
}

SCGComms_defaults = defaults

-------------------------------------------------------------------------------
-- Initialization and Post Initialization
-------------------------------------------------------------------------------
function Main:OnInitialize()
  Main.MinimapButton.Init()
  if Main.debug == true then
    print("SCGComms Debug Mode: On")
  end

  Main.CommPanel:Show()
end

function Main:OnEnable()
  Main:CreateDB()
  Main.MinimapButton.OnLoad()
end

function Main:SetDebug(bool)
  Main.debug = bool
  if bool == true then
    print("SCGComms Debug Mode: On")
  else
    print("SCGComms Debug Mode: Off")
  end
end

function Main:CreateDB()
  Main.db = LibStub("AceDB-3.0"):New("SCGCommsSaved", defaults)
end

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
LOCATIONS = {
  "Stocks", "MQ", "Recluse", "Lamb", "LR",
  "CD", "GY", "Shady Lady", "DD",
  "Keg", "OT", "Pig", "TD"
}

PROBLEMS = {
  "Pos. of Illegal Goods", "Propaganda",
  "Lock Picking Devices", "Bloodthistle",
  "Felweed", "Demon's Blood", "Plague",
  "Discharging a Weapon", "Gambling",
  "Vagrancy", "Possesssion of a Demon",
  "Unlawful Gatherinng",
  "Brawling", "Breaking and Entering",
  "Loitering", "Disturbing the Peace",
  "Harrassment", "Misuse of Magic",
  "Trespassing", "Resisting Arrest",
  "Pick Pocketing", "Unarmed Assault",
  "Leaving Crime Scene",
  "Property Damage", "Theft", "Burglary",
  "Stalking", "Armed Assault", "Magical Assault",
  "Falsifying Information", "Rioting",
  "Inciting a Riot", "Criminal Association",
  "Dist. of Illegal Goods", "Embezzlement",
  "Bribery", "Robbery", "Public Endangerment",
  "Impersonating an Agent of the Crown",
  "Murder", "Treason", "Slavery", "Sex Crimes",
  "Kidnapping", "Jailbreaking"
}
