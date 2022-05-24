*** Settings ***
Documentation       Inhuman Insurance, Inc. Artificial Intelligence System robot.
...                 Produces traffic data work items.

Library             Collections
Library             RPA.Tables
Resource            shared.resource


*** Variables ***
${TRAFFIC_JSON_FILE_PATH}=      ${OUTPUT_DIR}${/}traffic.json
# JSON data keys:
${COUNTRY_KEY}=                 SpatialDim
${RATE_KEY}=                    NumericValue
${GENDER_KEY}=                  Dim1
${YEAR_KEY}=                    TimeDim


*** Tasks ***
Produce traffic data work items
    Download Traffic Data
    ${traffic_data}=    Load Traffic Data As Table
    ${filtered_data}=    Filter And Sort Traffic Data    ${traffic_data}
    ${filtered_data}=    Get Latest Data By Country    ${filtered_data}
    ${payloads}=    Create Work Item Payloads    ${filtered_data}
    Save Work Item Payloads    ${payloads}


*** Keywords ***
Download Traffic Data
    Download
    ...    https://github.com/robocorp/inhuman-insurance-inc/raw/main/RS_198.json
    ...    ${TRAFFIC_JSON_FILE_PATH}
    ...    overwrite=True

Load Traffic Data As Table
    ${json}=    Load JSON from file    ${TRAFFIC_JSON_FILE_PATH}
    ${table}=    Create Table    ${json}[value]
    RETURN    ${table}

Filter And Sort Traffic Data
    [Arguments]    ${table}
    ${max_rate}=    Set Variable    ${5.0}
    ${both_genders}=    Set Variable    BTSX
    Filter Table By Column    ${table}    ${RATE_KEY}    <    ${max_rate}
    Filter Table By Column    ${table}    ${GENDER_KEY}    ==    ${both_genders}
    Sort Table By Column    ${table}    ${YEAR_KEY}    ascending=False
    RETURN    ${table}

Get Latest Data By Country
    [Arguments]    ${table}
    @{groups}=    Group Table By Column    ${table}    ${COUNTRY_KEY}
    ${latest_data_by_country}=    Create List
    FOR    ${group}    IN    @{groups}
        ${first_row}=    Pop Table Row    ${group}
        Append To List    ${latest_data_by_country}    ${first_row}
    END
    RETURN    ${latest_data_by_country}

Create Work Item Payloads
    [Arguments]    ${traffic_data}
    ${payloads}=    Create List
    FOR    ${row}    IN    @{traffic_data}
        ${payload}=    Create Dictionary
        ...    country=${row}[${COUNTRY_KEY}]
        ...    year=${row}[${YEAR_KEY}]
        ...    rate=${row}[${RATE_KEY}]
        Append To List    ${payloads}    ${payload}
    END
    RETURN    ${payloads}

Save Work Item Payloads
    [Arguments]    ${payloads}
    FOR    ${payload}    IN    @{payloads}
        Save Work Item Payload    ${payload}
    END

Save Work Item Payload
    [Arguments]    ${payload}
    ${variables}=    Create Dictionary    ${WORK_ITEM_NAME}=${payload}
    Create Output Work Item    variables=${variables}    save=True
