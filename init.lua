local mq = require('mq')
local imgui = require('ImGui')
local utils = require('utils')

local botCreateSelectedRace = ''
local botCreateSelectedClass = ''
local botCreateSelectedGender = 1
local createBotName = ''
local createBotTitle = ''
local createBotLastName = ''
local createBotSuffix = ''

local ClassRaceIconPadding = 4
local ClassRaceIconSize = 48

local DoSetBotTitle = false
local DoSetBotSurname = false
local DoSetBotSuffix = false

local function drawRaceGrid()
    local drawlist = ImGui.GetWindowDrawList()
    -- Grid Values
    local windowWidth = ImGui.GetWindowSizeVec().x
    local columnCount = math.floor(windowWidth / (ClassRaceIconSize + ClassRaceIconPadding))
    local currentColumn = 1
    local currentRow = 1

    for index, value in ipairs(utils.Races) do
        local prevCursorPos = ImGui.GetCursorPosVec()
        local prevScreenCursorPos = ImGui.GetCursorScreenPosVec()
        local raceTexture
        if botCreateSelectedGender == 1 then
            raceTexture = utils.RaceTextures['M' .. value:gsub("%s+", "")]
        else
            raceTexture = utils.RaceTextures['F' .. value:gsub("%s+", "")]
        end
        ImGui.DrawTextureAnimation(raceTexture, ClassRaceIconSize, ClassRaceIconSize)
        ImGui.SetCursorPos(prevCursorPos)
        if ImGui.InvisibleButton("##RaceBtn" .. index, ImVec2(ClassRaceIconSize, ClassRaceIconSize)) then
            printf("Button: %s Selected", value)
            botCreateSelectedRace = value
            botCreateSelectedClass = ''
        end
        if botCreateSelectedRace == value then
            ImGui.SetCursorPos(prevCursorPos)
            ImGui.SetCursorScreenPos(prevScreenCursorPos)
            local x = prevScreenCursorPos.x + ClassRaceIconSize
            local y = prevScreenCursorPos.y + ClassRaceIconSize
            local color = ImGui.GetColorU32(0, 1, 0, 0.25)
            drawlist:AddRectFilled(prevScreenCursorPos, ImVec2(x, y), color)
        end

        if currentColumn < columnCount then
            ImGui.SameLine(0, ClassRaceIconPadding)
            currentColumn = currentColumn + 1
        elseif currentColumn >= columnCount then
            ImGui.NewLine()
            ImGui.SetCursorPosY(prevCursorPos.y + (ClassRaceIconPadding + ClassRaceIconSize))
            currentRow = currentRow + 1
            currentColumn = 1
        end
    end
end
local function drawClassGrid()
    local drawlist = ImGui.GetWindowDrawList()
    -- Grid Values
    local windowWidth = ImGui.GetWindowSizeVec().x
    local columnCount = math.floor(windowWidth / (ClassRaceIconSize + ClassRaceIconPadding))
    local currentColumn = 1
    local currentRow = 1

    for index, value in ipairs(utils.Classes) do
        local prevCursorPos = ImGui.GetCursorPosVec()
        local prevScreenCursorPos = ImGui.GetCursorScreenPosVec()
        local classTexture = utils.ClassTextures[value:gsub("%s+", "")]
        ImGui.DrawTextureAnimation(classTexture, ClassRaceIconSize, ClassRaceIconSize)
        ImGui.SetCursorPos(prevCursorPos)
        if utils.IsValidRaceClassCombo(botCreateSelectedRace, value) then
            if ImGui.InvisibleButton("##ClassBtn" .. index, ImVec2(ClassRaceIconSize, ClassRaceIconSize)) then
                printf("Button: %s Selected", value)
                botCreateSelectedClass = value
            end
        end
        if botCreateSelectedClass == value then
            ImGui.SetCursorPos(prevCursorPos)
            ImGui.SetCursorScreenPos(prevScreenCursorPos)
            local x = prevScreenCursorPos.x + ClassRaceIconSize
            local y = prevScreenCursorPos.y + ClassRaceIconSize
            local color = ImGui.GetColorU32(0, 1, 0, 0.25)
            drawlist:AddRectFilled(prevScreenCursorPos, ImVec2(x, y), color)
        end
        if not utils.IsValidRaceClassCombo(botCreateSelectedRace, value) then
            ImGui.SetCursorPos(prevCursorPos)
            ImGui.SetCursorScreenPos(prevScreenCursorPos)
            local x = prevScreenCursorPos.x + ClassRaceIconSize
            local y = prevScreenCursorPos.y + ClassRaceIconSize
            local color = ImGui.GetColorU32(1, 0, 0, 0.25)
            drawlist:AddRectFilled(prevScreenCursorPos, ImVec2(x, y), color)
        end

        if currentColumn < columnCount then
            ImGui.SameLine(0, ClassRaceIconPadding)
            currentColumn = currentColumn + 1
        elseif currentColumn >= columnCount then
            ImGui.NewLine()
            ImGui.SetCursorPosY(prevCursorPos.y + (ClassRaceIconPadding + ClassRaceIconSize))
            currentRow = currentRow + 1
            currentColumn = 1
        end
    end
end
local function drawGenderSelectSection()
    ImGui.SetCursorPosX((ImGui.GetWindowSizeVec().x / 3))
    botCreateSelectedGender = ImGui.RadioButton("Male", botCreateSelectedGender, 1)
    ImGui.SameLine()
    botCreateSelectedGender = ImGui.RadioButton("Female", botCreateSelectedGender, 2)
