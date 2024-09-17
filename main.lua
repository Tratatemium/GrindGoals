-- This addon lets you set your goals for daily grind (number of items) and informs when its reached.
-- This is the file for addon main frame and globals


--[[ 
    **************************************************
    * SECTION: for me

    TODO
    NOTE

    **************************************************
--]]


-- Global variable so other addons / scripts could adress main code
GrindGoals = GrindGoals or {
    frames={}, functions={},
    topmostFrame = nil,             -- This global is for saving which frame displays on top
    itemOfInterestID = nil
}

--[[ GrindGoals = {
    frames = {
        GrindGoals.frames.mainFrame
    },
    functions = {
        GrindGoals.functions.countItemsInBags(itemID)
        function GrindGoals.functions.setFrameOnTop(self)
        GrindGoals.functions.updateMainframe()
    },
    GrindGoals.topmostFrame,
    GrindGoals.itemOfInterestID
    GrindGoals.itemIconTexture,
} ]]


-- Create variable for information storage.
GrindGoalsDB = GrindGoalsDB or {
    itemToFarmID = nil,
    itemNumberWanted = 0,
    itemNumberInBags = 0,
    isGrinding = false
}
--[[ GrindGoalsDB ={
GrindGoalsDB.itemNumberWanted,
GrindGoalsDB.itemToFarmID
} ]]

--[[ 
    **************************************************
    * SECTION: functions
    **************************************************
--]]

-- *** Count Items In Bags ***

-- NOTE: rewrite for banks?
function GrindGoals.functions.countItemsInBags(itemID, container) -- Function that checks how many of certan item player has in his bags
    if itemID == nil then
        return 0
    end
    local count = 0
    if container == "Bags" then
        for bag = BACKPACK_CONTAINER, BACKPACK_CONTAINER + NUM_BAG_SLOTS + NUM_REAGENTBAG_SLOTS do -- Loop through all bags
            for slot = 1, C_Container.GetContainerNumSlots(bag) do -- Loop through all slots in the bag          
                local id = C_Container.GetContainerItemID(bag, slot) 
                if id == itemID then
                    count = count + C_Container.GetContainerItemInfo(bag, slot).stackCount
                end
            end
        end
    end
    return count
end

-- *** Set Frame On Top ***

function GrindGoals.functions.setFrameOnTop(self) -- Function for setting frame as top frame
    if GrindGoals.topmostFrame then
        GrindGoals.topmostFrame:SetFrameLevel(1)  -- Reset the previous top frame's level
    end
    self:SetFrameStrata("HIGH")  -- Adjust this as needed
    self:SetFrameLevel(100)  -- Push the current frame to the top
    GrindGoals.topmostFrame = self  -- Set this frame as the new topmost
end

--- *** Get Farming Item Link ***

local function getFarmingItemLink()  -- Get item link from GrindGoalsDB.itemToFarmID
    local itemToFarmLink =""
    if GrindGoalsDB.itemToFarmID then
        _, itemToFarmLink = C_Item.GetItemInfo(GrindGoalsDB.itemToFarmID)
    else
        itemToFarmLink = "[No item selected!]"
    end
    return itemToFarmLink
end

-- *** Set Grind State ***

local function setGrindState(printMsg)                          -- Function that sets grind state depending on GrindGoalsDB.isGrinding variable
    if GrindGoalsDB.isGrinding == false then
        GrindGoals.frames.selectItemButton:Enable() 
        GrindGoals.frames.grindButton:Enable()
        GrindGoals.frames.stopGrindButton:Disable()
        GrindGoals.frames.itemNumberWantedBox:Enable()     
        GrindGoals.frames.glow:Hide()
    else
        if printMsg == true then    -- Message to chat on current state
            print(
            "|cFF00FF00[GrindGoals]|r:  Grinding  " .. getFarmingItemLink() .. " !   " ..
            GrindGoals.functions.countItemsInBags(GrindGoalsDB.itemToFarmID, "Bags") .. "/" .. GrindGoalsDB.itemNumberWanted
            )   
        end
        GrindGoals.frames.selectItemButton:Disable()
        GrindGoals.frames.grindButton:Disable()
        GrindGoals.frames.stopGrindButton:Enable()
        GrindGoals.frames.itemNumberWantedBox:Disable()        
        GrindGoals.frames.glow:Show()
    end
    
