-- This addon lets you set your goals for daily grind (number of items) and informs when its reached.
-- This is the file for addon main frame and globals

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
    GrindGoals.itemIconTexture
} ]]


-- Create variable for information storage.
GrindGoalsDB = GrindGoalsDB or {itemToFarmID =nil}


-- Function that checks how many of certan item player has in his bags
function GrindGoals.functions.countItemsInBags(itemID)
    if itemID == nil then
        return nil
    end
    local count = 0
    for bag = 0, 5 do -- Loop through all bags
        for slot = 1, C_Container.GetContainerNumSlots(bag) do -- Loop through all slots in the bag
            local id = C_Container.GetContainerItemID(bag, slot)
            if id == itemID then
                count = count + C_Container.GetContainerItemInfo(bag, slot).stackCount
            end
        end
    end
    return count
end

-- Function for setting frame as top frame
function GrindGoals.functions.setFrameOnTop(self)
    if GrindGoals.topmostFrame then
        GrindGoals.topmostFrame:SetFrameLevel(1)  -- Reset the previous top frame's level
    end
    self:SetFrameStrata("HIGH")  -- Adjust this as needed
    self:SetFrameLevel(100)  -- Push the current frame to the top
    GrindGoals.topmostFrame = self  -- Set this frame as the new topmost
end

local function getFarmingItemLink()  -- Get item link from GrindGoalsDB.itemToFarmID
    local itemToFarmLink =""
    if GrindGoalsDB.itemToFarmID then
        _, itemToFarmLink = C_Item.GetItemInfo(GrindGoalsDB.itemToFarmID)
    else
        itemToFarmLink = "[No item selected!]"
    end
    return itemToFarmLink
end

--Create main frame for addon
GrindGoals.frames.mainFrame = CreateFrame("Frame", "GrindGoalsMainFrame", UIParent, "BasicFrameTemplateWithInset")
GrindGoals.frames.mainFrame:SetSize(400, 250)
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
    if not GrindGoals.frames.itemSelectionFrame:IsShown() then
        GrindGoals.functions.setFrameOnTop(self)
    end
end)

-- Adding frame to WoW special list to make it closeable by Esc
table.insert(UISpecialFrames, "GrindGoalsMainFrame")

-- Making frame resizable
local resizeHandle = CreateFrame("Frame", "ResizeHandle", GrindGoals.frames.mainFrame)
resizeHandle:SetSize(16, 16)
resizeHandle:SetPoint("BOTTOMRIGHT", GrindGoals.frames.mainFrame, "BOTTOMRIGHT", -4, 4)
local isResizing = false
local function OnMouseDown(self, button)
    if button == "LeftButton" then
        isResizing = true
        self:GetParent()._resizeStartWidth = self:GetParent():GetWidth()
        self:GetParent()._resizeStartHeight = self:GetParent():GetHeight()
        self:GetParent()._resizeStartX, self:GetParent()._resizeStartY = GetCursorPosition()
    end
end

local function OnMouseUp(self, button)
    if button == "LeftButton" then
        isResizing = false
        self:GetParent():StopMovingOrSizing()
    end
end

local function OnUpdate(self)
    if isResizing then
        local x, y = GetCursorPosition()
        local scale = self:GetParent():GetEffectiveScale()
        local dx = (x - self:GetParent()._resizeStartX) / scale
        local dy = (y - self:GetParent()._resizeStartY) / scale
        local newWidth = self:GetParent()._resizeStartWidth + dx
        local newHeight = self:GetParent()._resizeStartHeight - dy
        
        self:GetParent():SetSize(math.max(100, newWidth), math.max(100, newHeight))
    end
end

resizeHandle:SetScript("OnMouseDown", OnMouseDown)
resizeHandle:SetScript("OnMouseUp", OnMouseUp)
resizeHandle:SetScript("OnUpdate", OnUpdate)

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



--                                         !!! Content of main frame !!!

