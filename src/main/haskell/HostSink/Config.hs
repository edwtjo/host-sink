{-# LANGUAGE OverloadedStrings #-}
module HostSink.Config
  ( readConfig
  , getSources
  , getProxyConfig
  ) where

import           Control.Monad    (unless)
import           Data.Ini
import           Data.Text        (Text)
import qualified Data.Text        as T
import qualified Data.Text.IO     as T
import qualified Data.Text.Read       as T
import           System.Directory
import           System.FilePath
import           System.IO

sources :: [Text]
sources = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
          , "https://mirror1.malwaredomains.com/files/justdomains"
          , "http://sysctl.org/cameleon/hosts"
          , "https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist"
          , "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
          , "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
          , "https://hosts-file.net/ad_servers.txt"
          , "http://winhelp2002.mvps.org/hosts.txt"
          ]

getListString :: Ini -> Text -> Text -> [Text]
getListString ini sec key =
  case lookupValue sec key ini of
    Left _ -> []
    Right txt -> T.splitOn "," txt

getStringValue :: Ini -> Text -> Text -> Maybe Text
getStringValue ini sec key =
  case lookupValue sec key ini of
    Left _ -> Nothing
    Right txt -> Just txt

getDecimalValue :: Ini -> Text -> Text -> Maybe Int
getDecimalValue ini sec key =
  case readValue sec key T.decimal ini of
    Left _ -> Nothing
    Right txt -> Just txt

configDir :: IO FilePath
configDir = do
  home <- getHomeDirectory
  let confDir = home </> ".config" </> "host-sink"
  createDirectoryIfMissing True confDir
  return confDir

createFileIfMissing :: FilePath -> IO ()
createFileIfMissing fp = do
  e <- doesFileExist fp
  unless e $ do
    hdl <- System.IO.openFile fp WriteMode
    hPutStr hdl "# Have a great time :)"
    hClose hdl

configFile :: IO FilePath
configFile = do
  confDir <- configDir
  let config = confDir </> "ini"
  createFileIfMissing config
  return config

readConfig :: IO Ini
readConfig = do
  cfg <- configFile
  initxt <- T.readFile cfg
  case parseIni initxt of
    Left err  -> putStrLn ("Error: " ++ err) >> return mempty
    Right ini -> return ini

getSources :: IO [Text]
getSources = do
  ini <- readConfig
  let s = getListString ini "sources" "replace"
      a = getListString ini "sources" "append"
  return $ (if null s then sources else s) ++ a

getProxyConfig :: IO (Maybe (Text,Int))
getProxyConfig = do
  ini <- readConfig
  let host = getStringValue ini "http-proxy" "host"
      port = getDecimalValue ini "http-proxy" "port"
      res = case (host,port) of
              (Just hst, Just prt) -> Just (hst,prt)
              _ -> Nothing
  return res