end

--[[ 
    **************************************************
    * SECTION: mainFrame
    **************************************************
--]]

GrindGoals.frames.mainFrame = CreateFrame("Frame", "GrindGoalsMainFrame", UIParent, "BasicFrameTemplateWithInset")
GrindGoals.frames.mainFrame:SetSize(375, 300)
GrindGoals.frames.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
GrindGoals.frames.mainFrame.TitleBg:SetHeight(30)
GrindGoals.frames.mainFrame.title = GrindGoals.frames.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
GrindGoals.frames.mainFrame.title:SetPoint("TOP", GrindGoals.frames.mainFrame.TitleBg, "CENTER", 0, 10)
GrindGoals.frames.mainFrame.title:SetText("GrindGoals")
-- GrindGoals.frames.mainFrame:SetClipsChildren(true) -- Prevents rendering outside the frame
GrindGoals.frames.mainFrame:Hide() -- Frame is hidden by default
-- Making frame movable
GrindGoals.frames.mainFrame:EnableMouse(true)
GrindGoals.frames.mainFrame:SetMovable(true)
GrindGoals.frames.mainFrame:RegisterForDrag("LeftButton")
GrindGoals.frames.mainFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
GrindGoals.frames.mainFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

-- Display frame on top if interracted with
GrindGoals.frames.mainFrame:SetScript("OnMouseDown", function(self)
    if ((
        not GrindGoals.frames.itemSelectionFrame:IsShown()) and 
        (not GrindGoals.frames.wrongNumberFrame:IsShown()) and
        (not GrindGoals.frames.wowhweadUrlFrame:IsShown())
    ) then
        GrindGoals.functions.setFrameOnTop(self)
    end
end)

-- Adding frame to WoW special list to make it closeable by Esc
table.insert(UISpecialFrames, "GrindGoalsMainFrame")


-- Making addon recognize slash commands.
SLASH_GRINDGOALS1 = "/g"
SLASH_GRINDGOALS2 = "/grind"
SlashCmdList["GRINDGOALS"] = function(msg)
    if msg == "" then
        if GrindGoals.frames.mainFrame:IsShown() then
            GrindGoals.frames.mainFrame:Hide()
        else
            GrindGoals.frames.mainFrame:Show()
        end
    elseif msg == "settings" then
        -- If the 'settings' argument is provided, open the settings
        SlashCmdList["MYADDONSETTINGS"]()
    else
        -- If invalid argument is provided
        print("Invalid command usage.")
    end
end

--[[ 
    **************************************************
    * SECTION: Contents of mainFrame
    **************************************************
--]]

-- *** updateMainframe() ***

function GrindGoals.functions.updateMainframe()      -- This function updates information in mainFrame
    GrindGoals.frames.mainFrame.itemLinkString:SetText("Item to grind: " .. (getFarmingItemLink() or ""))
    GrindGoals.frames.mainFrame.itemCountString:SetText("Number in bags: " .. (GrindGoals.functions.countItemsInBags(GrindGoalsDB.itemToFarmID, "Bags") or 0))
    GrindGoals.frames.mainFrame.characterBankCheckbox.Text:SetText("Number in character bank: ")
    GrindGoals.frames.mainFrame.warbandBankCheckbox.Text:SetText("Number in warband bank: ")
    GrindGoals.frames.itemNumberWantedBox:SetText(tostring(GrindGoalsDB.itemNumberWanted))
    if GrindGoalsDB.itemToFarmID then          -- Update item icon
        local _, _, _, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(GrindGoalsDB.itemToFarmID)
        GrindGoals.itemIconTexture:SetTexture(itemIcon) -- Get item texture from itemID
    else
        GrindGoals.itemIconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")  -- Placeholder icon
    end
end

-- *** Item selection text, item link ***

