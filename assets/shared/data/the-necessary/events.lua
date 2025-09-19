local allowHunglings = false
local hunglings = {}
local jungries = {}
local screenWidth = 1400
local spawnTimer = 0
local spawnInterval = 4
local startXLeft = -200
local startXRight = 1500
local baseY = 560

function onCreate()
    if luaSpriteExists('hungling1') then
        setProperty('hungling1.visible', false)
    end
    if luaSpriteExists('hungling2') then
        setProperty('hungling2.visible', false)
    end
    if luaSpriteExists('Jungry') then
        setProperty('Jungry.visible', false)
    end

    makeLuaSprite('blackOverlay', '', 0, 0)
    makeGraphic('blackOverlay', 1280, 720, '000000')
    setObjectCamera('blackOverlay', 'other')
    setProperty('blackOverlay.alpha', 0)
    addLuaSprite('blackOverlay', true)
end

function onUpdate(elapsed)
    if allowHunglings then
        for _, h in ipairs(hunglings) do
            local newX = getProperty(h.id .. '.x') + h.speed * elapsed
            setProperty(h.id .. '.x', newX)
            if h.speed > 0 and newX > screenWidth + 200 or h.speed < 0 and newX < -200 then
                removeLuaSprite(h.id, true)
                h.remove = true
            end
        end
        for _, j in ipairs(jungries) do
            local newX = getProperty(j.id .. '.x') + j.speed * elapsed
            setProperty(j.id .. '.x', newX)
            if j.speed > 0 and newX > screenWidth + 200 or j.speed < 0 and newX < -200 then
                removeLuaSprite(j.id, true)
                j.remove = true
            end
        end
        for i = #hunglings, 1, -1 do
            if hunglings[i].remove then
                table.remove(hunglings, i)
            end
        end
        for i = #jungries, 1, -1 do
            if jungries[i].remove then
                table.remove(jungries, i)
            end
        end
        spawnTimer = spawnTimer + elapsed
        if spawnTimer >= spawnInterval then
            spawnTimer = 0
            spawnHungling()
            if math.random() < 0.4 then
                spawnHungling()
            end
            if math.random() < 0.25 then
                spawnJungry()
            end
        end
    end
end

function spawnHungling()
    local type = (math.random(1, 2) == 1) and 'hungling1' or 'hungling2'
    local cloneId = type .. '_clone' .. tostring(math.random(10000, 99999))
    local goingRight = math.random(1, 2) == 1
    local startX = goingRight and startXLeft or startXRight
    local direction = goingRight and 1 or -1

    makeAnimatedLuaSprite(cloneId, type, startX, baseY)
    if type == 'hungling1' then
        addAnimationByPrefix(cloneId, 'move', 'hungling1 jump', 12, true)
    else
        addAnimationByPrefix(cloneId, 'move', 'hungling2 eatatakirun', 12, true)
    end
    objectPlayAnimation(cloneId, 'move', true)
    setProperty(cloneId .. '.antialiasing', false)
    if not goingRight then
        setProperty(cloneId .. '.flipX', true)
    end
    local scale = 0.9 + math.random() * 0.2
    scaleObject(cloneId, scale, scale)
    local maxOrder = math.max(getObjectOrder('gfGroup') or 20, getObjectOrder('stage') or 0)
    setObjectOrder(cloneId, maxOrder + 1)
    addLuaSprite(cloneId, false)

    table.insert(hunglings, {
        id = cloneId,
        speed = math.random(160, 320) * direction
    })
end

function spawnJungry()
    local cloneId = 'jungry_clone' .. tostring(math.random(10000, 99999))
    local goingRight = math.random(1, 2) == 1
    local startX = goingRight and startXLeft or startXRight
    local direction = goingRight and 1 or -1

    makeAnimatedLuaSprite(cloneId, 'Jungry', startX, baseY)
    addAnimationByPrefix(cloneId, 'move', 'Jungry', 12, true)
    objectPlayAnimation(cloneId, 'move', true)
    setProperty(cloneId .. '.antialiasing', false)
    if not goingRight then
        setProperty(cloneId .. '.flipX', true)
    end
    local scale = 1.0 + (math.random() * 0.2 - 0.1)
    scaleObject(cloneId, scale, scale)
    local maxOrder = math.max(getObjectOrder('gfGroup') or 20, getObjectOrder('stage') or 0)
    setObjectOrder(cloneId, maxOrder + 1)
    addLuaSprite(cloneId, false)

    table.insert(jungries, {
        id = cloneId,
        speed = math.random(120, 240) * direction
    })
end

function onStepHit()
    if curStep == 64 or curStep == 128 or curStep == 192 or curStep == 256 or curStep == 1856 or curStep == 1920 then
        setProperty('defaultCamZoom', 1.65)
        runTimer('zoomHold', 2)
    elseif curStep == 80 or curStep == 144 or curStep == 208 or curStep == 272 or curStep == 1872 or curStep == 1936 then
        setProperty('defaultCamZoom', 1.75)
        runTimer('zoomHold', 2)
    elseif curStep == 96 or curStep == 160 or curStep == 224 or curStep == 288 or curStep == 1888 or curStep == 1952 then
        setProperty('defaultCamZoom', 1.85)
        runTimer('zoomHold', 2)
    elseif curStep == 112 or curStep == 176 or curStep == 240 or curStep == 304 or curStep == 1904 or curStep == 1968 then
        setProperty('defaultCamZoom', 2.05)
        runTimer('zoomHold', 2)
    elseif curStep == 320 then
        allowHunglings = true
        setProperty('defaultCamZoom', 1.5)
        runTimer('zoomHold', 2)
    elseif curStep == 576 or curStep == 608 or curStep == 640 or curStep == 672 or curStep == 704 or curStep == 736 or
        curStep == 768 or curStep == 800 or curStep == 1472 or curStep == 1504 or curStep == 1568 or curStep == 1600 or
        curStep == 1632 or curStep == 1664 or curStep == 1696 then
        fadeOverlay(0.4, 0.9)
        setProperty('defaultCamZoom', 1.75)
        runTimer('zoomHold', 1)
    elseif curStep == 832 or curStep == 1728 or curStep == 1792 then
        fadeOverlay(0, 0.9)
    elseif curStep == 944 then
        setProperty('defaultCamZoom', 1.75)
        runTimer('zoomHold', 1)
    elseif curStep == 951 then
        setProperty('defaultCamZoom', 1.85)
        runTimer('zoomHold', 1)
    elseif curStep == 956 then
        setProperty('defaultCamZoom', 2)
        runTimer('zoomHold', 1)
    elseif curStep == 960 then
        setProperty('defaultCamZoom', 1.5)
        runTimer('zoomHold', 1)
    elseif curStep == 1216 then
        fadeOverlay(0.4, 0.9)
    elseif curStep == 1471 then
        fadeOverlay(0.4, 0.9)
    elseif curStep == 1776 then
        fadeOverlay(0.4, 0.9)
    elseif curStep == 1984 then
        setProperty('defaultCamZoom', 1.5)
        runTimer('zoomHold', 2)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'zoomHold' then
        setProperty('defaultCamZoom', 1.5)
    end
end

function fadeOverlay(targetAlpha, duration)
    doTweenAlpha('fadeBlack', 'blackOverlay', targetAlpha, duration, 'linear')
end

function onSpawnNote(i)
    if not getPropertyFromGroup('notes', i, 'mustPress') then
        setPropertyFromGroup('notes', i, 'multSpeed', 1.71)
    end
end
