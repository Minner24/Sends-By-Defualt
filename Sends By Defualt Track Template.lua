--VER. 1.0 by RGB

--THIS SCRIPT ASSUMES YOU HAVE DONE THE FOLLOWING:

--SWS Extensions installed
--Assigned a track template to a slot in your Resources list
--Created FX Receive tracks with desired names.

--IF SO:

--ENTER NAMES OF FX RECEIVE TRACKS and TEMPLATE SLOT NUMBER BELOW:

UserFXReceiveNames = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"} --Names of Receive Tracks inside the curly brackets
TemplateNumber = "2" --Put the slot number inside the quotes

---------------------------------------------------------------

-------DON'T TOUCH ANYTHING BEYOND HERE --------

-- Disarm record on all tracks

for i = 0, reaper.CountTracks(0) - 1 do
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

command_id = reaper.NamedCommandLookup("_S&M_ADD_TRTEMPLATE" .. TemplateNumber, 0)
reaper.Main_OnCommand(command_id, 0)

-- Set the selected track to record
local track = reaper.GetSelectedTrack(0, 0)
reaper.SetMediaTrackInfo_Value(track, "I_RECARM", 1)

-- Find the tracks with the specified names

local last_track
for i = 0, num_tracks - 1 do
  local cur_track = reaper.GetTrack(0, i)
  local _, track_name = reaper.GetSetMediaTrackInfo_String(cur_track, "P_NAME", "", false)
  
  for _, name in ipairs(UserFXReceiveNames) do
    if track_name == name then
      local receive_track = cur_track
      last_track = cur_track -- Save the last found track

      -- Add a send to the selected track, pointing to the receive track
      local send = reaper.CreateTrackSend(track, receive_track)
      -- Set the send properties as desired
      reaper.SetTrackSendInfo_Value(track, 0, send, "I_DSTCHAN", 2)
      reaper.SetTrackSendInfo_Value(track, 0, send, "D_VOL", 0)
      
      -- Check if the current track is the added track
      if cur_track ~= track then
        -- Set the added track to not arm for record
        reaper.SetMediaTrackInfo_Value(cur_track, "I_RECARM", 0)
      end
    end
  end
end

-- Move selected track below the focused track

function moveTrackBelowFocused()
  reaper.Undo_BeginBlock()
  
  local focused_track = reaper.GetSelectedTrack(0, 0)
  
  if focused_track then
    local focused_track_idx = reaper.GetMediaTrackInfo_Value(focused_track, "IP_TRACKNUMBER")
    
    if focused_track_idx < num_tracks then
      local insert_idx = focused_track_idx + 1
      reaper.InsertTrackAtIndex(insert_idx, true)
      
      local new_track = reaper.GetTrack(0, insert_idx)
      reaper.ReorderSelectedTracks(insert_idx, 0)
    end
  end
end
