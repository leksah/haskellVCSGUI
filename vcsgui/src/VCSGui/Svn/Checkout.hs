{-# LANGUAGE OverloadedStrings #-}
-----------------------------------------------------------------------------
--
-- Module      :  VCSGui.Svn.Checkout
-- Copyright   :  2011 Stephan Fortelny, Harald Jagenteufel
-- License     :  GPL
--
-- Maintainer  :  stephanfortelny at gmail.com, h.jagenteufel at gmail.com
-- Stability   :
-- Portability :
--
-- | Provides a GUI for checking out a working copy of a SVN repository.
--
-----------------------------------------------------------------------------

module VCSGui.Svn.Checkout (
    showCheckoutGUI
) where

import Control.Monad.Trans(liftIO)
import Control.Monad
import Control.Monad.Reader
import qualified VCSWrapper.Svn as Svn
import qualified VCSGui.Common.GtkHelper as H
import Paths_vcsgui(getDataFileName)
import Data.Maybe
import qualified Data.Text as T (unpack, pack)
import Control.Applicative ((<$>))
import GI.Gtk.Objects.Action (onActionActivate)
import GI.Gtk.Objects.Widget (widgetShowAll)
--
-- glade path and object accessors
--

getGladepath = getDataFileName "data/guiSvnCheckout.glade"
accessorWindowCheckout = "windowCheckout"
accessorActCheckout = "actCheckout"
accessorActCancel = "actCancel"
accessorActTxtViewUrl = "txtViewUrl"
accessorActTxtViewRevision = "txtViewRevision"
accessorActTxtViewPath = "txtViewPath"

data CheckoutGUI = CheckoutGUI {
    windowCheckout :: H.WindowItem
    ,actCheckout :: H.ActionItem
    ,actCancel :: H.ActionItem
    ,txtViewUrl :: H.TextViewItem
    ,txtViewRevision :: H.TextViewItem
    ,txtViewPath :: H.TextViewItem
    }

-- | Shows a GUI asking user for data to checkout a working copy of a SVN repository.
showCheckoutGUI :: Svn.Ctx()
showCheckoutGUI = do
    config <- ask
    liftIO $ do
        putStrLn "Starting gui ..."
        gui <- loadCheckoutGUI

         -- connect actions
        H.registerClose $ windowCheckout gui
        H.registerCloseAction (actCancel gui) (windowCheckout gui)
        liftIO $ onActionActivate (H.getItem (actCheckout gui)) $ do
                                            url <- H.get (txtViewUrl gui)
                                            realRevision <- H.get (txtViewRevision gui)
                                            realFilePath <- H.get (txtViewPath gui)
                                            let mbPwd = Nothing
                                            Svn.runVcs config $ Svn.checkout [(fromMaybe "" url, realRevision)] realFilePath mbPwd [] -- TODO pw handler
                                            H.closeWin $ windowCheckout gui


        liftIO $ widgetShowAll $ H.getItem $ windowCheckout gui

        liftIO $ putStrLn "Finished"
    return ()


loadCheckoutGUI :: IO CheckoutGUI
loadCheckoutGUI = do
                putStrLn $ "Creating builder from gladefile"
                gladepath <- liftIO getGladepath
                builder <- liftIO $ H.openGladeFile gladepath

                putStrLn $ "Creating gtk widgets from builder"
                win <- liftIO $ H.getWindowFromGlade builder accessorWindowCheckout
                actCheckout <- liftIO $  H.getActionFromGlade builder accessorActCheckout
                actCancel <- liftIO $  H.getActionFromGlade builder accessorActCancel
                txtViewUrl <- liftIO $  H.getTextViewFromGlade builder accessorActTxtViewUrl
                txtViewRevision <- liftIO $  H.getTextViewFromGlade builder accessorActTxtViewRevision
                txtViewPath <- liftIO $  H.getTextViewFromGlade builder accessorActTxtViewPath
                return $ CheckoutGUI win actCheckout actCancel txtViewUrl txtViewRevision txtViewPath

