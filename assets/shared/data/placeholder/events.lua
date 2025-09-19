local circles = {}
local circleSpeed = 200
local circleBopAmount = 0.2
local circleBopTime = 0.1
local circleBopNextBeat = 4

local circleScroll = {}
local circleScrollSpeed = 200
local circleScrollWidth = 1529

local function safeSet(prop, val)
    pcall(function()
        setProperty(prop, val)
    end)
end

local function applyStageConfig(cfg)
    for prop, val in pairs(cfg) do
        if type(val) == "table" then
            safeSet(prop .. "[0]", val[1])
            safeSet(prop .. "[1]", val[2])
        else
            safeSet(prop, val)
        end
    end
end

local function clearSprites(list)
    for _, id in ipairs(list) do
        removeLuaSprite(id, true)
    end
end

local function clearList(list)
    for _, item in ipairs(list) do
        removeLuaSprite(item.id, true)
    end
    return {}
end

local function buildCircles()
    circles = clearList(circles)
    local dadOrder = getObjectOrder('dadGroup') or 1
    local id, size, x, y = 'circle', 1, -200, 484

    makeLuaSprite(id, 'fuckingcircle', x, y)
    scaleObject(id, size, size)
    setObjectCamera(id, 'game')
    addLuaSprite(id, false)
    setObjectOrder(id, dadOrder - 1)

    local circle = {
        id = id,
        x = x,
        speedX = circleSpeed,
        bopTimer = 0,
        scaleX = size,
        scaleY = size
    }
    circle.propX = id .. ".x"
    circle.propScaleX = id .. ".scale.x"
    circle.propScaleY = id .. ".scale.y"

    table.insert(circles, circle)
end

local function updateCircles(elapsed)
    for _, c in ipairs(circles) do
        c.x = c.x + c.speedX * elapsed
        if c.x > 1280 + 50 then
            c.x = -200
        end
        setProperty(c.propX, c.x)

        if c.bopTimer > 0 then
            c.bopTimer = c.bopTimer - elapsed
            local scale = 1 + circleBopAmount * (c.bopTimer / circleBopTime)
            setProperty(c.propScaleX, c.scaleX * scale)
            setProperty(c.propScaleY, c.scaleY * scale)
        end
    end
end

local function buildCircleScroll()
    circleScroll = clearList(circleScroll)
    local dadOrder = getObjectOrder('dadGroup') or 1

    for i = 0, 1 do
        local id = 'circleScroll' .. i
        makeLuaSprite(id, 'fuckingcirclescroll', i * circleScrollWidth, 0)
        setObjectCamera(id, 'hud')
        addLuaSprite(id, true)
        setObjectOrder(id, dadOrder - 1)

        local scroll = {
            id = id,
            x = i * circleScrollWidth,
            bopTimer = 0
        }
        scroll.propX = id .. ".x"
        scroll.propScaleX = id .. ".scale.x"
        scroll.propScaleY = id .. ".scale.y"

        table.insert(circleScroll, scroll)
    end
end

local function updateCircleScroll(elapsed)
    local minX
    for _, c in ipairs(circleScroll) do
        c.x = c.x + circleScrollSpeed * elapsed
    end

    minX = math.huge
    for _, c in ipairs(circleScroll) do
        if c.x < minX then
            minX = c.x
        end
    end

    for _, c in ipairs(circleScroll) do
        if c.x >= circleScrollWidth then
            c.x = minX - circleScrollWidth
        end
        setProperty(c.propX, c.x)

        if c.bopTimer > 0 then
            c.bopTimer = c.bopTimer - elapsed
            local scale = 1 + circleBopAmount * (c.bopTimer / circleBopTime)
            setProperty(c.propScaleX, scale)
            setProperty(c.propScaleY, scale)
        end
    end
end

local function buildStage(stage)
    clearSprites({'scrapped', 'place', 'fuckingchair'})
    circles, circleScroll = clearList(circles), clearList(circleScroll)

    if stage == 'scrapped' then
        makeAnimatedLuaSprite('scrapped', 'bgscrapped', -82, 19)
        addAnimationByPrefix('scrapped', 'idle', 'bgscrapped idle', 12, true)
        objectPlayAnimation('scrapped', 'idle', true)
        setScrollFactor('scrapped', 1, 1)
        setProperty('scrapped.antialiasing', true)
        addLuaSprite('scrapped', false)
        local dadOrder = getObjectOrder('dadGroup')
        if dadOrder then
            setObjectOrder('scrapped', dadOrder - 1)
        end
        applyStageConfig({
            ["gfGroup.x"] = 400,
            ["gfGroup.y"] = 130,
            ["gfGroup.alpha"] = 0,
            ["dadGroup.x"] = 735,
            ["dadGroup.y"] = 140,
            ["boyfriendGroup.x"] = 910,
            ["boyfriendGroup.y"] = 320,
            opponentCameraOffset = {14, 152},
            boyfriendCameraOffset = {102, 275},
            girlfriendCameraOffset = {0, 0},
            defaultCamZoom = 0.8
        })
    elseif stage == 'place' then
        makeAnimatedLuaSprite('place', 'place', 238, 245)
        addAnimationByPrefix('place', 'idle', 'place idle', 12, true)
        objectPlayAnimation('place', 'idle', true)
        setScrollFactor('place', 1, 1)
        setProperty('place.antialiasing', false)
        addLuaSprite('place', false)

        makeAnimatedLuaSprite('fuckingchair', 'fuckingchair', 238, 245)
        addAnimationByPrefix('fuckingchair', 'idle', 'fuckingchair idle', 12, true)
        objectPlayAnimation('fuckingchair', 'idle', true)
        setScrollFactor('fuckingchair', 1, 1)
        setProperty('fuckingchair.antialiasing', false)
        addLuaSprite('fuckingchair', false)

        local dadOrder = getObjectOrder('dadGroup')
        if dadOrder then
            setObjectOrder('place', dadOrder - 2)
            buildCircles()
            setObjectOrder('fuckingchair', dadOrder - 1)
            buildCircleScroll()
        end

        applyStageConfig({
            ["gfGroup.x"] = 400,
            ["gfGroup.y"] = 130,
            ["gfGroup.alpha"] = 0,
            ["dadGroup.x"] = 285,
            ["dadGroup.y"] = 75,
            ["boyfriendGroup.x"] = 730,
            ["boyfriendGroup.y"] = -60,
            opponentCameraOffset = {165, -60},
            boyfriendCameraOffset = {150, 112},
            girlfriendCameraOffset = {0, 0},
            defaultCamZoom = 1.4
        })
    end
