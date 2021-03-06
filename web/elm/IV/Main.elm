module IV.Main exposing (..)

import IV.Msg exposing (..)
import Animation
import IV.Scenario.Main as Scenario
import IV.Scenario.Model as ScenarioModel
import IV.Apparatus.Main as Apparatus
import IV.Clock.Main as Clock

import IV.Types exposing (..)
import IV.Scenario.Calculations as Calc

-- Model

type alias Model =
    { scenario : ScenarioModel.Model -- this holds all the user-chosen data

    -- The following hold the animation states of component pieces
    , clock : Clock.Model
    , apparatus : Apparatus.Model
    }

scenario' model val =
  { model | scenario = val }

subscriptions : Model -> Sub Msg
subscriptions model =
  -- Note: This provides a subscription to the animation frame iff
  -- any of the listed animations is running.
  Animation.subscription
    AnimationClockTick
    (Apparatus.animations model.apparatus ++ Clock.animations model.clock)


-- Update

initWithScenario : ScenarioModel.Model -> Model
initWithScenario scenario =
  { scenario = scenario
  , apparatus = Apparatus.unstarted scenario
  , clock = Clock.startingState
  }
  
init : ( Model, Cmd Msg )
init = (initWithScenario Scenario.cowScenario, Cmd.none)


updateScenario model updater =
  let
    ( newScenario, cmd ) = updater model.scenario
  in
    ( scenario' model newScenario, cmd)
  
showTrueFlow model =
  let
    dps = Calc.dropsPerSecond model.scenario
    (newApparatus, cmd) = Apparatus.showTrueFlow dps model.apparatus
  in
    ( { model | apparatus = newApparatus }
    , cmd
    )
  

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToScenario msg' ->
      Scenario.update msg' |> updateScenario model

    PickedScenario scenario ->
      ( initWithScenario scenario
      , Cmd.none
      )

    ChoseDripSpeed ->
      showTrueFlow model

    FluidRanOut ->
      let 
        -- TODO: Changing the value in the scenario is needed so that
        -- the drip doesn't start up again (from an empty bag) when
        -- the simulation finishes (the clock runs out).
        scenario = model.scenario
        newScenario = { scenario | dripText = "0" }
        drainedModel = { model | scenario = newScenario }
      in
        update ChoseDripSpeed drainedModel

    StartSimulation ->
      let
        (newApparatus, apparatusCmd) = Apparatus.startSimulation model.scenario model.apparatus
        (newClock, clockCmd) = Clock.startSimulation (Calc.hours model.scenario) model.clock

        newModel = { model
                     | apparatus = newApparatus
                     , clock = newClock
                   }
        cmd = Cmd.batch [apparatusCmd, clockCmd]
      in
        (newModel, cmd)
        
    StopSimulation ->
      showTrueFlow model
        
    AnimationClockTick tick ->
      let
        (newApparatus, apparatusCmd) = Apparatus.animationClockTick tick model.apparatus
        (newClock, clockCmd) = Clock.animationClockTick tick model.clock

        newModel = { model
                     | apparatus = newApparatus
                     , clock = newClock
                   }
        cmd = Cmd.batch [apparatusCmd, clockCmd]
      in
        (newModel, cmd)
        
