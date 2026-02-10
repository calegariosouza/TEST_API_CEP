*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    BuiltIn
Library    String
Library    OperatingSystem

*** Variables ***
${BASE_URL}    https://viacep.com.br
${CEPS_FILE}    ceps.csv

*** Test Cases ***
Validar API ViaCEP - Todos os CEPs
    ${ceps}=    Read CEPs From File
    FOR    ${cep_data}    IN    @{ceps}
        Validar CEP ViaCEP    ${cep_data}[cep]
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

Validar CEP ViaCEP
    [Arguments]    ${cep}
    [Documentation]    Valida um CEP específico na API ViaCEP
    
    Log To Console    \n[ViaCEP] Validando CEP ${cep}
    
    TRY
        Create Session    viaCep    ${BASE_URL}    verify=False    disable_warnings=1
        
        ${resp}=    GET On Session    viaCep    /ws/${cep}/json/    expected_status=any
        
        Should Be Equal As Integers    ${resp.status_code}    200
        
        ${json}=    Set Variable    ${resp.json()}
        
        # Validar se não retornou erro
        IF    'erro' in ${json}
            Log To Console    [ViaCEP] CEP não encontrado ⚠️
            RETURN
        END
        
        # Validações básicas
        Dictionary Should Contain Key    ${json}    cep
        Dictionary Should Contain Key    ${json}    localidade
        Dictionary Should Contain Key    ${json}    uf
        
        # Exibir dados
        IF    'logradouro' in ${json} and '${json}[logradouro]' != ''
            Log To Console    [ViaCEP] Logradouro: ${json}[logradouro]
        END
        
        Log To Console    [ViaCEP] Localidade: ${json}[localidade]
        Log To Console    [ViaCEP] UF: ${json}[uf]
        Log To Console    [ViaCEP] Validado com sucesso! ✅
        
    EXCEPT    AS    ${error}
        Log To Console    [ViaCEP] ERRO: ${error} ❌
        Fail    Falha na validação do CEP ${cep}
    END