GrindGoals.frames.mainFrame.itemLinkString = GrindGoals.frames.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.mainFrame.itemLinkString:SetPoint("TOPLEFT", GrindGoals.frames.mainFrame, "TOPLEFT", 20, -35)
GrindGoals.frames.mainFrame.itemLinkString:SetPoint("BOTTOMRIGHT", GrindGoals.frames.mainFrame, "TOPRIGHT", -20, -65)
--GrindGoals.frames.mainFrame.itemLinkString:SetJustifyH("LEFT")       -- Align text to the left
GrindGoals.frames.mainFrame.itemLinkString:SetJustifyV("TOP")  -- Align text to the top
GrindGoals.frames.mainFrame.itemLinkString:SetWordWrap(true)

-- *** Item ICON ***

local itemIconFrame = CreateFrame("Frame", "itemIconFrame", GrindGoals.frames.mainFrame, "BackdropTemplate") -- Frame to show item icon
itemIconFrame:SetSize(64, 64)  -- Width, Height
itemIconFrame:SetPoint("TOPLEFT", GrindGoals.frames.mainFrame.itemLinkString, "TOPLEFT", 0, -20)  -- Position on the screen
itemIconFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
itemIconFrame:SetBackdropColor(0, 0, 0, 1)  -- Black background

GrindGoals.itemIconTexture = itemIconFrame:CreateTexture(nil, "ARTWORK")-- Item icon texture
GrindGoals.itemIconTexture:SetSize(40, 40)  -- Icon size
GrindGoals.itemIconTexture:SetPoint("CENTER", itemIconFrame, "CENTER")
itemIconFrame:SetScript("OnEnter", function(self)    -- tooltip
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
    if GrindGoalsDB.itemToFarmID then
        GameTooltip:SetItemByID(GrindGoalsDB.itemToFarmID) -- Get item link from itemID
    end
end)
itemIconFrame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)

GrindGoals.frames.glow = CreateFrame("Frame", "GrindGoals.frames.glow", GrindGoals.frames.mainFrame, "GlowBorderTemplate") -- glowing border for item icon 
GrindGoals.frames.glow:SetSize(62, 62)  -- Width, Height
GrindGoals.frames.glow:SetPoint("CENTER", itemIconFrame, "CENTER", 0, 0)
GrindGoals.frames.glow:Hide()

-- *** Button to open item selection frame ***

GrindGoals.frames.selectItemButton = CreateFrame("Button", "GrindGoals.frames.selectItemButton", GrindGoals.frames.mainFrame, "UIPanelButtonTemplate") -- Button to open item selection frame 
GrindGoals.frames.selectItemButton:SetPoint("CENTER", itemIconFrame, "CENTER", 105, 0)
GrindGoals.frames.selectItemButton:SetSize(125, 35)
GrindGoals.frames.selectItemButton:SetText("Select Item")
GrindGoals.frames.selectItemButton:SetNormalFontObject("GameFontNormalLarge")
GrindGoals.frames.selectItemButton:SetHighlightFontObject("GameFontHighlightLarge")
GrindGoals.frames.selectItemButton:SetScript("OnEnter", function(self)    --tooltip
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Open item selection window.", nil, nil, nil, nil, true)
end)
GrindGoals.frames.selectItemButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)
GrindGoals.frames.selectItemButton:SetScript("OnClick", function() -- script on clicking button
    GrindGoals.frames.itemSelectionFrame:Show()  
end)

-- *** Wowhead URL button ***

GrindGoals.frames.wowhweadButton = CreateFrame("Button", "GrindGoals.frames.selectItemButton", GrindGoals.frames.mainFrame, "UIPanelButtonTemplate") -- Button to open wowhead url frame 
GrindGoals.frames.wowhweadButton:SetPoint("CENTER", GrindGoals.frames.selectItemButton, "CENTER", 130, 0)
GrindGoals.frames.wowhweadButton:SetSize(125, 35)
GrindGoals.frames.wowhweadButton:SetText("Wowhead")
GrindGoals.frames.wowhweadButton:SetNormalFontObject("GameFontNormalLarge")
GrindGoals.frames.wowhweadButton:SetHighlightFontObject("GameFontHighlightLarge")
GrindGoals.frames.wowhweadButton:SetScript("OnEnter", function(self)    --tooltip
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Get Wowhead link for selected item.", nil, nil, nil, nil, true)
end)
GrindGoals.frames.wowhweadButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)
GrindGoals.frames.wowhweadButton:SetScript("OnClick", function() -- script on clicking button
    PlaySound(808)
    if GrindGoalsDB.itemToFarmID then
        GrindGoals.frames.wowhweadUrlFrame:Show()
    else
        GrindGoals.frames.wrongNumberFrame:Show()   -- If item not selected show error frame5
    end

end)

