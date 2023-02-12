--                                               /\ \    
--   __  _   ___ ___     ___     ___      __     \_\ \   
--  /\ \/'\/' __` __`\  / __`\ /' _ `\  /'__`\   /'_` \  
--  \/>  <//\ \/\ \/\ \/\ \L\ \/\ \/\ \/\ \L\.\_/\ \L\ \ 
--   /\_/\_\ \_\ \_\ \_\ \____/\ \_\ \_\ \__/.\_\ \___,_\
--   \//\/_/\/_/\/_/\/_/\/___/  \/_/\/_/\/__/\/_/\/__,_ /                                        
-- Base.
import XMonad
import System.Directory
import System.IO
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W
-- Actions.
import XMonad.Actions.CopyWindow
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves
import XMonad.Actions.WithAll
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
-- Data.
import Data.Maybe 
import Data.Map as M
-- Hooks.
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops 
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
-- Layouts/Modifiers.
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ResizableTile
import XMonad.Layout.LimitWindows
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Spacing
import XMonad.Layout.ToggleLayouts as T
import XMonad.Layout.MultiToggle as MT
-- Utilities.
import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Util.SpawnOnce
-- Defaults
myFont = "xft:Iosevka:regular:size=9:antialias=true:hinting=true"
myModMask = mod4Mask                             -- Sets Mod Key to Super/Win/Fn.
myTerminal = "alacritty"                         -- Sets default Terminal Emulator.
myBrowser = "firefox"                            -- Sets default browser.
myBorderWidth = 2                                -- Sets Border Width in pixels.
myNormColor   = "#282828"                        -- Border color of normal windows.
myFocusColor  = "#9C6BBC"                        -- Border color of focused windows.
-- Startup Applications
myStartupHook = do
    spawnPipe "picom" --Compositor
    spawnOnce "lxpolkit" -- Graphical authentication agent.
    spawnOnce "./test.sh"
    spawnOnce "xset s off"
    spawnOnce "xset s 0 0"
    spawnOnce "xset -dpms"
    spawnOnce "xsetroot -cursor_name Left_ptr" 
-- Workspaces.
myWorkspaces = [" main ", " web ", " code ", " unity ", " games ", " disc ", " mail ", " libre ", " other "]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..]
clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>" -- i have no idea how this works
    where i = fromJust $ M.lookup ws myWorkspaceIndices
-- Layouts config.
tall     = renamed [Replace "Tall"]
           $ limitWindows 10
           $ spacingRaw False (Border 0 0 0 0) True (Border 10 10 10 10) True
           $ ResizableTall 1 (3/100) (10/20) []
monocle  = renamed [Replace "Monocle"]
           $ limitWindows 10 Full
floats   = renamed [Replace "Float"]
           $ limitWindows 10 simplestFloat
myLayoutHook = avoidStruts $ T.toggleLayouts floats $ lessBorders OnlyScreenFloat
             $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where  myDefaultLayout = (tall ||| smartBorders monocle ||| floats)
-- Keyboard shortcuts.
myKeys =
-- Base.
     [ ("M-S-r", spawn "xmonad --recompile")     -- Recomplies xmonad.
     , ("M-q", spawn "xmonad --restart")         -- Restarts xmonad.
     , ("M-S-q", io exitSuccess)                 -- Quits xmonad.
     , ("M-S-c", kill1)                          -- Kill the currently focused client.
     , ("M-S-a", killAll)                        -- Kill all windows on current workspace.
     , ("M-d", spawn "rofi -show drun -theme RofiApplications") -- Launches rofi App Launcher.
-- Screenshot
     , ("<Print>", spawn "scrot -u")
-- Spawn programs keybindings.
     , ("M-<Return>", spawn (myTerminal))        -- Launches Alacritty Terminal.
     , ("M-b", spawn (myBrowser))                -- Launches Firefox.
     , ("M-n", spawn "nemo")                     -- Launches Nemo file manager.
-- Window layouts modifiers.
     , ("M-f", sendMessage (T.Toggle "floats"))  -- Toggles my 'floats' layout.
     , ("M-t", withFocused $ windows . W.sink)   -- Push floating window back to tile.
     , ("M-S-t", sinkAll)                        -- Push ALL floating windows to tile.
     , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles Fullscreen/NB.
     , ("M-<Tab>", sendMessage NextLayout)       -- Switch to next layout.
-- Space control.
     , ("M-S-i", decScreenSpacing 8)             -- Decrease screen spacing.
     , ("M-S-u", incScreenSpacing 8)             -- Increase screen spacing.
-- Resizing.
     , ("M-h", sendMessage Shrink)               -- Shrink horiz window width.
     , ("M-l", sendMessage Expand)               -- Expand horiz window width.
     , ("M-j", sendMessage MirrorShrink)         -- Shrink vert window width.
     , ("M-k", sendMessage MirrorExpand)         -- Expand vert window width.
-- Navigation.
     , ("M-m", windows W.focusMaster)            -- Move focus to the master window.
     , ("M-S-m", windows W.swapMaster)           -- Swap the focused window and the master window.
     , ("M-<Right>", windows W.focusDown)        -- Move focus to the next window.
     , ("M-<Left>", windows W.focusUp)           -- Move focus to the prev window.
     , ("M-S-<Right>", windows W.swapDown)       -- Swap focused window with next window.
     , ("M-S-<Left>", windows W.swapUp)          -- Swap focused window with prev window.
     , ("M-<Backspace>", promote)                -- Promote focused window to master.
     , ("M-.", nextScreen)                       -- Switch focus to next monitor
     , ("M-,", prevScreen)                       -- Switch focus to prev monitor
	]


-- Set window properties. Find class file with xprop
myManageHook = composeAll                           
     [ className =? "firefox" --> doShift ( myWorkspaces !! 1 )
     , className =? "Brave-browser-nightly" --> doShift ( myWorkspaces !! 1)
     , className =? "Code" --> doShift (myWorkspaces !! 2)
     , className =? "jetbrains-rider" --> doShift (myWorkspaces !! 2)
     , className =? "unityhub" --> doShift (myWorkspaces !! 3)
     , className =? "Steam" --> doShift (myWorkspaces !! 4)
     , className =? "Lutris" --> doShift (myWorkspaces !! 4)
     , className =? "discord" --> doShift (myWorkspaces !! 5)
     , className =? "thunderbird" --> doShift (myWorkspaces !! 6)
     , className =? "control"         --> doFloat
     , className =? "error"           --> doFloat
     , className =? "file_progress"   --> doFloat
     , className =? "dialog"          --> doFloat
     , className =? "download"        --> doFloat
     , className =? "Gimp"            --> doFloat
     , className =? "Update"          --> doFloat
     , className =? "notification"    --> doFloat
     , className =? "pinentry-gtk-2"  --> doFloat
     , className =? "confirm"         --> doFloat
     , className =? "splash"          --> doFloat
     , className =? "toolbar"         --> doFloat
     , className =? "Steam"           --> doFloat
     , isFullscreen -->  doFullFloat ] 
-- Main.
main = do
    xmproc0 <- spawnPipe "xmobar -x 0 ~/.config/xmonad/xmobarrc0"
    --xmproc2 <- spawnPipe "xmobar -x 2 ~/.config/xmonad/xmobarrc0"
    xmonad . docks . ewmh . ewmhFullscreen $ def
     { manageHook         = myManageHook
     , modMask            = myModMask
     , startupHook        = myStartupHook
     , layoutHook         = myLayoutHook
     , workspaces         = myWorkspaces
     , borderWidth        = myBorderWidth
     , normalBorderColor  = myNormColor
     , focusedBorderColor = myFocusColor 
     , logHook = dynamicLogWithPP $ xmobarPP                           -- Xmobar settings.
       { ppOutput = \x -> hPutStrLn xmproc0 x                          -- Places xmobar on Display 1.
       , ppCurrent = xmobarColor "#AB72E1" "" . wrap "<box type=Bottom width=2 mb=2 color=#CB98FB>" "</box>"         -- Current Workspace.
       , ppVisible = xmobarColor "#AB72E1" "" . clickable              -- Visible Workspaces.
       , ppHidden = xmobarColor "#AB72E1" "" . wrap "<box type=Top width=2 mt=2 color=#CB98FB>" "</box>" . clickable -- Hidden Workspaces.
       , ppHiddenNoWindows = xmobarColor "#AB72E1" ""  . clickable     -- Hidden Workspaces without windows.
       , ppTitle = xmobarColor "#AB72E1" "" . shorten 60               -- Active window title.
       , ppSep =  "<fc=#666666> <fn=0>|</fn> </fc>"                    -- Separator character.
       , ppLayout = xmobarColor "#AB72E1" ""                           -- Current Layout Indicator.
       , ppUrgent = xmobarColor "#AB72E1" "" . wrap "!" "!"            -- Urgent workspace.
       , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t] } }                -- Xmobar template.
       `additionalKeysP` myKeys
