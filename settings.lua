


--[[ 
    **************************************************
    * SECTION: Settings frame
    **************************************************
--]]

GrindGoals.frames.settingsFrame = CreateFrame("Frame", "GrindGoalsSettingsFrame", GrindGoals.frames.mainFrame, "BasicFrameTemplateWithInset")
GrindGoals.frames.settingsFrame:SetSize(375, 325)
GrindGoals.frames.settingsFrame:SetPoint("CENTER", GrindGoals.frames.mainFrame, "CENTER", 0, 0)
GrindGoals.frames.settingsFrame.TitleBg:SetHeight(30)
GrindGoals.frames.settingsFrame.title = GrindGoals.frames.settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
GrindGoals.frames.settingsFrame.title:SetPoint("TOP", GrindGoals.frames.settingsFrame.TitleBg, "CENTER", 0, 10)
GrindGoals.frames.settingsFrame.title:SetText("GrindGoals Settings")
-- GrindGoals.frames.settingsFrame:SetClipsChildren(true) -- Prevents rendering outside the frame
GrindGoals.frames.settingsFrame:Hide() -- Frame is hidden by default
-- Making frame movable
GrindGoals.frames.settingsFrame:EnableMouse(true)

GrindGoals.frames.settingsFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        GrindGoals.frames.mainFrame:StartMoving()
    end
end)

GrindGoals.frames.settingsFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        GrindGoals.frames.mainFrame:StopMovingOrSizing()
    end
end)

GrindGoals.frames.settingsFrame.CloseButton:SetScript("OnClick", function()
    GrindGoals.frames.mainFrame:Hide() -- Hide the parent frame
end)

--[[ 
    **************************************************
    * SECTION: Settings frame contents
    **************************************************

    settings = {
        announceEveryNItem = true,
        numItemsToAnnounce = 100,
        announceInChat = true,
        announceOnScreen = false,
        playSound = false
    }

--]]

GrindGoals.frames.settingsFrame:SetScript("OnShow", function()
    GrindGoals.frames.settingsFrame.announceEveryNItemCheckBox:SetChecked(GrindGoalsDB.settings.announceEveryNItem)
    GrindGoals.frames.settingsFrame.numItemsToAnnounceBox:SetText(tostring(GrindGoalsDB.settings.numItemsToAnnounce))
    GrindGoals.frames.settingsFrame.announceInChatCheckBox:SetChecked(GrindGoalsDB.settings.announceInChat)
    GrindGoals.frames.settingsFrame.announceOnScreenCheckBox:SetChecked(GrindGoalsDB.settings.announceOnScreen)
    GrindGoals.frames.settingsFrame.playSoundCheckBox:SetChecked(GrindGoalsDB.settings.playSound)
end)

--*** Announce every N items acquierd ***

GrindGoals.frames.settingsFrame.announceEveryNItemCheckBox = CreateFrame("CheckButton", "announceEveryNItemCheckBox", GrindGoals.frames.settingsFrame, "UICheckButtonTemplate")
GrindGoals.frames.settingsFrame.announceEveryNItemCheckBox:SetPoint("TOPLEFT", GrindGoals.frames.settingsFrame, "TOPLEFT", 15, -30)
GrindGoals.frames.settingsFrame.announceEveryNItemCheckBox.Text:SetText("Announce every               items you have acquierd")
GrindGoals.frames.settingsFrame.announceEveryNItemCheckBox:SetScript("OnClick", function(self)
    PlaySound(808)
    GrindGoalsDB.settings.announceEveryNItem = self:GetChecked()
end)

GrindGoals.frames.settingsFrame.numItemsToAnnounceBox = CreateFrame("EditBox", "numItemsToAnnounceBox", GrindGoals.frames.settingsFrame.announceEveryNItemCheckBox, "InputBoxTemplate")
GrindGoals.frames.settingsFrame.numItemsToAnnounceBox:SetSize(35, 15)
GrindGoals.frames.settingsFrame.numItemsToAnnounceBox:SetPoint("CENTER", GrindGoals.frames.settingsFrame.announceEveryNItemCheckBox, "LEFT", 138, 0)
GrindGoals.frames.settingsFrame.numItemsToAnnounceBox:SetMaxLetters(4)
GrindGoals.frames.settingsFrame.numItemsToAnnounceBox:SetAutoFocus(false)

GrindGoals.frames.settingsFrame.numItemsToAnnounceBox:SetScript("OnEnter", function(self)    
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Number of items you have acquierd after which information message is shown, 1-9999", nil, nil, nil, nil, true)
end)

GrindGoals.frames.settingsFrame.numItemsToAnnounceBox:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)

GrindGoals.frames.settingsFrame.numItemsToAnnounceBox:SetScript("OnTextChanged", function(self)
    local text = self:GetText()
    local newText = text:gsub("[^0-9]", "") -- Remove all non-numeric characters
    if text ~= newText then
        self:SetText(newText)
        self:ClearFocus()
    end
    GrindGoalsDB.settings.numItemsToAnnounce = tonumber(self:GetText())
end)

-- *** Announce in chat ***

GrindGoals.frames.settingsFrame.announceInChatCheckBox = CreateFrame("CheckButton", "announceInChatCheckBox", GrindGoals.frames.settingsFrame, "UICheckButtonTemplate")
GrindGoals.frames.settingsFrame.announceInChatCheckBox:SetPoint("TOPLEFT", GrindGoals.frames.settingsFrame.announceEveryNItemCheckBox, "TOPLEFT", 25, -25)
GrindGoals.frames.settingsFrame.announceInChatCheckBox.Text:SetText("Announce in chat")
GrindGoals.frames.settingsFrame.announceInChatCheckBox:SetScript("OnClick", function(self)
    PlaySound(808)
    GrindGoalsDB.settings.announceInChat = self:GetChecked()
end)

GrindGoals.frames.settingsFrame.announceOnScreenCheckBox = CreateFrame("CheckButton", "announceOnScreenCheckBox", GrindGoals.frames.settingsFrame, "UICheckButtonTemplate")
GrindGoals.frames.settingsFrame.announceOnScreenCheckBox:SetPoint("TOPLEFT", GrindGoals.frames.settingsFrame.announceInChatCheckBox, "TOPLEFT", 0, -25)
GrindGoals.frames.settingsFrame.announceOnScreenCheckBox.Text:SetText("Announce on screen")
GrindGoals.frames.settingsFrame.announceOnScreenCheckBox:SetScript("OnClick", function(self)
    PlaySound(808)
    GrindGoalsDB.settings.announceOnScreen = self:GetChecked()
end)

GrindGoals.frames.settingsFrame.playSoundCheckBox = CreateFrame("CheckButton", "playSoundCheckBox", GrindGoals.frames.settingsFrame, "UICheckButtonTemplate")
GrindGoals.frames.settingsFrame.playSoundCheckBox:SetPoint("TOPLEFT", GrindGoals.frames.settingsFrame.announceOnScreenCheckBox, "TOPLEFT", 0, -25)
GrindGoals.frames.settingsFrame.playSoundCheckBox.Text:SetText("Play sound")
GrindGoals.frames.settingsFrame.playSoundCheckBox:SetScript("OnClick", function(self)
    PlaySound(808)
    GrindGoalsDB.settings.playSound = self:GetChecked()
end)


