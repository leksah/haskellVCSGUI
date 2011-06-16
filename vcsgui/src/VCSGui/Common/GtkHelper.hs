-----------------------------------------------------------------------------
--
-- Module      :  VCSGui.Common.GtkHelper
-- Copyright   :
-- License     :  AllRightsReserved
--
-- Maintainer  :  Harald Jagenteufel
-- Stability   :  experimental
-- Portability :
--
-- |
--
-----------------------------------------------------------------------------

module VCSGui.Common.GtkHelper (
    openGladeFile
    , getWindowFromGlade
    , getActionFromGlade
    , getLabelFromGlade
    , getTextEntryFromGlade
    , getTextViewFromGlade
    , getTreeViewFromGlade
    , addColumnToTreeView
    , addTextColumnToTreeView

    , getName
    , getItem
    , getGetter
    , getSetter

    , WindowItem
    , ActionItem
    , LabelItem
    , TextEntryItem
    , TextViewItem
    , TreeViewItem
) where

import qualified Graphics.UI.Gtk as Gtk

import System.Directory

-- Typesynonyms
type WindowItem = (String, Gtk.Window, ())
type ActionItem = (String, Gtk.Action, ())
type LabelItem = (String, Gtk.Label, (IO (Maybe String), String -> IO ()))
type TextEntryItem = (String, Gtk.Entry, (IO (Maybe String), String -> IO ()))
type TextViewItem = (String, Gtk.TextView, (IO (Maybe String), String -> IO ()))
type TreeViewItem a = (String, (Gtk.ListStore a, Gtk.TreeView), (IO (Maybe [a]), [a] -> IO ()))

-- Type accessors
getName :: (String, a, b) -> String
getName (n, _, _) = n

getItem :: (String, a, b) -> a
getItem (_, item, _) = item

getGetter :: (String, a, (b, c)) -> b
getGetter (_, _, (getter, _)) = getter

getSetter :: (String, a, (b, c)) -> c
getSetter (_,_, (_, setter)) = setter


----------------------
-- *FromGlade
----------------------

openGladeFile :: FilePath -> IO Gtk.Builder
openGladeFile fn = do
    builder <- Gtk.builderNew
    Gtk.builderAddFromFile builder fn
    return builder


getWindowFromGlade :: Gtk.Builder
    -> String
    -> IO WindowItem
getWindowFromGlade builder name = do
    (a, b) <- wrapWidget builder Gtk.castToWindow name
    return (a, b, ())


getActionFromGlade :: Gtk.Builder
    -> String
    -> IO ActionItem
getActionFromGlade builder name = do
    (a, b) <- wrapWidget builder Gtk.castToAction name
    return (a, b, ())


getLabelFromGlade :: Gtk.Builder
    -> String
    -> IO LabelItem
getLabelFromGlade builder name = do
    (_, entry) <- wrapWidget builder Gtk.castToLabel name
    let getter = error "don't call get on a gtk label!" :: IO (Maybe String)
        setter val = Gtk.labelSetText entry val :: IO ()
    return (name, entry, (getter, setter))

getTextEntryFromGlade :: Gtk.Builder
    -> String
    -> IO TextEntryItem
getTextEntryFromGlade builder name = do
    (_, entry) <- wrapWidget builder Gtk.castToEntry name
    let getter = fmap testBlank $ Gtk.entryGetText entry :: IO (Maybe String)
        setter val = Gtk.entrySetText entry val :: IO ()
    return (name, entry, (getter, setter))


getTextViewFromGlade :: Gtk.Builder
    -> String
    -> IO TextViewItem
getTextViewFromGlade builder name =  do
        (_, entry)  <- wrapWidget builder Gtk.castToTextView name
        buffer <- Gtk.textViewGetBuffer entry
        let getter = getLongText buffer :: IO (Maybe String)
            setter = (\text -> Gtk.textBufferSetText buffer text) :: String -> IO ()
        return (name, entry, (getter, setter))
    where
    getLongText buffer = do
        start <- Gtk.textBufferGetStartIter buffer
        end <- Gtk.textBufferGetEndIter buffer
        isEmpty <- (Gtk.textIterEqual start end)
        if isEmpty then return Nothing else do
            s <- Gtk.textBufferGetText buffer start end True -- True to inclue hidden char
            return $ Just s


---------------------------------
-- TreeView
---------------------------------

getTreeViewFromGlade :: Gtk.Builder
    -> String
    -> [a]
    -> IO (TreeViewItem a)
getTreeViewFromGlade builder name rows = do
    (_, tView) <- wrapWidget builder Gtk.castToTreeView name
    entry@(store, treeView) <- createStoreForTreeView tView rows
    let getter = getFromListStore entry
        setter = setToListStore entry
    return (name, (store, treeView), (getter, setter))


createStoreForTreeView :: Gtk.TreeView
    -> [a]
    -> IO (Gtk.ListStore a, Gtk.TreeView)
createStoreForTreeView listView rows = do
    listStore <- Gtk.listStoreNew rows
    Gtk.treeViewSetModel listView listStore
    return (listStore, listView)


getFromListStore :: (Gtk.ListStore a, Gtk.TreeView)
    -> IO (Maybe [a])
getFromListStore (store, _) = do
    list <- Gtk.listStoreToList store
    if null list
        then return Nothing
        else return $ Just list


setToListStore :: (Gtk.ListStore a, Gtk.TreeView)
    -> [a]
    -> IO ()
setToListStore (store, view) newList = do
    Gtk.listStoreClear store
    mapM_ (Gtk.listStoreAppend store) newList
    return ()


-- | Add a column to given ListStore and TreeView using a mapping.
-- The mapping consists of a CellRenderer, the title and a function, that maps each row to attributes of the column
addColumnToTreeView :: Gtk.CellRendererClass r =>
    TreeViewItem a
    -> r
    -> String
    -> (a -> [Gtk.AttrOp r])
    -> IO ()
addColumnToTreeView (_, (listStore, listView), _) renderer title value2attributes = do
    newCol <- Gtk.treeViewColumnNew
    Gtk.set newCol [Gtk.treeViewColumnTitle Gtk.:= title]
    Gtk.treeViewAppendColumn listView newCol
    Gtk.treeViewColumnPackStart newCol renderer True
    Gtk.cellLayoutSetAttributes newCol renderer listStore value2attributes


addTextColumnToTreeView :: TreeViewItem a
    -> String
    -> (a -> [Gtk.AttrOp Gtk.CellRendererText])
    -> IO ()
addTextColumnToTreeView tree title map = do
    r <- Gtk.cellRendererTextNew
    addColumnToTreeView tree r title map

---------------------------
-- internal helpers
---------------------------

wrapWidget :: Gtk.GObjectClass objClass =>
     Gtk.Builder
     -> (Gtk.GObject -> objClass)
     -> String -> IO (String, objClass)
wrapWidget builder cast name = do
    putStrLn $ " cast " ++ name
    gobj <- Gtk.builderGetObject builder cast name
    return (name, gobj)


testBlank :: String -> Maybe String
testBlank "" = Nothing
testBlank s = Just s