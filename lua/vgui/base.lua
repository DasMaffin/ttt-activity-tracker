local PANEL = {}
vgui.Register("ActivityTrackerBaseHUD", PANEL, "EditablePanel")
local activityBaseHUD = nil

function PANEL:Init()
    self:SetSize(ScrW() * 0.6, ScrH() * 0.6)
    self:SetPos(ScrW() * 0.2, ScrH() * 0.2)
    self:SetVisible(false)    
    self.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 40, 240))
    end

    self.closeButton = vgui.Create("DButton", self)
    self.closeButton:SetSize(32, 32)
    self.closeButton:SetPos(self:GetWide() - 40, 8)
    self.closeButton:SetText("")
    self.closeButton.Paint = function(s, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(25, 25, 35, 255), true, true, true, true)
        draw.SimpleText("×", "DermaBold", (w / 2) - 2, (h / 2) - 2, Color(255, 128, 128), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    self.closeButton.DoClick = function()
        self:SetVisible(false)
        BaseHUDisActive = false
        gui.EnableScreenClicker(false)
    end

    -- Horizontal line below the close button
    self.lineY = 50 -- Y position of the line
    self.PaintOver = function(s, w, h)
        surface.SetDrawColor(Color(255, 255, 255, 50)) -- Light gray line
        surface.DrawLine(10, self.lineY, w - 10, self.lineY)
    end

    -- Register cards container
    self.registerCards = vgui.Create("DIconLayout", self)
    self.registerCards:SetPos(10, 10) -- Position below the close button
    self.registerCards:SetSize(735, self.lineY - 10) -- Height up to the line
    self.registerCards:SetSpaceX(5) -- Spacing between cards

    -- Styled scroll panel
    self.scrollPanel = vgui.Create("DScrollPanel", self)
    self.scrollPanel:SetPos(10, self.lineY + 10)
    self.scrollPanel:SetSize(self:GetWide() - 20, self:GetTall() - self.lineY - 20)
    self.scrollPanel:Dock(FILL)
    self.scrollPanel:DockMargin(10, self.lineY + 10, 10, 10)
    self.scrollPanel.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 0, 10))
    end

    -- Style the scrollbar
    local sbar = self.scrollPanel:GetVBar()
    sbar:SetHideButtons(true)
    sbar.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(200, 200, 200))
    end
    sbar.btnGrip.Paint = function(_, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(150, 150, 150))
    end
    
    self.CheckLayout = vgui.Create("DPanel", self.scrollPanel)
    self.CheckLayout:SetSize(self.scrollPanel:GetWide(), self.scrollPanel:GetTall())
    self.CheckLayout.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 255, 0, 10))
    end
    self:AddRegisterCard("Check Player", self.CheckLayout)

    
    -- currently all players are added by default. Just an idea to limit which player gets tracked later maybe
    -- self.AddLayout = vgui.Create("DPanel", self.scrollPanel)
    -- self.AddLayout:SetSize(self.scrollPanel:GetWide(), self.scrollPanel:GetTall())
    -- self:AddRegisterCard("Add Player", self.AddLayout)


    self.DataDisplay = vgui.Create("ActivityTrackerDataDisplayHUD", self.CheckLayout)
    self.DataDisplay:Dock(FILL)
    self.DataDisplay.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 255, 10))
    end
end

cards = {}
local switchTabs = {}
local lastSelectedIndex = 1
function PANEL:AddRegisterCard(name, layout, method)
    local card = vgui.Create("DButton", self.registerCards)
    card:SetSize(100, self.lineY - 10)
    card:SetText("")
    card.Paint = function(s, w, h)
        draw.SimpleText(name, "DermaDefault", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    layout:SetVisible(false)
    switchTabs[name] = {}
    switchTabs[name].index = table.Count(cards) + 1 -- Save the index on creation, so it will not change when more cards are added.
    switchTabs[name].method = function()
        lastSelectedIndex = switchTabs[name].index  -- we need to update lastSelectedIndex otherwise the correct layout will open, but it will show as if index 1 was selected when closing and reopening the UI.
        self:DrawCards(lastSelectedIndex)
        if method then
            method()
        end
    end
    card.DoClick = function()
        self:CloseAllCards()
        if switchTabs[name].method then
            switchTabs[name].method()
        end
    end

    cards[card] = {
        name = name,
        layout = layout,
        index = table.Count(cards) + 1
    }

    return card
end

function PANEL:DrawCards(activeID)
    for card, content in pairs(cards) do
        if(content.index == activeID) then
            content.layout:SetVisible(true)
        end
        card.Paint = function(s, w, h)
            if(content.index == activeID) then
                draw.RoundedBoxEx(8, 0, 5, w, h - 5, Color(50, 50, 70, 255), true, true, false, false)
            else
                draw.RoundedBoxEx(8, 0, 0, w, h, Color(50, 50, 70, 255), true, true, false, false)
            end
            draw.SimpleText(content.name, "DermaDefault", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

function PANEL:CloseAllCards()
    for card, content in pairs(cards) do
        content.layout:SetVisible(false)
    end
end

function ActivityTracker:TogglePanel()
    if not IsValid(activityBaseHUD) then
        activityBaseHUD = vgui.Create("ActivityTrackerBaseHUD")
    end

    -- Toggle visibility
    if activityBaseHUD:IsVisible() then
        activityBaseHUD:SetVisible(false)
        gui.EnableScreenClicker(false)
    else
        activityBaseHUD:SetVisible(true)
        activityBaseHUD:MakePopup()
        gui.EnableScreenClicker(true)
        activityBaseHUD:DrawCards(lastSelectedIndex)
    end
end