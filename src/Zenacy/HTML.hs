--------------------------------------------------------------------------------
-- Copyright (C) 2016 Zenacy Reader Technologies LLC
--------------------------------------------------------------------------------

-- | Zenacy HTML is an HTML parsing and processing library that implements the
-- WHATWG HTML parsing standard.  The standard is described as a state machine
-- that this library implements exactly as spelled out including all the error
-- handling, recovery, and conformance checks that makes it robust in handling
-- any HTML pulled from the web.  In addition to parsing, the library provides
-- many processing features to help extract information from web pages or
-- rewrite them and render the modified results.
module Zenacy.HTML
  ( 
  -- * Introduction
  -- $intro

  -- * Hello, World
  -- $example

  -- * Rewriting
  -- $rewrite

  -- * Extraction
  -- $extract

  -- * Samples
  -- $samples

  -- * Origin
  -- $history

  module X
  ) where

import Zenacy.HTML.Internal.HTML as X
import Zenacy.HTML.Internal.Image as X
import Zenacy.HTML.Internal.Oper as X
import Zenacy.HTML.Internal.Query as X
import Zenacy.HTML.Internal.Render as X
import Zenacy.HTML.Internal.Zip as X

-- $intro
--
-- The Zenacy HTML parser is an implementation of the HTML parsing standard
-- defined by the WHATWG.
--
-- https://html.spec.whatwg.org/multipage/parsing.html
--
-- The standard defines a parsing state machine, so it is very prescriptive
-- on how HTML is handled including many edge cases and error recovery.
-- This library aims to follow the standard closely in such a way to match the
-- code back to the standard and make future updates straightforward.
--
-- One of the main uses an a HTML parser is for extracting information from
-- the web.  Having a parser that can handle all the nuances of poorly
-- formatted HTML helps to make this extraction as robust as possible.
-- This was a key motivation in deciding to implement a parser in this fashion.
-- Additionally, the standard describes the algorithms needed to produce the
-- correct document structure.  Applications that are sensitive to the
-- document structure, such as extracting and rewriting large portions of
-- a web page, may benefit from Zenacy HTML.
--
-- The library provides a wide variety of features including:
--
-- * A fully standard compliant HTML parser
-- * HTML Fragment parsing
-- * Document rendering
-- * A zipper type for document traversal
-- * An iterator type for document walking
-- * Various functions for processing aspects of HTML
-- * Lightweight queries for rewriting
--
-- $example
--
-- The library is designed to be imported unqualified.
--
-- > import Zenacy.HTML
--
-- The `htmlParseEasy` function can be used to parse an HTML document string
-- and return the document model.
--
-- > htmlParseEasy "<div>HelloWorld</div>"
--
-- Note that some of the missing elements where automatically added to
-- the document structure as required by the standard.
--
-- > HTMLDocument ""
-- >   [ HTMLElement "html" HTMLNamespaceHTML []
-- >     [ HTMLElement "head" HTMLNamespaceHTML [] []
-- >     , HTMLElement "body" HTMLNamespaceHTML []
-- >       [ HTMLElement "div" HTMLNamespaceHTML []
-- >         [ HTMLText "HelloWorld" ] ] ] ]
--
-- The parsed result can also be rendered using `htmlRender`.
--
-- > htmlRender $ htmlParseEasy "<div>HelloWorld</div>"
--
-- The resulting rendered document appears like so.
--
-- > "<html><head></head><body><div>HelloWorld</div></body></html>"
--
-- $rewrite
--
-- This example illustrates a function that converts span elements to divs.
-- 
-- > rewrite :: Text -> Text
-- > rewrite = htmlRender . htmlMapElem f . fromJust . htmlDocHtml . htmlParseEasy
-- >   where
-- >     f x
-- >       | htmlElemHasName "span" x = htmlElemRename "div" x
-- >       | otherwise = x
-- >
-- > rewrite "<span>Hello</span><span>World</span>"
--
-- Running the above gives the modified document.
--
-- > "<html><head></head><body><div>Hello</div><div>World</div></body></html>"
--
-- $extract
--
-- The next example shows one way to find all the hyperlinks in a document.
-- This solution recurses over the document elements while ignoring fragments
-- and templates.
--
-- > extract :: Text -> [Text]
-- > extract = go . htmlParseEasy
-- >   where
-- >     go = \case
-- >       HTMLDocument n c ->
-- >         concatMap go c
-- >       e @ (HTMLElement "a" s a c) ->
-- >         case htmlElemAttrFind (htmlAttrHasName "href") e of
-- >           Just (HTMLAttr n v s) ->
-- >             v : concatMap go c
-- >           Nothing ->
-- >             concatMap go c
-- >       HTMLElement n s a c ->
-- >         concatMap go c
-- >       _otherwise ->
-- >         []
-- >
-- > extract "<a href=\"https://example1.com\"></a><a href=\"https://example2.com\"></a>"
--
-- The extract function will give the following list.
--
-- > [ "https://example1.com"
-- > , "https://example2.com"
-- > ]
--
-- $samples
--
-- The unit tests include the above samples as well as many other example
-- usages of the library.
--
-- $history
--
-- Zenacy HTML was originally developed for Zenacy Reader Technologies LLC
-- starting around 2015 and used in a web reading SaaS for a few years.
-- The need to understand and handle
-- the wide variety and sublties of HTML found on the web lead to the development
-- of library that closely followed the standard.  The library was tweaked and
-- optimized a bit and though there is room for more improvements the result
-- worked quite well in production (a lot of credit goes to the GHC team and Haskell
-- community for providing such great, fast functional programming tools).
