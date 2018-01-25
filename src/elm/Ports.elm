port module Ports exposing (..)


import Types exposing (..)
import Coders exposing (..)
import Json.Encode exposing (..)
import Json.Decode exposing (decodeValue)


sendInfoOutside : InfoForOutside -> Cmd msg
sendInfoOutside info =
  case info of
    Alert str ->
      infoForOutside
        { tag = "Alert"
        , data = string str
        }

    ActivateCards (col, cardIds) ->
      let
        listListStringToValue lls =
          lls
            |> List.map (List.map string)
            |> List.map list
            |> list
      in
      infoForOutside
        { tag = "ActivateCards"
        , data = tupleToValue int listListStringToValue ( col, cardIds )
        }

    GetText id ->
      infoForOutside
        { tag = "GetText"
        , data = string id
        }

    SaveObjects ( statusValue, objectsValue ) ->
      infoForOutside
        { tag = "SaveObjects"
        , data = list [ statusValue, objectsValue ]
        }

    SaveLocal tree ->
      infoForOutside
        { tag = "SaveLocal"
        , data = treeToValue tree
        }

    UpdateCommits ( objectsValue, head_ ) ->
      let
        headToValue mbs =
          case mbs of
            Just str -> string str
            Nothing -> null
      in
      infoForOutside
        { tag = "UpdateCommits"
        , data = tupleToValue identity headToValue ( objectsValue, head_ )
        }

    ConfirmCancel id origContent ->
      infoForOutside
        { tag = "ConfirmCancel"
        , data = list [ string id, string origContent ]
        }

    New str_ ->
      infoForOutside
        { tag = "New"
        , data =
            case str_ of
              Just str -> string str
              Nothing -> null
        }

    Save filepath ->
      infoForOutside
        { tag = "Save"
        , data = string filepath
        }

    SaveAs ->
      tagOnly "SaveAs"

    ExportJSON tree ->
      infoForOutside
        { tag = "ExportJSON"
        , data = treeToJSON tree
        }

    ExportTXT tree ->
      infoForOutside
        { tag = "ExportTXT"
        , data = treeToMarkdown tree
        }

    Open filepath_ ->
      infoForOutside
        { tag = "Open"
        , data =
            case filepath_ of
              Just filepath -> string filepath
              Nothing -> null
        }

    SetSaved filepath ->
      infoForOutside
        { tag = "SetSaved"
        , data = string filepath
        }

    SetChanged ->
      tagOnly "SetChanged"

    Pull ->
      tagOnly "Pull"

    Push ->
      tagOnly "Push"

    SocketSend collabState ->
      infoForOutside
        { tag = "SocketSend"
        , data = collabStateToValue collabState
        }


getInfoFromOutside : (InfoForElm -> msg) -> (String -> msg) -> Sub msg
getInfoFromOutside tagger onError =
  infoForElm
    (\outsideInfo ->
        case outsideInfo.tag of
          "Reset" ->
            tagger <| Reset

          "Load" ->
            case decodeValue ( tupleDecoder Json.Decode.string Json.Decode.value ) outsideInfo.data of
              Ok ( filepath, json ) ->
                tagger <| Load (filepath, json)

              Err e ->
                onError e

          "ImportJSON" ->
            tagger <| ImportJSON outsideInfo.data

          "Changed" ->
            tagger <| Changed

          "Saved" ->
            case decodeValue Json.Decode.string outsideInfo.data of
              Ok filepath ->
                tagger <| Saved filepath

              Err e ->
                onError e

          "DoExportJSON" ->
            tagger <| DoExportJSON

          "DoExportTXT" ->
            tagger <| DoExportTXT

          "Keyboard" ->
            case decodeValue Json.Decode.string outsideInfo.data of
              Ok shortcut ->
                tagger <| Keyboard shortcut

              Err e ->
                onError e

          _ ->
            onError <| "Unexpected info from outside: " ++ toString outsideInfo
    )


tagOnly : String -> Cmd msg
tagOnly tag =
  infoForOutside { tag = tag, data = null }


port infoForOutside : OutsideData -> Cmd msg

port infoForElm : (OutsideData -> msg) -> Sub msg
