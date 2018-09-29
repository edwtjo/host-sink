{-# LANGUAGE OverloadedStrings #-}

module HostSink.Parse
  ( fileParser
  ) where

import           Control.Applicative
import           Data.Attoparsec.Text
import           Data.Char
import           Data.Text            (Text)
import qualified Data.Text            as T

mySpace :: Parser ()
mySpace = skipWhile spc
  where
    spc c = c `elem` [' ','\t']

comments :: Parser Text
comments = mySpace >> char '#' *> takeTill eol >> return "CMT"
  where
    eol c = c == '\r' || c == '\n'

host1 :: Parser Text
host1 = do
  mySpace
  parts <- word `sepBy1` char '.'
  _ <- ending
  return $ T.intercalate "." parts
  where
    ending = comments <|> (mySpace >> return "LN")
    word = takeWhile1 (\c -> isLetter c || isDigit c || elem c ['-','_'])

ipHost :: Parser Text
ipHost = do
  _ <- string "127.0.0.1" <|>
        string "0.0.0.0" <|>
        string "::1" <|>
        string "255.255.255.255" <|>
        string "fe80::1%lo0" <|>
        string "ff00::0" <|>
        string "ff02::1" <|>
        string "ff02::2" <|>
        string "ff02::3"
  mySpace
  host1

lineParser :: Parser Text
lineParser =
  comments <|>
  ipHost <|>
  host1 <|>
  emptyLine
  where
    emptyLine = mySpace >> return "LN"

fileParser :: Text -> [Text]
fileParser txt =
  case parseOnly rpprs txt of
    Right r -> r
    Left l  -> prune [T.pack l]
  where
    rpprs = many1 $ lineParser <* endOfLine

prune :: [Text] -> [Text]
prune = filter (\p -> p `notElem`
  [ "CMT"
  , "LN"
  , "localhost"
  , "localhost.localdomain"
  , "local"
  , "broadcasthost"
  , "ip6-localhost"
  , "ip6-loopback"
  , "ip6-localnet"
  , "ip6-mcastprefix"
  , "ip6-allnodes"
  , "ip6-allrouters"
  , "ip6-allhosts"
  , "0.0.0.0"
  ])
