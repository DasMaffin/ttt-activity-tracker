ActivityTracker = ActivityTracker or {}
ActivityTracker.activitiesFolder = "activityTracker"
ActivityTracker.activitiesFile = "/activities.json"
ActivityTracker.activitiesPath = ActivityTracker.activitiesFolder .. ActivityTracker.activitiesFile

if SERVER then
    AddCSLuaFile("vgui/base.lua")
    AddCSLuaFile("vgui/fonts.lua")
    AddCSLuaFile("vgui/data_display.lua")
    AddCSLuaFile("cl/inputmanager.lua")
    
    include("sv/activity_manager.lua")

    util.AddNetworkString("CollectDataForDisplaying")
elseif CLIENT then
    include("vgui/base.lua")
    include("vgui/fonts.lua")
    include("vgui/data_display.lua")
    include("cl/inputmanager.lua")    
end