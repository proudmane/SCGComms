local AceGUI = LibStub("AceGUI-3.0")
local Main = SCGComms
local Me = {}
local w = {}
local open = false

SCGComms.DebugPanel = Me

-------------------------------------------------------------------------------
-- Utility Functions
-------------------------------------------------------------------------------
function Me:StringifyValues()
  -- loop through everything in db, stringify it.
  local info = table.tostring(Main.db.char.patrolInfo)
  local comms = table.tostring(Main.db.char.patrolComms)
  local map = table.tostring(Main.db.char.minimapicon)
  local locs = table.tostring(LOCATIONS)
  local locs_index = table.tostring(Main:LocationsIndex())
  local num_locs = Main.NumLocations()
  local orig_locs = table.tostring(ORIG_LOCATIONS)
  local ranks = table.tostring(RANKS)
  local ranks_index = table.tostring(Main:RanksIndex())
  local offenses = table.tostring(OFFENSES)

  local debug = "```Patrol Information: "..info.."\n\nPatrol Config: "..comms..
  "\n\nMinimap data: "..map.."\n\nLocations: "..locs.."\n\nLocations Index:"..locs_index..
  "\n\nNumLocations: "..num_locs.."\n\nOrigLocations: "..orig_locs.."\n\nRanks: "..ranks..
  "\n\nRanks Index: "..ranks_index.."\n\nOffenses: "..offenses.."```"

  return debug
end

function Me:PrintClubs()
  -- convenience method kept in for if the Community ID ever changes
  w["config_text"]:SetText(table.tostring(C_Club.GetStreams("345393461")))
end

function Me:GetOpen()
  return open
end

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

-------------------------------------------------------------------------------
-- Frame Constructor
-------------------------------------------------------------------------------
function Me:DebugFrame()
  local my_key = "debug_frame"
  w[my_key] = AceGUI:Create("Frame")
  w[my_key]:SetTitle("SWCG Comms Debugger")
  w[my_key]:SetWidth(420)
  w[my_key]:SetHeight(530)
  w[my_key]:SetLayout("List")

  w[my_key]:SetCallback("OnClose", function() open = false end)

  Me:ScrollFrame(my_key)
end

function Me:ScrollFrame(parent_key)
  local my_key = "scroll_frame"
  w[my_key] = AceGUI:Create("ScrollFrame")
  w[my_key]:SetLayout("Flow")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetFullHeight(true)

  Me:DebuggerTextGroup(my_key)
  Me:DebuggerButton(my_key)
  Me:DebuggerTextBox(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:DebuggerTextGroup(parent_key)
  local my_key = "debug_text_group"
  w[my_key] = AceGUI:Create("InlineGroup")
  w[my_key]:SetTitle("How to Use:")
  w[my_key]:SetFullWidth(true)

  Me:DebuggerText(my_key)

  w[parent_key]:AddChild(w[my_key])
end

function Me:DebuggerText(parent_key)
  local my_key = "config_text"
  w[my_key] = AceGUI:Create("Label")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetText(
  "This panel provides development tools for the author to find bugs and "..
  "debug them. Press the 'Debug' button. The addon will generate a string "..
  "of text which contains all of the internal values within the addon's "..
  "DB. Copy this text and send to Donorbashed#1683 in a discord private "..
  "message. This is essential for fixing the bug you are reporting. If "..
  "you cannot use Discord for whatever reason whisper Darosaa-MoonGuard when "..
  "you see me online.\n\n"..
  "Select all of the text with your mouse and then Control-C to copy in the game."
  )

  w[parent_key]:AddChild(w[my_key])
end

function Me:DebuggerTextBox(parent_key)
  local my_key = "debugger_text_box"
  w[my_key] = AceGUI:Create("MultiLineEditBox")
  w[my_key]:SetFullWidth(true)
  w[my_key]:SetNumLines(18)
  w[my_key]:SetMaxLetters(0)
  w[my_key]:SetLabel("Debug String: ")

  w[parent_key]:AddChild(w[my_key])
end

function Me:DebuggerButton(parent_key)
  local my_key = "debugger_button"
  w[my_key] = AceGUI:Create("Button")
  w[my_key]:SetText("Debug")
  w[my_key]:SetWidth(80)
  w[my_key]:SetCallback("OnClick",
    function() w["debugger_text_box"]:SetText(Me:StringifyValues()) end)

  w[parent_key]:AddChild(w[my_key])
end
-------------------------------------------------------------------------------
-- Events
-------------------------------------------------------------------------------
function Me.Show()
  Me:DebugFrame()
  open = true
end
