{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Prelude          hiding (takeWhile, writeFile)

import           Control.Monad    (when)

import           Data.HashSet     (HashSet)
import qualified Data.HashSet     as HS
import           Data.Text        (Text)
import           Data.Text.IO     (writeFile)

import           HostSink.CLI
import           HostSink.Config
import           HostSink.Fetcher
import           HostSink.Format
import           HostSink.Parse

doit :: Cmd -> IO()
doit (Main hst ubnd) =
  when (hst || ubnd) $ do
     sources <- getSources
     hss <- mapM retrieve sources
     let hss' = HS.toList $ HS.unions hss
         hsls = hostFileFMT hss'
         unld = unboundFMT hss'
     when hst $ writeFile "hosts" hsls
     when ubnd $ writeFile "local-data.conf" unld
     putStrLn "Done"
  where
    retrieve :: Text -> IO (HashSet Text)
    retrieve url = do
      txt <- fetchUrl url
      return $ HS.fromList $ fileParser txt

main :: IO ()
main = runCLI doit
