function onCreate()
    makeLuaSprite('blackOverlay', '', 0, 0)
    makeGraphic('blackOverlay', 1280, 720, '000000')
    setObjectCamera('blackOverlay', 'other')
    setProperty('blackOverlay' .. '.alpha', 1)
    addLuaSprite('blackOverlay', true)
end

function onSongStart()
    fadeOverlay(0, 13)
end

function onStepHit()
    if curStep == 512 then
        fadeOverlay(0.4, 1.2)
        zoomCamera(1.2, 25)
    elseif curStep == 760 then
        fadeOverlay(1, 0.01)
        zoomCamera(0.95, 1)
    elseif curStep == 768 then
        fadeOverlay(0, 0.01)
    elseif curStep == 1152 then
        zoomCamera(1.2, 2)
    elseif curStep == 1168 then
        fadeOverlay(1, 4)
        zoomCamera(0.95, 1)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'zoomHold' then
        setProperty('defaultCamZoom', 0.95)
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