function GrindGoals.functions.updateMainframe()      -- This function updates information in mainFrame
    GrindGoals.frames.mainFrame.itemLinkString:SetText("Item to grind: " .. getFarmingItemLink())
    GrindGoals.frames.mainFrame.itemCountString:SetText("Number in bags: " .. (GrindGoals.functions.countItemsInBags(GrindGoalsDB.itemToFarmID) or 0))
    if GrindGoalsDB.itemToFarmID then          -- Update item icon
        local _, _, _, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(GrindGoalsDB.itemToFarmID)
        GrindGoals.itemIconTexture:SetTexture(itemIcon)
    else
        GrindGoals.itemIconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")  -- Placeholder icon
    end
end

GrindGoals.frames.mainFrame.itemLinkString = GrindGoals.frames.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.mainFrame.itemLinkString:SetPoint("TOPLEFT", GrindGoals.frames.mainFrame, "TOPLEFT", 15, -35)

local itemIconFrame = CreateFrame("Frame", "itemIconFrame", GrindGoals.frames.mainFrame, "BackdropTemplate")
itemIconFrame:SetSize(64, 64)  -- Width, Height
itemIconFrame:SetPoint("TOPLEFT", GrindGoals.frames.mainFrame.itemLinkString, "TOPLEFT", 0, -15)  -- Position on the screen
itemIconFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
itemIconFrame:SetBackdropColor(0, 0, 0, 1)  -- Black background
-- Create the item icon texture
GrindGoals.itemIconTexture = itemIconFrame:CreateTexture(nil, "ARTWORK")
GrindGoals.itemIconTexture:SetSize(40, 40)  -- Icon size
GrindGoals.itemIconTexture:SetPoint("CENTER", itemIconFrame, "CENTER")
itemIconFrame:SetScript("OnEnter", function(self)    --tooltip
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
    if GrindGoalsDB.itemToFarmID then
        GameTooltip:SetItemByID(GrindGoalsDB.itemToFarmID)
    end
end)
itemIconFrame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)

GrindGoals.frames.mainFrame.itemCountString = GrindGoals.frames.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GrindGoals.frames.mainFrame.itemCountString:SetPoint("TOPLEFT", GrindGoals.frames.mainFrame.itemLinkString, "TOPLEFT", 0, -80)


-- Button to open item selection frame
local selectItemButton = CreateFrame("Button", "selectItemButton", GrindGoals.frames.mainFrame, "UIPanelButtonTemplate")
selectItemButton:SetPoint("BOTTOMRIGHT", GrindGoals.frames.mainFrame, "TOPRIGHT", -100, -100)
selectItemButton:SetSize(125, 35)
selectItemButton:SetText("Select Item")
selectItemButton:SetNormalFontObject("GameFontNormalLarge")
selectItemButton:SetHighlightFontObject("GameFontHighlightLarge")
selectItemButton:SetScript("OnEnter", function(self)    --tooltip
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Open item selection window.", nil, nil, nil, nil, true)
end)
selectItemButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()        
end)
selectItemButton:SetScript("OnClick", function() -- script on clicking button
    GrindGoals.frames.itemSelectionFrame:Show()  
end)


--                                           !!! mainFrame scripts !!!

GrindGoals.frames.mainFrame:SetScript("OnHide", function() -- On hide.
    PlaySound(808)
end)
GrindGoals.frames.mainFrame:SetScript("OnShow", function() -- On show.
    PlaySound(808)
    GrindGoals.functions.updateMainframe()

end)

--                                               !!! EVENTS !!! 

-- Create event listner frame
local eventListenerFrame = CreateFrame("Frame", "GrindGoalsEventListenerFrame", UIParent)

local function eventHandler(self, event, ...)




    if GrindGoals.frames.mainFrame:IsShown() then
        GrindGoals.frames.mainFrame.itemCountString:SetText("Number in bags: " .. (
            GrindGoals.functions.countItemsInBags(GrindGoalsDB.itemToFarmID) or 0)
        )
    end

end





eventListenerFrame:SetScript("OnEvent", eventHandler)





GrindGoals.frames.mainFrame:Show()
