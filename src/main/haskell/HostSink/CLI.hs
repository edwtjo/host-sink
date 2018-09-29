module HostSink.CLI
  ( runCLI
  , Cmd(..))
  where

import           Data.Semigroup      ((<>))
import           Options.Applicative

data Cmd = Main
  { hosts   :: Bool
  , unbound :: Bool
  }

mainMode :: Parser Cmd
mainMode =
  Main <$> switch (long "hosts" <> short 's' <> help "Generate hosts")
       <*> switch (long "unbound" <> short 'u' <> help "Generate local-data.conf")

runCLI :: (Cmd -> IO()) -> IO ()
runCLI f = f =<< execParser opts
  where
    opts = info (mainMode <**> helper)
      ( fullDesc
      <> progDesc "Helper to remove ad- or tracking hosts from your internet"
      <> header "host-sink - Generate host sinkhole files"
      )
