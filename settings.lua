


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
