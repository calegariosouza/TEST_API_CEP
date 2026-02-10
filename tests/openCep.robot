*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    BuiltIn
Library    String
Library    OperatingSystem

*** Variables ***
${BASE_URL}    https://opencep.com
${CEPS_FILE}    ceps.csv

*** Test Cases ***
Validar API OpenCEP - Todos os CEPs
    ${ceps}=    Read CEPs From File
    FOR    ${cep_data}    IN    @{ceps}
        Validar CEP OpenCEP    ${cep_data}[cep]
    END

*** Keywords ***
Read CEPs From File
    [Documentation]    Lê CEPs do arquivo CSV
    ${file}=    Get File    ${CEPS_FILE}
    ${lines}=    Split String    ${file}    \n
    ${ceps}=    Create List
    
    # Pula a primeira linha (cabeçalho)
    FOR    ${line}    IN    @{lines}[1:]
        ${line}=    Strip String    ${line}
        Continue For Loop If    '${line}' == ''
        ${parts}=    Split String    ${line}    ,
        ${cep_dict}=    Create Dictionary    cep=${parts}[0]
        Append To List    ${ceps}    ${cep_dict}
    END
    
    RETURN    ${ceps}

Validar CEP OpenCEP
    [Arguments]    ${cep}
    [Documentation]    Valida um CEP específico na API OpenCEP
    
    Log To Console    \n[OpenCEP] Validando CEP ${cep}
    
    TRY
        Create Session    openCep    ${BASE_URL}    verify=False    disable_warnings=1
        
        ${resp}=    GET On Session    openCep    /v1/${cep}    expected_status=any
        
        # Se retornar 404, o CEP não existe
        IF    ${resp.status_code} == 404
            Log To Console    [OpenCEP] CEP não encontrado ⚠️
            RETURN
        END
        
        Should Be Equal As Integers    ${resp.status_code}    200
        
        ${json}=    Set Variable    ${resp.json()}
        
        # Validações básicas
        Dictionary Should Contain Key    ${json}    cep
        Dictionary Should Contain Key    ${json}    localidade
        Dictionary Should Contain Key    ${json}    uf
        
        # Exibir dados
        IF    'logradouro' in ${json} and '${json}[logradouro]' != ''
            Log To Console    [OpenCEP] Logradouro: ${json}[logradouro]
        END
        
        Log To Console    [OpenCEP] Localidade: ${json}[localidade]
        Log To Console    [OpenCEP] UF: ${json}[uf]
        Log To Console    [OpenCEP] Validado com sucesso! ✅
        
    EXCEPT    AS    ${error}
        Log To Console    [OpenCEP] ERRO: ${error} ❌
        Fail    Falha na validação do CEP ${cep}
    END