end

function onCreate()
    math.randomseed(os.time())
    buildStage('place')

    makeLuaSprite('evilImage', 'theevilfuckingimage', 0, 0)
    setObjectCamera('evilImage', 'hud')
    scaleObject('evilImage', 1.25, 1.25)
    addLuaSprite('evilImage', true)

    makeLuaSprite('blackOverlay', '', 0, 0)
    makeGraphic('blackOverlay', 1280, 720, '000000')
    setObjectCamera('blackOverlay', 'other')
    setProperty('blackOverlay' .. '.alpha', 1)
    addLuaSprite('blackOverlay', true)

    makeLuaText('placeholderTxt', "THIS SONG IS A PLACEHOLDER.", 0, 0, 0)
    setTextAlignment('placeholderTxt', 'center')
    setTextSize('placeholderTxt', 64)
    setObjectCamera('placeholderTxt', 'hud')
    screenCenter('placeholderTxt', 'x')
    setProperty('placeholderTxt.alpha', 0)
    addLuaText('placeholderTxt')
end

function onSongStart()
    fadeOverlay(0, 12)
end

function onUpdate(elapsed)
    updateCircles(elapsed)
    updateCircleScroll(elapsed)
end

function onBeatHit()
    if curBeat % circleBopNextBeat == 0 then
        for _, c in ipairs(circles) do
            c.bopTimer = circleBopTime
        end
    end
end

function onStepHit()
    if curStep == 87 then
        doTweenAngle('evilImageTweenAngle', 'evilImage', 360, 8, 'quartInOut')
        doTweenY('evilImageTweenY', 'evilImage', 1400, 6, 'quartInOut')
    elseif curStep == 100 then
        screenCenter('placeholderTxt', 'xy')
        setProperty('placeholderTxt.alpha', 1)
        doTweenX('placeholderTxtXScale', 'placeholderTxt.scale', 1.13, 1.2, 'elasticOut');
        doTweenY('placeholderTxtYScale', 'placeholderTxt.scale', 1.13, 1.2, 'elasticOut');
        runTimer('dropPlaceholder', 1)
    elseif curStep == 256 then
        for _, c in ipairs(circles) do
            c.speedX = c.speedX * 2.5
        end
        circleBopNextBeat = 1
    elseif curStep == 374 then
        fadeOverlay(0.4, 0.9)
        zoomCamera(1.9, 2)
    elseif curStep == 384 then
        fadeOverlay(0, 0.7)
        zoomCamera(1.4, 1)
    elseif curStep == 512 then
        fadeOverlay(0.4, 0.9)
        zoomCamera(2, 12)
    elseif curStep == 640 then
        for _, c in ipairs(circles) do
            c.speedX = c.speedX / 2.5
        end
        circleBopNextBeat = 4
        fadeOverlay(0, 0.7)
        zoomCamera(1.4, 1)
    elseif curStep == 896 then
        fadeOverlay(0.4, 2)
    elseif curStep == 1152 then
        fadeOverlay(0, 0.01)
        cameraFlash('game', 'FFFFFF', 0.5, true)
        buildStage('scrapped')
    elseif curStep == 1408 then
        cameraFlash('game', 'FFFFFF', 0.5, true)
        buildStage('place')
    elseif curStep == 1664 then
        fadeOverlay(1, 15)
    end
end

function onTimerCompleted(tag)
    if tag == 'dropPlaceholder' then
        doTweenAngle('placeholderDropAngle', 'placeholderTxt', 360, 4, 'quartInOut')
        doTweenY('placeholderDropTweenY', 'placeholderTxt', 1400, 3, 'quartInOut')
    end
end

function fadeOverlay(targetAlpha, duration)
    doTweenAlpha('fadeBlack', 'blackOverlay', targetAlpha, duration, 'linear')
end

function zoomCamera(zoomLevel, holdTime)
    setProperty('defaultCamZoom', zoomLevel)
    if holdTime and holdTime > 0 then
        runTimer('zoomHold', holdTime)
    end
end
