module Types exposing (..)

import Array exposing (Array)




-- OBJECTS

type alias Content =
  { id : String
  , contentType : String
  , content : String
  }

type alias Node =
  { id : String
  , contentId : String
  , childrenIds : List String
  }

type alias Commit =
  { id : String
  , rootNode : String
  , timestamp : Int
  , authors : List String
  , committer : String
  , parents: List String
  , message : String
  }

type alias Operation =
  { opType : String
  , params : List (Maybe String)
  }

type alias Objects =
  { contents : List Content
  , nodes : List Node
  , commits : List Commit
  , operations : Array Operation
  }

type alias State =
  { objects : Objects
  , commit : String
  , viewState : ViewState
  } 



-- TRANSIENTS

type alias ViewState =
  { active : String
  , editing : Maybe String
  , field : String
  }


type alias Tree =
  { uid : String
  , content : Content
  , parentId : Maybe String
  , prev : Maybe String
  , next : Maybe String
  , visible : Bool
  , children : Children
  }


type Children = Children (List Tree)
type alias Group = List Tree
type alias Column = List (List Tree)




-- DEFAULTS

defaultContent : Content
defaultContent =
  { id = -- sha1(contentType+"\n"+content)
      "5960f096212e449474d2eb1f8f4e33495d0a53aa" 
  , contentType = "text/markdown" 
  , content = "fromDefault"
  }

defaultNode : Node
defaultNode =
  { id = -- sha1(contentId+"\n"+childrenIds.join("\n")
      "1331dfaaa7dc267a902e4a9aa0e9d97130fabc4c" 
  , contentId = defaultContent.id
  , childrenIds = []
  }

defaultCommit : Commit
defaultCommit =
  { id = -- sha1(rootNode+"\n"+parents.join("\n")+authors.join("\n")+commiter+"\n"+timestamp+"\n"+message)
      "bc5ff95381ff8577663e45455b14cd09d7e126c1"
  , rootNode = defaultNode.id
  , timestamp = 1474906969610
  , authors = ["Gingko"]
  , committer = "Gingko"
  , parents= []
  , message = "Initial commit."
  }

defaultObjects : Objects
defaultObjects =
  { contents = [defaultContent]
  , nodes = [defaultNode]
  , commits = [defaultCommit]
  , operations = Array.empty
  }