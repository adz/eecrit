module IV.Update exposing (update)

import IV.Msg exposing (Msg(..))
import IV.Model as Model exposing (Model)
import String
import IV.Droplet.Main as Droplet
import IV.Scenario.Update as Scenario
import IV.Clock.Update as Clock
import IV.Scenario.Msg as SpeedMsg
import IV.Clock.Msg as ClockMsg
import IV.Pile.ManagedStrings exposing (floatString)
import IV.Types exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToScenario msg' ->
      ( { model | scenario = Scenario.update msg' model.scenario }
      , Cmd.none
      )

    StartSimulation ->
      let
        dropletData = model.scenario.dripText |> floatString |> DropsPerSecond
      in          
      ( { model
          | droplet = Droplet.update (Droplet.StartSimulation dropletData) model.droplet
          , clock = Clock.update ClockMsg.StartSimulation model.clock
        }
      , Cmd.none
      )

    AnimationClockTick tick ->
      ( { model
          | droplet = Droplet.update (Droplet.AnimationClockTick tick) model.droplet
          , clock = Clock.update (ClockMsg.AnimationClockTick tick) model.clock
        }
      , Cmd.none
      )

