-----------------------------------------------------------------------------
--
-- Module      :  Main
-- Copyright   :
-- License     :  AllRightsReserved
--
-- Maintainer  :
-- Stability   :
-- Portability :
--
-- |
--
-----------------------------------------------------------------------------

module Main (
    main
) where

import VCSGui.Common.Types
import qualified VCSGui.Svn as Svn
import qualified VCSWrapper.Common as Wrapper

import qualified VCSGui.Git.Log as GitLog
import qualified VCSGui.Git.Commit as GitCommit
import Graphics.UI.Gtk

--
--svn
--

--
-- commit
--

{-
cwd = "/home/n0s/project1_work3"
main = do
    initGUI
    runWithConfig $ Svn.showCommitGUI
    mainGUI
    mainQuit
    where
        runWithConfig = runVcs $ makeConfig (Just cwd) Nothing Nothing
-}

--
-- checkout
--

{-
cwd = "/home/n0s/"
main = do
    initGUI
    runWithConfig $ Svn.showCheckoutGUI
    mainGUI
    mainQuit
    where
        runWithConfig = runVcs $ makeConfig (Just cwd) Nothing Nothing
-}

--
--log
--

{-
cwd = "/home/n0s/project1_work3"
main = do
        initGUI
        runWithConfig $
            Svn.showLogGUI
        mainGUI
        mainQuit
    where
        runWithConfig = runVcs $ makeConfig (Just cwd) Nothing Nothing
---}

--
--git
--

--
--log
--


--cwdGit = "/home/n0s-ubuntu/testrepo"
{-
main = do
        initGUI
        runWithConfig $
            GitLog.showLogGUI
        mainGUI
    where
        runWithConfig = runVcs $ makeConfig (Just cwdGit) Nothing Nothing
-}


--
-- commit
--
{-
main = do
    initGUI
    runWithConfig $
        GitCommit.showCommitGUI
    mainGUI
    where
        runWithConfig = runVcs $ makeConfig (Just cwdGit) Nothing Nothing

-}


--
-- common
--
cwd = "/home/forste/leksahWorkspace/leksah"
main = do
    initGUI
    Svn.showSetupConfigGUI config $ \(Just(x,y)) -> putStrLn $ "Config:" ++ show y ++ ", Chosen vcs:" ++ show x
    mainGUI
    where
        config = Just (Wrapper.GIT, Wrapper.makeConfig Nothing Nothing Nothing)
--        config = Just (Wrapper.GIT, Wrapper.makeConfig (Just cwd) Nothing Nothing)

