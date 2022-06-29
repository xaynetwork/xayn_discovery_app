# Data flow in the application

This doc describes the relationships between different app pars and how the data flow works there.


### Screen <-> Manager data flow

* every `screen` suppose to have its own `manager` 
* `screen` subscribes for the `manager` state changes
* all user interactions (actions) are delivered to the `manager`
* `manager` takes care on the user action and how to react onto it
* in case of need, `manager` can:
    * trigger `useCase` to fetch some data
    * subscribe for the `useCase` events (continuous stream events)
    * trigger UI updates
        - open another screen
        - show dialog/snackbar
    * emit updated state back to the `screen`

<img src="./../.github/art/screen_manager_data_flow.png" alt="Screen <-> Manager relationships"/>

<details>
    <summary>plantuml diagram script</summary>

        @startuml
        state Screen #dcedc8{
            state BlockBuilder
            BlockBuilder: take Manager instance
            BlockBuilder: updates UI
            state "Widget #0" as widget0
            state "Widget #1" as widget1
        
            BlockBuilder --> widget0: data #0
            BlockBuilder --> widget1: data #1
            BlockBuilder --> widget2: data #2
        }
        Screen: gets Manager instance via DI
        
        state "Manager / Cubit" as Manager #ffecb3{
        
            state useCase
        
            state uiController
            uiController: open screen
            uiController: show dialog
            uiController: show toast, popup
        
            state stateUpdate
            stateUpdate: combine data into new state
            stateUpdate: and emits it
        
            state "method #0" as method0
            method0: validates user action
        
            state "method #1" as method1
            method1: validata data
            method1: trigge UseCase
        
            state "method #2" as method2
            method2: validates user action
        
            [*] -> useCase: subscribes to events
            [*] -> stateUpdate: emits initial state
            method0 --> stateUpdate: react on user action
            method1 --> useCase: input
            useCase -right-> stateUpdate: output
            method1 --> stateUpdate: react on user action
            method2 --> uiController: action\nvalidated
        }
        
            BlockBuilder --[#33691e,bold]--> Manager: subscribes to state changes
            widget0 --[#33691e,bold]--> method0: user click
            widget1 --[#33691e,bold]--> method1: user swipe
            widget2 --[#33691e,bold]--> method2: user click
            stateUpdate --[#f57c00,bold]--> BlockBuilder: emits new state
        @enduml
</details>


----------------

##### 🛠 To edit diagram:
1. copy its script
1. edit it at [here](https://plantuml.com/)
1. generate a new `.png` image and update it here
1. do not forget to copy new `plantuml diagram script` here as well