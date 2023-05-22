--VER. 1.0 by RGB

--THIS SCRIPT ASSUMES YOU HAVE DONE THE FOLLOWING:

--SWS Extensions installed
--Assigned a track template to a slot in your Resources list
--Created FX Receive tracks with desired names.

--IF SO:

--ENTER NAMES OF FX RECEIVE TRACKS and TEMPLATE SLOT NUMBER BELOW:

UserFXReceiveNames = {"Room", "Med Room", "Big Amb", "Slap", "Echo", "Comp"} --Names of Receive Tracks inside the curly brackets
TemplateNumber = "2" --Put the slot number inside the quotes

---------------------------------------------------------------

-------DON'T TOUCH ANYTHING BEYOND HERE --------

-- Disarm record on all tracks

for i=0, reaper.CountTracks(0)-1 do
  local track = reaper.GetTrack(0, i)
  reaper.SetMediaTrackInfo_Value(track, "I_RECARM", 0)
end

-- Iterate over all tracks

local num_tracks = reaper.GetNumTracks()
for i = 0, num_tracks - 1 do
  local track = reaper.GetTrack(0, i)
  reaper.SetTrackSelected(track, false)
end

-- Select the slot for the FX template

command_id = reaper.NamedCommandLookup("_S&M_ADD_TRTEMPLATE"..TemplateNumber, 0)
reaper.Main_OnCommand(command_id,0)

-- Set the selected track to record
local track = reaper.GetSelectedTrack(0, 0)
reaper.SetMediaTrackInfo_Value(track, "I_RECARM", 1)

-- Find the tracks with the specified names

local receive_tracks = {}
for _, name in ipairs(UserFXReceiveNames) do
  for i = 0, num_tracks - 1 do
    local cur_track = reaper.GetTrack(0, i)
    local _, track_name = reaper.GetSetMediaTrackInfo_String(cur_track, "P_NAME", "", false)
    if track_name == name then
      receive_track = cur_track
      break
    end
  end
  if receive_track then
    -- Add a send to the selected track, pointing to the receive track
    local send = reaper.CreateTrackSend(track, receive_track)
    -- Set the send properties as desired
    reaper.SetTrackSendInfo_Value(track, 0, send, "I_DSTCHAN", 2)
    reaper.SetTrackSendInfo_Value(track, 0, send, "D_VOL", 0)
    receive_track = nil
  end
end

-- Move selected track to bottom of track list

function moveTrackToBottom()  -- defines the function
  reaper.Undo_BeginBlock()  -- begins a block of undoable actions
  
  -- gets the selected track
  local sel_track = reaper.GetSelectedTrack(0, 0)
  
  -- if a track is selected, then continue
  if sel_track then
    -- gets the number of tracks in the project
    local num_tracks = reaper.CountTracks(0)
    
    -- moves the selected track to the bottom of the track list
    reaper.ReorderSelectedTracks(num_tracks, 0)
  end
  
  -- ends the undo block
  reaper.Undo_EndBlock('Move selected track to bottom of track list', -1)
end

-- execute the function
moveTrackToBottom()

