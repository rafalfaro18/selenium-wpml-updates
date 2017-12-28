*** Settings ***

Library  SeleniumLibrary
Library  Collections
Library  String

*** Variables ***

${URL}    http://your-domain.lndo.site
${adminpage}    ${URL}/wp-admin
${time}      10s
${nav}      Chrome


*** Test Cases ***

Loguearse a Wordpress de MVC
    [Documentation]    Loguearse en worpress de staging
    Navegador    ${nav}
    Wait Until Page Contains   Log In
    BuiltIn.Sleep    500ms
    Input Text  user_login  YOUR_EMAIL_HERE
    Input Password  user_pass  YOUR_PASSWORD_HERE
    Submit Form	   loginform


Ir a paginas por arreglar, obtener los enlaces de los cards
    @{pagesToFix}  Create List      locations-eastern-usa/  locations-western-u-s/  locations-caribbean/   room-for-tradition/  locations-asia-australia/  locations-city-center/   spacesvillas/  spacesguestrooms-and-suites/  amenitiesbeach/  amenitiesmountain/   amenitiesgolf/
    Loop List   @{pagesToFix}

    Close Browser


*** Keywords ***

Navegador
    [Arguments]    ${path}
    Open Browser     ${adminpage}         ${path}

Dormir
    BuiltIn.Sleep   ${time}

Espera Elemento
    [Arguments]    ${string}
    Wait Until Page Contains   ${string}

Loop List
    [Arguments]    @{pages}
        :FOR   ${j}   IN   @{pages}
            \    Go To    ${URL}/${j}
            \    Page Should Contain Element    wpadminbar
            \    ${intlengthOfCards} =      Get Element Count        css:h3 a
            \    Log    ${intlengthOfCards}
            \    @{arraylinks} =  Execute Javascript	var x=[]; jQuery("h3 a").each(function() {x.push(this.href)}); return x;
            \    Loop Links  @{arraylinks}

Loop Links
    [Arguments]    @{links}
        :FOR    ${i}    IN  @{links}
            \    Log    Link ${i} \n
            \    Visitar    ${i}

Visitar
    [Arguments]    ${link}
    Go To    ${link}
    ${spanishLink} =  Execute Javascript	return jQuery("#icl_translate_options .icl_odd_row a")[0].href;
    Go To   ${spanishLink}
    Wait Until Page Contains   Save & Close
    ${spanishURL} =  Execute Javascript	return document.getElementsByName('fields[field-button_0_link-0][data]')[0].value;
    ${matchesBool} =   Execute Javascript	return document.getElementsByName('fields[field-button_0_link-0][data]')[0].value.indexOf('www.marriott.com');
    Run Keyword If  ${matchesBool}>=0    Cambiar String Final y Guardar    ${spanishURL}  .marriott.com    .espanol.marriott.com


Cambiar String Final y Guardar
    [Arguments]    ${link}   ${toReplace}  ${replacement}
    ${temp} =   Replace String    ${link}   ${toReplace}    ${replacement}
    Wait Until Page Contains   Save
    Input Text   fields[field-button_0_link-0][data]    ${temp}
    Click Button   class:js-save
    Alert Should Not Be Present    action=ACCEPT
