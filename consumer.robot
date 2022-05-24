*** Settings ***
Documentation       Inhuman Insurance, Inc. Artificial Intelligence System robot.
...                 Consumes traffic data work items.

Resource            shared.resource


*** Tasks ***
Consume traffic data work items
    For Each Input Work Item    Process traffic data
    Log    Done.


*** Keywords ***
Process Traffic Data
    ${payload}=    Get Work Item Payload
    ${traffic_data}=    Set Variable    ${payload}[${WORK_ITEM_NAME}]
    ${valid}=    Validate Traffic Data    ${traffic_data}
    IF    ${valid}
        Post Traffic Data To Sales System    ${traffic_data}
    ELSE
        Handle Invalid Traffic Data    ${traffic_data}
    END

Validate Traffic Data
    [Arguments]    ${traffic_data}
    ${country}=    Get value from JSON    ${traffic_data}    $.country
    ${valid}=    Evaluate    len("${country}") == 3
    RETURN    ${valid}

Post Traffic Data To Sales System
    [Arguments]    ${traffic_data}
    ${status}    ${return}=    Run Keyword And Ignore Error
    ...    POST
    ...    https://robocorp.com/inhuman-insurance-inc/sales-system-api
    ...    json=${traffic_data}
    Handle Traffic API Response    ${status}    ${return}    ${traffic_data}

Handle Traffic API Response
    [Arguments]    ${status}    ${return}    ${traffic_data}
    IF    "${status}" == "PASS"
        Handle Traffic API OK Response
    ELSE
        Handle Traffic API Error Response    ${return}    ${traffic_data}
    END

Handle Traffic API OK Response
    Release Input Work Item    DONE

Handle Traffic API Error Response
    [Arguments]    ${return}    ${traffic_data}
    Log
    ...    Traffic data posting failed: ${traffic_data} ${return}
    ...    ERROR
    Release Input Work Item
    ...    state=FAILED
    ...    exception_type=APPLICATION
    ...    code=TRAFFIC_DATA_POST_FAILED
    ...    message=${return}

Handle Invalid Traffic Data
    [Arguments]    ${traffic_data}
    ${message}=    Set Variable    Invalid traffic data: ${traffic_data}
    Log    ${message}    WARN
    Release Input Work Item
    ...    state=FAILED
    ...    exception_type=BUSINESS
    ...    code=INVALID_TRAFFIC_DATA
    ...    message=${message}
