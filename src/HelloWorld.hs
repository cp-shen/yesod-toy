{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module HelloWorld where

import Yesod

data HelloWorld = HellowWorld

mkYesod "HelloWorld" [parseRoutes| / HomeR  GET |]

instance Yesod HelloWorld

getHomeR :: Handler Html
getHomeR = defaultLayout [whamlet|Hello World!|]

hwMain :: IO ()
hwMain = warp 3001 HellowWorld