GrindGoals.frames.wowhweadUrlFrame = CreateFrame("Frame", "GrindGoals.frames.wowhweadUrlFrame", GrindGoals.frames.mainFrame, "BackdropTemplate") -- Frame to show wowhead url
GrindGoals.frames.wowhweadUrlFrame:SetSize(320, 130)
GrindGoals.frames.wowhweadUrlFrame:SetPoint("CENTER", GrindGoals.frames.mainFrame, "CENTER", 0, 0) 
GrindGoals.frames.wowhweadUrlFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
GrindGoals.frames.wowhweadUrlFrame:SetBackdropColor(0, 0, 0, 1) 
GrindGoals.frames.wowhweadUrlFrame:Hide()
GrindGoals.frames.wowhweadUrlFrame.wrongNumberString = GrindGoals.frames.wowhweadUrlFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.wowhweadUrlFrame.wrongNumberString:SetPoint("CENTER", GrindGoals.frames.wowhweadUrlFrame, "CENTER", 0, 35)
GrindGoals.frames.wowhweadUrlFrame.wrongNumberString:SetText("Ctrl + C and paste this link to your browser!")

local wowhweadUrlbox = CreateFrame("EditBox", "wowhweadUrlbox ", GrindGoals.frames.wowhweadUrlFrame, "InputBoxTemplate")
wowhweadUrlbox:SetSize(250, 50)
wowhweadUrlbox:SetPoint("CENTER", GrindGoals.frames.wowhweadUrlFrame, "CENTER", 0, 10)
wowhweadUrlbox:SetMaxLetters(200)
wowhweadUrlbox:SetAutoFocus(true)

local wowhweadUrlFrameCloseButton = CreateFrame("Button", "wowhweadUrlFrameCloseButton", GrindGoals.frames.wowhweadUrlFrame, "UIPanelButtonTemplate") -- OK button
wowhweadUrlFrameCloseButton:SetPoint("CENTER", GrindGoals.frames.wowhweadUrlFrame, "CENTER", 0, -25)
wowhweadUrlFrameCloseButton:SetSize(125, 35)
wowhweadUrlFrameCloseButton:SetText("Close")
wowhweadUrlFrameCloseButton:SetNormalFontObject("GameFontNormalLarge")
wowhweadUrlFrameCloseButton:SetHighlightFontObject("GameFontHighlightLarge")
wowhweadUrlFrameCloseButton:SetScript("OnClick", function()
    PlaySound(808)
    GrindGoals.frames.wowhweadUrlFrame:Hide()
end)

GrindGoals.frames.wowhweadUrlFrame:SetScript("OnShow",function ()
    GrindGoals.functions.setFrameOnTop(GrindGoals.frames.wowhweadUrlFrame)
    wowhweadUrlbox :SetText("https://www.wowhead.com/item=" .. GrindGoalsDB.itemToFarmID)
    wowhweadUrlbox:HighlightText()
end)


-- *** Number of items in bags ***

-- NOTE : add bank and warband bank, make into checkboxes
GrindGoals.frames.mainFrame.itemCountString = GrindGoals.frames.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.mainFrame.itemCountString:SetPoint("TOPLEFT", itemIconFrame, "BOTTOMLEFT", 0, -11)


GrindGoals.frames.mainFrame.characterBankCheckbox = CreateFrame("CheckButton", "characterBankCheckbox", GrindGoals.frames.mainFrame, "UICheckButtonTemplate")
GrindGoals.frames.mainFrame.characterBankCheckbox:SetPoint("TOPLEFT", GrindGoals.frames.mainFrame.itemCountString, "TOPLEFT", 0, -15)

