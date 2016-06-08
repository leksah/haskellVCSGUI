{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
-----------------------------------------------------------------------------
--
-- Module      :  VCSGui.Common.Error
-- Copyright   :  2011 Stephan Fortelny, Harald Jagenteufel
-- License     :  GPL
--
-- Maintainer  :  stephanfortelny at gmail.com, h.jagenteufel at gmail.com
-- Stability   :
-- Portability :
--
-- | Functions to handle errors are found in this module.
--
-----------------------------------------------------------------------------

module VCSGui.Common.Error (
    showErrorGUI
) where

import Data.Text (Text)
import GI.Gtk.Objects.Dialog (constructDialogUseHeaderBar, dialogRun)
import GI.Gtk.Objects.Widget (widgetDestroy)
import Data.GI.Base (new')
import GI.Gtk.Objects.MessageDialog
       (constructMessageDialogMessageType, constructMessageDialogButtons,
        setMessageDialogText, MessageDialog(..))
import GI.Gtk.Enums (ButtonsType(..), MessageType(..))

-- | Displays a simple window displaying given 'String' as an error message.
showErrorGUI :: Text -- ^ Message to display.
    -> IO ()
showErrorGUI msg = do
    dialog <- new' MessageDialog [
                  constructDialogUseHeaderBar 0,
                  constructMessageDialogMessageType MessageTypeError,
                  constructMessageDialogButtons ButtonsTypeOk]
    setMessageDialogText dialog msg
    _ <- dialogRun dialog
    widgetDestroy dialog
    return ()