end
local function SetBotTitleEventCallback(botTitle, botName)
    if botTitle == '' then return end

    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^title %s", botTitle:gsub(" ", "_"))
    end
    DoSetBotTitle = false
end

local function SetBotLastNameEventCallback(botLastName, botName)
    if botLastName == '' then return end
    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^lastname %s", botLastName:gsub(" ", "_"))
    end
    DoSetBotSurname = false

end

local function SetBotSuffixEventCallback(botSuffix, botName)
    if botSuffix == '' then return end
    mq.delay(5000, function() return mq.TLO.Spawn(botName)() end)
    if mq.TLO.Spawn(botName)() then
        mq.cmdf('/target "%s"', botName)
        mq.delay(250)
        mq.cmdf("/say ^suffix %s", botSuffix:gsub(" ", "_"))
    end
    DoSetBotSuffix = false
end

local function drawNameAndDetailsSection()
    local textInputPadding = 16
    local firstCursorPos = ImGui.GetCursorPosVec()
    local quarterY = (ImGui.GetWindowSizeVec().y - ImGui.GetCursorPosY()) / 4
    local CenterX = (ImGui.GetWindowSizeVec().x - ImGui.GetCursorPosX()) / 2
    ImGui.SetCursorPosY(ImGui.GetCursorPosY() + textInputPadding)
    ImGui.SetNextItemWidth(CenterX)
    createBotTitle = ImGui.InputTextWithHint("##BotTitle", "Enter a Bot Title (Optional)...", createBotTitle)
    ImGui.SetCursorPosY(ImGui.GetCursorPosY() + textInputPadding)
    ImGui.SetNextItemWidth(CenterX)
    createBotName = ImGui.InputTextWithHint("##BotName", "Enter a Bot Name...", createBotName)
    ImGui.SetCursorPosY(ImGui.GetCursorPosY() + textInputPadding)
    ImGui.SetNextItemWidth(CenterX)
    createBotLastName = ImGui.InputTextWithHint("##BotLastName", "Enter a Bot Last Name (Optional)...", createBotLastName)
    ImGui.SetCursorPosY(ImGui.GetCursorPosY() + textInputPadding)
    ImGui.SetNextItemWidth(CenterX)
    createBotSuffix = ImGui.InputTextWithHint("##BotSuffix", "Enter a Bot Suffix (Optional)...", createBotSuffix)
    ImGui.SetCursorPos(ImVec2(CenterX + 16, firstCursorPos.y))
    ImGui.Text("Bot Name: %s", createBotName)
    ImGui.SetCursorPosX(CenterX + 16)
    ImGui.Text("Race: %s", botCreateSelectedRace)
    ImGui.SetCursorPosX(CenterX + 16)
    ImGui.Text("Class: %s", botCreateSelectedClass)
    ImGui.SetCursorPosX(CenterX + 16)
    if botCreateSelectedGender == 1 then
        ImGui.Text("Gender/Sex: Male")
    elseif botCreateSelectedGender == 2 then
        ImGui.Text("Gender/Sex: Female")
    end
    ImGui.SetCursorPosX(CenterX + 16)
    if ImGui.Button("Create Bot", ImVec2(96, 32)) then
        if botCreateSelectedClass and botCreateSelectedGender and botCreateSelectedRace and createBotName then
            local createCmd = '^botcreate ' .. createBotName
            createCmd = createCmd .. ' ' .. utils.ClassIDs[botCreateSelectedClass:gsub("%s+", "")]
            createCmd = createCmd .. ' ' .. utils.RaceIds[botCreateSelectedRace:gsub("%s+", "")]
            if botCreateSelectedGender == 1 then
                createCmd = createCmd .. ' 0'
            elseif botCreateSelectedGender == 2 then
                createCmd = createCmd .. ' 1'
            end
            mq.cmdf("/say %s", createCmd)
            mq.cmdf("/say ^botspawn %s", createBotName)
            DoSetBotTitle = true
            DoSetBotSuffix = true
            DoSetBotSurname = true
        else
            printf("Invalid or Missing Options Selected")
        end
    end
end


local function drawCreateBotScreen()
    ImGui.SetCursorPosX(16)
    utils.CenterText("Create A Bot")
    ImGui.SeparatorText("Races")
    drawRaceGrid()
    ImGui.NewLine()
    ImGui.SeparatorText("Classes")
    drawClassGrid()
    ImGui.NewLine()
    ImGui.SeparatorText("Gender/Sex")
    drawGenderSelectSection()
    ImGui.NewLine()
    ImGui.SeparatorText("Name and Details")
    drawNameAndDetailsSection()
end

local Running = true
local showBuildABot, openBuildABot = true, true
local function guiLoop()
    openBuildABot, showBuildABot = ImGui.Begin("BuildABot", showBuildABot)
    if not openBuildABot then mq.exit() end
    if showBuildABot then
        ImGui.SetWindowSize("BuildABot", ImVec2(512, 768), ImGuiCond.Always)
        drawCreateBotScreen()
    end
    ImGui.End()
end


mq.imgui.init("BuildABot", guiLoop)
local function main()
    while Running do
        mq.delay(10)
        if DoSetBotTitle then
            SetBotTitleEventCallback(createBotTitle, createBotName)
        end
        if DoSetBotSurname then
            SetBotLastNameEventCallback(createBotLastName, createBotName)
        end
        if DoSetBotSuffix then
            SetBotSuffixEventCallback(createBotSuffix, createBotName)
        end
    end
end

main()
