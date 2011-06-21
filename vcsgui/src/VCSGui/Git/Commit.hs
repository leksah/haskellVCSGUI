-----------------------------------------------------------------------------
--
-- Module      :  VCSGui.Git.Commit
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

module VCSGui.Git.Commit (
    showCommitGUI
) where

import Control.Monad.Trans(liftIO)

import Graphics.UI.Gtk

import VCSGui.Common.GtkHelper
import qualified VCSGui.Common.Commit as Commit

import qualified VCSWrapper.Git as Git
import qualified VCSWrapper.Common as Wrapper


doCommit commitMsg files _ = do
    Git.add files
    Git.commit files Nothing commitMsg []

showCommitGUI :: Git.Ctx ()
showCommitGUI = do
    Commit.showCommitGUI setupListStore doCommit

setupListStore :: TreeView -> Wrapper.Ctx (ListStore Commit.SCFile)
setupListStore view = do
        repoStatus <- Git.status
        --GITSCFile Bool FilePath String
        let selectedF = [Commit.GITSCFile True fp (show mod) | (Wrapper.GITStatus fp mod) <- repoStatus, mod == Wrapper.Modified || mod == Wrapper.Added]
            notSelectedF = [Commit.GITSCFile False fp (show mod) | (Wrapper.GITStatus fp mod) <- repoStatus, mod /= Wrapper.Modified && mod /= Wrapper.Added]

        liftIO $ do
            store <- listStoreNew (selectedF ++ notSelectedF)
            treeViewSetModel view store
            let item = (store, view)

            toggleRenderer <- cellRendererToggleNew
            addColumnToTreeView' item toggleRenderer "Commit" (\(Commit.GITSCFile s _ _)-> [cellToggleActive := s])
            addTextColumnToTreeView' item "File" (\(Commit.GITSCFile _ p _) -> [cellText := p])
            addTextColumnToTreeView' item "File status" (\(Commit.GITSCFile _ _ m) -> [cellText := m])

            -- register toggle renderer
            on toggleRenderer cellToggled $ \filepath -> do
                putStrLn ("toggle called: " ++ filepath)

                Just treeIter <- treeModelGetIterFromString store filepath
                value <- listStoreGetValue store $ listStoreIterToIndex treeIter
                let newValue = (\(Commit.GITSCFile b fp m) -> Commit.GITSCFile (not b) fp m) value
                listStoreSetValue store (listStoreIterToIndex treeIter) newValue
                return ()
            return store