GrindGoals.frames.mainFrame.warbandBankCheckbox = CreateFrame("CheckButton", "characterBankCheckbox", GrindGoals.frames.mainFrame, "UICheckButtonTemplate")
GrindGoals.frames.mainFrame.warbandBankCheckbox:SetPoint("TOPLEFT", GrindGoals.frames.mainFrame.characterBankCheckbox, "TOPLEFT", 0, -25)

--[[ -- Creating database settings entry if we dont have that one
if My_CashAndSlashDB.settingsKeys[key] == nil then
    My_CashAndSlashDB.settingsKeys[key] = true
end
-- Displaying checkbox status according to database
checkbox:SetChecked(My_CashAndSlashDB.settingsKeys[key])

checkbox:SetScript("OnEnter", function(self)    
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(checkboxTooltip, nil, nil, nil, nil, true)
end)

checkbox:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)

checkbox:SetScript("OnClick", function(self)
    PlaySound(808)
    My_CashAndSlashDB.settingsKeys[key] = self:GetChecked()
 ]]

-- *** How much do you want to farm line and editBox ***

GrindGoals.frames.mainFrame.itemNumberWantedString = GrindGoals.frames.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.mainFrame.itemNumberWantedString:SetPoint("TOPLEFT", GrindGoals.frames.mainFrame.warbandBankCheckbox, "TOPLEFT", 0, -35)
GrindGoals.frames.mainFrame.itemNumberWantedString:SetText("How many do you need:")

GrindGoals.frames.itemNumberWantedBox = CreateFrame("EditBox", "NumberOfKillsToAnnounceBox", GrindGoals.frames.mainFrame, "InputBoxTemplate") -- Edit box to put the number of items to farm in
GrindGoals.frames.itemNumberWantedBox:SetSize(35, 15)
GrindGoals.frames.itemNumberWantedBox:SetPoint("LEFT", GrindGoals.frames.mainFrame.itemNumberWantedString, "RIGHT", 10, 0)
GrindGoals.frames.itemNumberWantedBox:SetMaxLetters(4)
GrindGoals.frames.itemNumberWantedBox:SetAutoFocus(false)
GrindGoals.frames.itemNumberWantedBox:SetText(tostring(GrindGoalsDB.itemNumberWanted))

GrindGoals.frames.itemNumberWantedBox:SetScript("OnEnter", function(self)    -- Tooltip for the box
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("How many items do you wish to have, 1-9999", nil, nil, nil, nil, true)
end)
GrindGoals.frames.itemNumberWantedBox:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)

GrindGoals.frames.itemNumberWantedBox:SetScript("OnTextChanged", function(self)
    local text = self:GetText()
    local newText = text:gsub("[^0-9]", "") -- Remove all non-numeric characters
    if text ~= newText then
        self:SetText(newText)
    end
end)

-- *** Start / stop grinding BUTTONS ***

GrindGoals.frames.grindButton = CreateFrame("Button", "GrindGoals.frames.grindButton", GrindGoals.frames.mainFrame, "UIPanelButtonTemplate") -- Start farming button
GrindGoals.frames.grindButton:SetPoint("CENTER", GrindGoals.frames.mainFrame.itemNumberWantedString, "LEFT", 60, -35)
GrindGoals.frames.grindButton:SetSize(125, 35)
GrindGoals.frames.grindButton:SetText("Grind!")
GrindGoals.frames.grindButton:SetNormalFontObject("GameFontNormalLarge")
GrindGoals.frames.grindButton:SetHighlightFontObject("GameFontHighlightLarge")
GrindGoals.frames.grindButton:SetScript("OnEnter", function(self)    --tooltip
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Lock in selected item and number and start farming", nil, nil, nil, nil, true)
end)
GrindGoals.frames.grindButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)

