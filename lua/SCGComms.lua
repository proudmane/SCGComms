-------------------------------------------------------------------------------
-- Stormwind City Guard Comms
-- For the Stormwind City Guard Guild - Moon Guard
-- Special thanks to Tammya-MoonGuard
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Includes, libs, etc.
-------------------------------------------------------------------------------
local Main             = LibStub("AceAddon-3.0"):NewAddon( "SCGComms",
                            "AceHook-3.0", "AceEvent-3.0" )
local AceConfig        = LibStub("AceConfig-3.0")
Main.debug = true

SCGComms = Main

-------------------------------------------------------------------------------
-- Database defaults
-------------------------------------------------------------------------------
local defaults = {
  char = {
    patrol_comms = {
      enabled = true,
      patrolIntro = "'s patrol.",
      clearSignal = "clear.",
      enrouteTo = "Enroute to"
    },
    minimapicon = {
      hide = false
    }
  }
}

-------------------------------------------------------------------------------
-- Initialization and Post Initialization
-------------------------------------------------------------------------------
function Main:OnInitialize()
  Main.MinimapButton.Init()
end

function Main:OnEnable()
  Main:CreateDB()
  Main.MinimapButton.OnLoad()
end

function Main.Show()
  Main.CommPanel:BuildPanel()
end

-------------------------------------------------------------------------------
-- Constants, attributes
-------------------------------------------------------------------------------
LOCATIONS = {
  "MQ", "Recluse", "Lamb", "LR",
  "CD", "Shady Lady", "DD",
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

-------------------------------------------------------------------------------
function Main:CreateDB()
  Main.db = LibStub("AceDB-3.0"):New("SCGCommsSaved", defaults)
end
