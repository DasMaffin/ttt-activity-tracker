ActivityTracker.currentRoundActivities = ActivityTracker.currentRoundActivities or {}
ActivityTracker.allActivities = ActivityTracker.allActivities or {}

hook.Add("Initialize", "InitializeActivities", function()
    ActivityTracker.allActivities = loadAllActivities()
end)

local betweenRoundReports = {}
hook.Add("TTTBeginRound", "OnRoundBeginActivityTracking", function()
    local osTime = os.time() --os.date(...) for formatting, check wiki.
    for _, ply in ipairs(player.GetHumans()) do
        ActivityTracker.currentRoundActivities[ply:SteamID64()] = {}
        ActivityTracker.currentRoundActivities[ply:SteamID64()].startTime = osTime
        ActivityTracker.currentRoundActivities[ply:SteamID64()].activePlayers = #team.GetPlayers(TEAM_TERROR) -- TODO Check if this is accurate, doesnt count spec, does count died before round start...
        ActivityTracker.currentRoundActivities[ply:SteamID64()].playing = ply:Team() == TEAM_TERROR
        ActivityTracker.currentRoundActivities[ply:SteamID64()].finishedReports = betweenRoundReports[ply:SteamID64()] or 0
    end
    betweenRoundReports = {}
end)

hook.Add("TTTEndRound", "OnRoundEndActivityTracking", function(result)
    local osTime = os.time() --os.date(...) for formatting, check wiki.
    for _, ply in ipairs(player.GetHumans()) do
        ActivityTracker.currentRoundActivities[ply:SteamID64()] = ActivityTracker.currentRoundActivities[ply:SteamID64()] or {}
        ActivityTracker.currentRoundActivities[ply:SteamID64()].endTime = osTime
    end
    
    for plyID, activity in pairs(ActivityTracker.currentRoundActivities) do
        if activity.endTime ~= nil and activity.startTime ~= nil then
            ActivityTracker.allActivities[plyID] = ActivityTracker.allActivities[plyID] or {} -- create if not existing, otherwise use what we have

            table.insert(ActivityTracker.allActivities[plyID], 
            {   -- copy don't reference
                startTime = activity.startTime,
                endTime   = activity.endTime,
                activePlayers = activity.activePlayers,
                playing = activity.playing,              -- wether or not the player took part in this round or was AFK.
                finishedReports = activity.finishedReports
            }) 
        end
    end

    ActivityTracker.currentRoundActivities = {}

    saveAllActivities(ActivityTracker.allActivities)
end)

-- TODO test that reports between rounds are applied correctly.
hook.Add("RDMManagerStatusUpdated", "CountFinishedReports", function(ply, index, status, isReportFromPreviousMap)
    if status == 3 then
        if GetRoundState() ~= ROUND_ACTIVE then
            betweenRoundReports[ply:SteamID64()] = (betweenRoundReports[ply:SteamID64()] or 0) + 1
        else
            ActivityTracker.currentRoundActivities[ply:SteamID64()] = ActivityTracker.currentRoundActivities[ply:SteamID64()] or {}
            ActivityTracker.currentRoundActivities[ply:SteamID64()].finishedReports = (ActivityTracker.currentRoundActivities[ply:SteamID64()].finishedReports or 0) + 1
        end
    end
end)

net.Receive("CollectDataForDisplaying", function(len, ply)
    local timerange = net.ReadTable()
    local fromTimestamp = os.time({
        year = timerange.FromYear,
        month = timerange.FromMonth,
        day   = timerange.FromDay,
        hour  = 0,
        min   = 0,
        sec   = 0,
        isdst = false
    })
    local toTimestamp = os.time({
        year = timerange.ToYear,
        month = timerange.ToMonth,
        day   = timerange.ToDay,
        hour  = 23,
        min   = 59,
        sec   = 59,
        isdst = false
    })
    local sendBackActivity = {}
    local chunkSize = 100
    local chunkIndex = 1
    local i = 1
    if ActivityTracker.allActivities[timerange.player] then
        for _, activity in ipairs(ActivityTracker.allActivities[timerange.player]) do
            if activity.startTime < toTimestamp and activity.endTime > fromTimestamp then
                i = i + 1
                if not sendBackActivity[chunkIndex] then
                    sendBackActivity[chunkIndex] = {}
                end
                table.insert(sendBackActivity[chunkIndex], activity)
                if i % chunkSize == 0 then
                    chunkIndex = chunkIndex + 1
                end
            end
        end
    end

    for _, chunk in ipairs(sendBackActivity) do
        local json = util.TableToJSON(chunk)
        print("JSON size:", #json, "bytes")
        net.Start("CollectDataForDisplaying")
        net.WriteUInt(_, 16)              -- chunk index
        net.WriteUInt(#sendBackActivity, 16) -- total chunks
        net.WriteTable(chunk)
        net.Send(ply)
    end
end)

function loadAllActivities()
    local allActivities = {}
    if file.Exists(ActivityTracker.activitiesPath, "DATA") then
        allActivities = util.JSONToTable(file.Read(ActivityTracker.activitiesPath, "DATA"), false, true)
    end
    return allActivities
end

function saveAllActivities(activities)
    if not file.Exists(ActivityTracker.activitiesFolder, "DATA") then file.CreateDir(ActivityTracker.activitiesFolder) end
    file.Write(ActivityTracker.activitiesPath, util.TableToJSON(activities, true))
end