-- This is the panel in which data gets displayed.
-- Has an input to select which playerdata and the timerange.
-- Has an output of the selected data organized neatly.
DATE_TYPE_DAY = 1
DATE_TYPE_MONTH = 2
DATE_TYPE_YEAR = 3

local PANEL = {}
vgui.Register("ActivityTrackerDataDisplayHUD", PANEL, "EditablePanel")
local dataDisplayHUD = nil

function PANEL:Init()
    dataDisplayHUD = self

    self.InputRegion = vgui.Create("DPanel", self)
    self.InputRegion:Dock(TOP)
    self.InputRegion.Paint = function(s, w, h) end

    self.SelectPlayerInputPanel = vgui.Create("DPanel", self.InputRegion)
    self.SelectPlayerInputPanel:Dock(LEFT)
    self.SelectPlayerInputPanel.Paint = function(s, w, h) end

    self.SelectPlayerInputLabel = vgui.Create("DLabel", self.SelectPlayerInputPanel)
    self.SelectPlayerInputLabel:SetText("")
    self.SelectPlayerInputLabel:Dock(TOP)
    self.SelectPlayerInputLabel.Paint = function(s, w, h)
        draw.SimpleText("Input a SteamID64 (the 7...):", "DermaDefault", 5, h - 5, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end

    local playerInput = nil
    self.SelectPlayerInput = vgui.Create("DTextEntry", self.SelectPlayerInputPanel)
    self.SelectPlayerInput:Dock(TOP)
    self.SelectPlayerInput:SetEditable(true)

    local autoFromOffset = 7 -- How many days in the past should be selected by default?
    self.FromDayPanel, self.FromDayInputLabel, self.FromDayInput = self:CreateNumberInput(1, 31, "From Day:", DATE_TYPE_DAY, LEFT, autoFromOffset)
    self.FromMonthPanel, self.FromMonthInputLabel, self.FromMonthInput = self:CreateNumberInput(1, 12, "From Month:", DATE_TYPE_MONTH, LEFT, autoFromOffset)
    self.FromYearPanel, self.FromYearInputLabel, self.FromYearInput = self:CreateNumberInput(2025, 2026, "From Year:", DATE_TYPE_YEAR, LEFT, autoFromOffset)

    self.ToYearPanel, self.ToYearInputLabel, self.ToYearInput = self:CreateNumberInput(2025, 2026, "To Year:", DATE_TYPE_YEAR, RIGHT)
    self.ToMonthPanel, self.ToMonthInputLabel, self.ToMonthInput = self:CreateNumberInput(1, 12, "To Month:", DATE_TYPE_MONTH, RIGHT)
    self.ToDayPanel, self.ToDayInputLabel, self.ToDayInput = self:CreateNumberInput(1, 31, "To Day:", DATE_TYPE_DAY, RIGHT)

    self.FetchDataButtonPanel = vgui.Create("DPanel", self)
    self.FetchDataButtonPanel:Dock(TOP)
    self.FetchDataButtonPanel.Paint = function(s, w, h) end

    self.FetchDataButton = vgui.Create("DButton", self.FetchDataButtonPanel)
    self.FetchDataButton:Dock(RIGHT)
    self.FetchDataButton:SetText("Display Data")
    self.FetchDataButton.DoClick = function()
        net.Start("CollectDataForDisplaying")
        net.WriteTable({
            FromDay = self.FromDayInput:GetSelected(),
            FromMonth = self.FromMonthInput:GetSelected(),
            FromYear = self.FromYearInput:GetSelected(),
            ToDay = self.ToDayInput:GetSelected(),
            ToMonth = self.ToMonthInput:GetSelected(),
            ToYear = self.ToYearInput:GetSelected(),
            player = self.SelectPlayerInput:GetValue()
        })
        net.SendToServer()
    end

    self.DisplayDataPanel = vgui.Create("DPanel", self)
    self.DisplayDataPanel:Dock(FILL)
    self.DisplayDataPanel.Paint = function(s, w, h) end
end

function PANEL:CreateNumberInput(rangeMin, rangeMax, label, type, dockType, daysAgo) -- type = day, month, year (1, 2, 3)
    local datePanel = vgui.Create("DPanel", self.InputRegion)
    datePanel:Dock(dockType)
    datePanel.Paint = function(s, w, h) end

    local dateInputLabel = vgui.Create("DLabel", datePanel)
    dateInputLabel:SetText("")
    dateInputLabel:Dock(TOP)
    dateInputLabel.Paint = function(s, w, h)
        draw.SimpleText(label, "DermaDefault", 5, h - 5, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    end

    local dateInput = vgui.Create("DComboBox", datePanel)
    dateInput:Dock(TOP)
    dateInput:Clear()
    for i = rangeMin, rangeMax do
        dateInput:AddChoice(string.format("%02d", i))
    end
    daysAgo = daysAgo or 0
    local daysAgo = os.time() - (daysAgo * 24 * 60 * 60)
    if type == DATE_TYPE_DAY then
        dateInput:ChooseOptionID(tonumber(os.date("%d", daysAgo)))
    elseif type == DATE_TYPE_MONTH then
        dateInput:ChooseOptionID(tonumber(os.date("%m", daysAgo)))
    elseif type == DATE_TYPE_YEAR then
        local currentYear = tonumber(os.date("%Y", daysAgo))
        for i = 1, (rangeMax - rangeMin) + 1 do
            local year = tonumber(dateInput:GetOptionText(i))
            if year == currentYear then
                dateInput:ChooseOptionID(i)
                break
            end
        end
    end
    return datePanel, dateInputLabel, dateInput
end

function PANEL:PerformLayout(width, height)
    self.InputRegion:SetTall(self:GetTall() * 0.1)

    self.SelectPlayerInputPanel:SetWide(self.InputRegion:GetWide() * 0.2)   
    self.SelectPlayerInputLabel:SetTall(self.FromDayPanel:GetTall() * 0.5)
    self.SelectPlayerInput:SetTall(self.FromDayPanel:GetTall() * 0.5)

    self.FromDayPanel:SetWide(self.InputRegion:GetWide() * 0.1)    
    self.FromDayInputLabel:SetTall(self.FromDayPanel:GetTall() * 0.5)
    self.FromDayInput:SetTall(self.FromDayPanel:GetTall() * 0.5)

    self.FromMonthPanel:SetWide(self.InputRegion:GetWide() * 0.1)    
    self.FromMonthInputLabel:SetTall(self.FromMonthPanel:GetTall() * 0.5)
    self.FromMonthInput:SetTall(self.FromMonthPanel:GetTall() * 0.5)

    self.FromYearPanel:SetWide(self.InputRegion:GetWide() * 0.1)    
    self.FromYearInputLabel:SetTall(self.FromYearPanel:GetTall() * 0.5)
    self.FromYearInput:SetTall(self.FromYearPanel:GetTall() * 0.5)

    

    self.ToDayPanel:SetWide(self.InputRegion:GetWide() * 0.1)    
    self.ToDayInputLabel:SetTall(self.ToDayPanel:GetTall() * 0.5)
    self.ToDayInput:SetTall(self.ToDayPanel:GetTall() * 0.5)

    self.ToMonthPanel:SetWide(self.InputRegion:GetWide() * 0.1)    
    self.ToMonthInputLabel:SetTall(self.ToMonthPanel:GetTall() * 0.5)
    self.ToMonthInput:SetTall(self.ToMonthPanel:GetTall() * 0.5)

    self.ToYearPanel:SetWide(self.InputRegion:GetWide() * 0.1)    
    self.ToYearInputLabel:SetTall(self.ToYearPanel:GetTall() * 0.5)
    self.ToYearInput:SetTall(self.ToYearPanel:GetTall() * 0.5)

    
    self.FetchDataButton:SetWide(self.FetchDataButtonPanel:GetWide() * 0.1)

    if self.PlaytimeLabel then
        self.PlaytimeLabel:SetTall(self.DisplayDataPanel:GetTall() * 0.1)
    end
    if self.ActivePlaytimeLabel then
        self.ActivePlaytimeLabel:SetTall(self.DisplayDataPanel:GetTall() * 0.1)
    end
    if self.PlaytimeLabel then
        self.PlaytimeLabel:SetTall(self.DisplayDataPanel:GetTall() * 0.1)
    end
    if self.AFKReports then
        self.AFKReports:SetTall(self.DisplayDataPanel:GetTall() * 0.1)
    end
    if self.PlayingReports then
        self.PlayingReports:SetTall(self.DisplayDataPanel:GetTall() * 0.1)
    end
    if self.TotalReports then
        self.TotalReports:SetTall(self.DisplayDataPanel:GetTall() * 0.1)
    end
    if self.QuantifiedPoints then
        self.QuantifiedPoints:SetTall(self.DisplayDataPanel:GetTall() * 0.1)
    end
end

function PANEL:DisplayActivities(activities)
    local totalPlayTime = 0
    local totalAFKTime = 0
    local playingReports = 0
    local AFKReports = 0
    local quantifiedPoints = 0
    for _, activity in ipairs(activities) do
        local roundTime = activity.endTime - activity.startTime
        totalPlayTime = totalPlayTime + roundTime
        if activity.playing == true then
            totalAFKTime = totalAFKTime + roundTime
            playingReports = playingReports + activity.finishedReports
            quantifiedPoints = quantifiedPoints + activity.activePlayers * roundTime
        else
            AFKReports = AFKReports + activity.finishedReports
        end
    end

    self.AFKOnlineTime = self:CreateDataDisplay("Total AFK time: ", totalAFKTime .. "s", self.AFKOnlineTime)
    self.ActivePlaytimeLabel = self:CreateDataDisplay("Total Active time: ", (totalPlayTime - totalAFKTime) .. "s", self.ActivePlaytimeLabel)
    self.PlaytimeLabel = self:CreateDataDisplay("Total Online time: ", totalPlayTime .. "s", self.PlaytimeLabel)

    self.AFKReports = self:CreateDataDisplay("Total Reports while AFK: ", AFKReports, self.AFKReports)
    self.PlayingReports = self:CreateDataDisplay("Total Reports while playing: ", playingReports, self.PlayingReports)
    self.TotalReports = self:CreateDataDisplay("Total Reports: ", playingReports + AFKReports, self.TotalReports)

    self.QuantifiedPoints = self:CreateDataDisplay("Quantified Playtime points (playtime * active players): ", quantifiedPoints, self.QuantifiedPoints)

    self:InvalidateLayout(true)
end

function PANEL:CreateDataDisplay(label, data, gui)
    local dataLabel = gui
    if not dataLabel then
        dataLabel = vgui.Create("DLabel", self.DisplayDataPanel)
        dataLabel:Dock(TOP)
        dataLabel:SetText("") 
    end
    dataLabel.Paint = function(s, w, h)
        draw.SimpleText(label .. data , "DermaDefault", 5, 0, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    return dataLabel
end

net.Receive("CollectDataForDisplaying", function(len, ply)
    local activities = net.ReadTable()

    dataDisplayHUD:DisplayActivities(activities)
end)