module HostSink.Fetcher
  (
    fetchUrl
  ) where

import           Control.Lens
import qualified Data.ByteString.Lazy as LB
import           Data.Text            (Text)
import qualified Data.Text            as T
import qualified Data.Text.Encoding   as T
import           Network.Wreq

import           HostSink.Config

fetchUrl :: Text -> IO Text
fetchUrl url = do
  mpc <- getProxyConfig
  let opts = case mpc of
        Nothing ->
          defaults
        Just (host,port) ->
          defaults & proxy ?~ httpProxy (T.encodeUtf8 host) port
      url' = T.unpack url
  r <- getWith opts url'
  let txt = T.decodeUtf8 $ LB.toStrict $ r ^. responseBody
  putStrLn $ "Got data from: " ++ url'
  putStrLn $ "Size: " ++ show (T.length txt) ++ " chars"
  return txt