GrindGoals.frames.stopGrindButton = CreateFrame("Button", "GrindGoals.frames.grindButton", GrindGoals.frames.mainFrame, "UIPanelButtonTemplate") -- Stop farming
GrindGoals.frames.stopGrindButton:SetPoint("CENTER", GrindGoals.frames.mainFrame.itemNumberWantedString, "LEFT", 190, -35)
GrindGoals.frames.stopGrindButton:SetSize(125, 35)
GrindGoals.frames.stopGrindButton:SetText("Stop!")
GrindGoals.frames.stopGrindButton:SetNormalFontObject("GameFontNormalLarge")
GrindGoals.frames.stopGrindButton:SetHighlightFontObject("GameFontHighlightLarge")
GrindGoals.frames.stopGrindButton:SetScript("OnEnter", function(self)    --tooltip
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Stop farming and unlock the item selection", nil, nil, nil, nil, true)
end)
GrindGoals.frames.stopGrindButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)
GrindGoals.frames.stopGrindButton:Disable() -- Stop button disabled by default

GrindGoals.frames.wrongNumberFrame = CreateFrame("Frame", "GrindGoals.frames.wrongNumberFrame", GrindGoals.frames.mainFrame, "BackdropTemplate") -- Frame to show wrong number message
GrindGoals.frames.wrongNumberFrame:SetSize(270, 110)
GrindGoals.frames.wrongNumberFrame:SetPoint("CENTER", GrindGoals.frames.mainFrame, "CENTER", 0, 0) 
GrindGoals.frames.wrongNumberFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
GrindGoals.frames.wrongNumberFrame:SetBackdropColor(0, 0, 0, 1) 
GrindGoals.frames.wrongNumberFrame.wrongNumberString = GrindGoals.frames.wrongNumberFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.wrongNumberFrame.wrongNumberString:SetPoint("CENTER", GrindGoals.frames.wrongNumberFrame, "CENTER", 0, 20)
GrindGoals.frames.wrongNumberFrame:SetScript("OnShow",function ()
    if GrindGoalsDB.itemToFarmID then
        GrindGoals.frames.wrongNumberFrame.wrongNumberString:SetText("You already have what you wish for!")
    else
        GrindGoals.frames.wrongNumberFrame.wrongNumberString:SetText("You must choose the item first!")
    end
    GrindGoals.functions.setFrameOnTop(GrindGoals.frames.wrongNumberFrame)
    PlaySound(850)
end)

local wrongNumberOkButton = CreateFrame("Button", "wrongNumberOkButton", GrindGoals.frames.wrongNumberFrame, "UIPanelButtonTemplate") -- OK button
wrongNumberOkButton:SetPoint("CENTER", GrindGoals.frames.wrongNumberFrame, "CENTER", 0, -15)
wrongNumberOkButton:SetSize(125, 35)
wrongNumberOkButton:SetText("OK")
wrongNumberOkButton:SetNormalFontObject("GameFontNormalLarge")
wrongNumberOkButton:SetHighlightFontObject("GameFontHighlightLarge")
wrongNumberOkButton:SetScript("OnClick", function()
    PlaySound(808)
    GrindGoals.frames.wrongNumberFrame:Hide()
end)
GrindGoals.frames.wrongNumberFrame:Hide()

-- *** Clicking start / stop buttons ***

-- TODO : Sounds!
GrindGoals.frames.grindButton:SetScript("OnClick", function() -- script on clicking START button
    GrindGoalsDB.itemNumberWanted = tonumber(GrindGoals.frames.itemNumberWantedBox:GetText()) or 0 -- Global for number of items player want (goal)
    if GrindGoalsDB.itemToFarmID and (GrindGoalsDB.itemNumberWanted > GrindGoals.functions.countItemsInBags(GrindGoalsDB.itemToFarmID, "Bags")) then -- Check if player already has that number and item selected
        GrindGoalsDB.isGrinding = true
        GrindGoalsDB.itemNumberInBags = GrindGoals.functions.countItemsInBags(GrindGoalsDB.itemToFarmID, "Bags")
        setGrindState(true)
    else
        GrindGoals.frames.wrongNumberFrame:Show()
    end
    
end)
GrindGoals.frames.stopGrindButton:SetScript("OnClick", function() -- script on clicking STOP button
    print("|cFF00FF00[GrindGoals]|r:  Stopped grinding!")
    GrindGoalsDB.isGrinding = false
    GrindGoalsDB.itemNumberInBags = 0
    setGrindState()
end)

