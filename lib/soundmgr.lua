module ( "soundmgr", package.seeall )

local SOUNDSYSTEM = ""
local FMOD_channels ={}
local FMOD_currentchannel = 0
local FMOD_musicchannel = nil
local lastmusic = nil

function init(pSoundSystems, pFMODChannels,pUNTZSampleRate,pUNTZnumFrames)

  print ("soundmgr.init : testing")
  
  SOUNDSYSTEM = ""
  local soundsystems
  if pSoundSystems then
    if type(pSoundSystems)=="string" then
      soundsystems = {pSoundSystems}
    else
      soundsystmes = pSoundSystems
    end
  else
    soundsystems = {"UNTZ","FMOD"}
  end

  for i,v in ipairs(soundsystems) do
    print ("soundmgr.init : testing "..v)
    if v=="FMOD" then
      if MOAIFmodEx and MOAIFmodEx.init then
        if pcall(MOAIFmodEx.init,MOAIFmodEx) then
          SOUNDSYSTEM=v
          break
        end
      end
    elseif v=="UNTZ" then
      if MOAIUntzSystem and MOAIUntzSystem.initialize then
        if pcall(MOAIUntzSystem.initialize,pUNTZSampleRate, pUNTZnumFrames) then
          SOUNDSYSTEM=v
          break
        end
      end
    end
    print ("soundmgr.init : testing "..v .. " ko!!!")
  end

  print ("soundmgr.init : choosed "..SOUNDSYSTEM or "(NO AUDIO)")

  if SOUNDSYSTEM=="FMOD" then
    local numchannels = pchannels or 16
    for i=1,numchannels do
      local newchannel = MOAIFmodExChannel.new()
      table.insert(FMOD_channels,newchannel)
    end
    FMOD_currentchannel = 0
  elseif SOUNDSYSTEM=="UNTZ" then
  end
end

function newSound (pfile)
  local newSound
  if SOUNDSYSTEM=="FMOD" then
    newSound = MOAIFmodExSound .new()
    newSound:loadSFX(pfile)
  elseif SOUNDSYSTEM=="UNTZ" then
    newSound = MOAIUntzSound.new()
    newSound:load(pfile)
  end
  return newSound
end

function newMusic (pfile)
  local newMusic
  if SOUNDSYSTEM=="FMOD" then
    newMusic = MOAIFmodExSound .new()
    newMusic:loadBGM(pfile)
  elseif SOUNDSYSTEM=="UNTZ" then
    newMusic = MOAIUntzSound.new()
    newMusic:load(pfile)
  end
  return newMusic
end

function playSound (psound,pvolume)
  if SOUNDSYSTEM=="FMOD" then
    if #FMOD_channels < FMOD_currentchannel then
      FMOD_currentchannel = 1
    else
      FMOD_currentchannel = FMOD_currentchannel + 1
    end
    if pvolume then
      FMOD_channels[FMOD_currentchannel]:setVolume(pvolume)
    else
      FMOD_channels[FMOD_currentchannel]:setVolume(1)
    end
    FMOD_channels[FMOD_currentchannel]:play(psound)
    FMOD_channels[FMOD_currentchannel].sound=psound
  elseif SOUNDSYSTEM=="UNTZ" then
    if pvolume then
      psound:setVolume(pvolume)
    else
      psound:setVolume(1)
    end
    psound:setPosition(0)
    psound:setLooping(false)
    psound:play()
  end
end

function playMusic (pmusic,pvolume)
  if lastmusic and lastmusic~=pmusic then
    stop(lastmusic)
  end
  if SOUNDSYSTEM=="FMOD" then
    if FMOD_musicchannel == nil then
      FMOD_musicchannel = MOAIFmodExChannel.new()
    end
    if pvolume then
      FMOD_musicchannel:setVolume(pvolume)
    else
      FMOD_musicchannel:setVolume(1)
    end
    FMOD_musicchannel:play(pmusic,true)
    FMOD_musicchannel.sound=pmusic
  elseif SOUNDSYSTEM=="UNTZ" then
    if not pmusic:isPlaying() then
      if pvolume then
        pmusic:setVolume(pvolume)
      else
        pmusic:setVolume(1)
      end
      pmusic:setPosition(0)
      pmusic:setLooping(true)
      pmusic:play()
    end
  end
  lastmusic = pmusic
end

function stop (psound)
  if SOUNDSYSTEM=="FMOD" then
    if FMOD_musicchannel and FMOD_musicchannel.sound and FMOD_musicchannel.sound==psound then
      FMOD_musicchannel:stop()
    end
    for i,v in pairs(FMOD_channels) do
      if v and v.sound and v.sound==psound then
        v:stop()
      end
    end
  elseif SOUNDSYSTEM=="UNTZ" then
    psound:stop()
  end
end

function setVolume (psound,pvolume)
  if SOUNDSYSTEM=="FMOD" then
    if FMOD_musicchannel and FMOD_musicchannel.sound and FMOD_musicchannel.sound==psound then
      FMOD_musicchannel:setVolume(pvolume)
    end
    for i,v in pairs(FMOD_channels) do
      if v and v.sound and v.sound==psound then
        v:setVolume(pvolume)
      end
    end
  elseif SOUNDSYSTEM=="UNTZ" then
    psound:setVolume(pvolume)
  end
end

function release(psound)
  if psound then
    if type(psound)=="table" then
      for k,v in pairs(psound) do
        if type(v) == "userdata" then
          release2(v)
        end
      end
    elseif type(psound) == "userdata" then
      release2(psound)
    end
  end
end

function release2(psound)
  if psound then
    if SOUNDSYSTEM=="FMOD" then
      psound:release()
    else
      psound = nil
    end
  end
end