--[[ 
    **************************************************
    * SECTION: Announcment messages in the top of the screen
    **************************************************
--]]

GrindGoals.frames.msgFrame = CreateFrame("FRAME", "GrindGoals.frames.msgFrame", UIParent)
GrindGoals.frames.msgFrame:SetWidth(1)
GrindGoals.frames.msgFrame:SetHeight(1)
GrindGoals.frames.msgFrame:SetPoint("CENTER", UIParent, "TOP", 0, -200)
GrindGoals.frames.msgFrame:SetFrameStrata("TOOLTIP")
GrindGoals.frames.msgFrame.text = GrindGoals.frames.msgFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
GrindGoals.frames.msgFrame.text:SetFont("fonts/2002.ttf", 18, "OUTLINE")  -- Replace with your Gothic font path and desired size
GrindGoals.frames.msgFrame.text:SetTextColor(1.0, 0.84, 0.0) 
GrindGoals.frames.msgFrame.text:SetPoint("CENTER")
GrindGoals.frames.msgFrame:Hide()


--[[ 
    **************************************************
    * SECTION: mainFrame scripts
    **************************************************
--]]

GrindGoals.frames.mainFrame:SetScript("OnHide", function() -- On hide.
    PlaySound(808)
end)
GrindGoals.frames.mainFrame:SetScript("OnShow", function() -- On show.
    PlaySound(808)
    GrindGoals.functions.updateMainframe()
    setGrindState()
end)

--[[ 
    **************************************************
    * SECTION: mainFrame Events
    **************************************************
--]]

-- Create event listner frame
local eventListenerFrame = CreateFrame("Frame", "GrindGoalsEventListenerFrame", UIParent)

local function eventHandler(self, event, ...)

    if event == "ADDON_LOADED" and ... == "GrindGoals" then
    end

    if event == "GET_ITEM_INFO_RECEIVED" then   -- This evrnt fires when game cache recives item info from server t.ex. with C_Item.GetItemInfo
        GrindGoals.functions.updateMainframe()   -- So we need to update mainFrame once more for it to show item info correctly
    end

    if event == "BAG_UPDATE" and GrindGoalsDB.isGrinding then
        GrindGoalsDB.itemNumberInBags = GrindGoals.functions.countItemsInBags(GrindGoalsDB.itemToFarmID, "Bags")
        if GrindGoalsDB.itemNumberInBags >= GrindGoalsDB.itemNumberWanted then
            print("|cFF00FF00[GrindGoals]|r:  Grind goal is reached!")

            local msgText = (
                "Congratulations, " .. UnitName("player") .. 
                "! \nYou've just achieved your goal: " .. (getFarmingItemLink() or "") ..  "  " ..
                GrindGoalsDB.itemNumberInBags .. "/" .. GrindGoalsDB.itemNumberWanted
            )
            PlaySound(SOUNDKIT.IG_QUEST_LIST_COMPLETE)
            GrindGoals.frames.msgFrame.text:SetText(msgText)
            GrindGoals.frames.msgFrame:Show()  -- Show the message
            C_Timer.After(5, function()  -- Schedule the frame to hide after `duration` seconds
                GrindGoals.frames.msgFrame:Hide()
            end)

            GrindGoalsDB.isGrinding = false
            GrindGoalsDB.itemNumberInBags = 0
            setGrindState()
        end
    end


    if GrindGoals.frames.mainFrame:IsShown() then
        GrindGoals.frames.mainFrame.itemCountString:SetText("Number in bags: " .. (
            GrindGoals.functions.countItemsInBags(GrindGoalsDB.itemToFarmID, "Bags") or 0)
        )
    end

end

eventListenerFrame:SetScript("OnEvent", eventHandler)
eventListenerFrame:RegisterEvent("ADDON_LOADED")
eventListenerFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
eventListenerFrame:RegisterEvent("CHAT_MSG_LOOT")
eventListenerFrame:RegisterEvent("BAG_UPDATE")