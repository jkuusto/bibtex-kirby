*** Settings ***
Resource  ../resource.robot
Suite Setup      Open And Configure Browser
Suite Teardown   Close Browser
Test Setup       Reset Bibtexs
Library  Collections

*** Test Cases ***
User can select and view references by a tag
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  Creating random articles.
    Input Text  author  Dummy, F.
    Input Text  journal  Journal about creating articles
    Input Text  year  2024
    Input Text    tags    random, robot
    Click Button    Create
    Click Link    Create book
    Input Text    title    Not creating non-random books.
    Input Text    author    Dummy, G.
    Input Text    publisher    Dummy Publisher
    Input Text    year    2023
    Input Text    tags    not random, robot
    Click Button    Create
    Wait For Condition    return document.readyState=="complete"
    Click Element    xpath=//div[@class='tag' and @data-tag='random'][1]
    Element Should Not Be Visible    xpath=//span[@class='bibtex-title' and @data-type='book']

User can search references
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  Creating random articles.
    Input Text  author  Dummy, A.
    Input Text  journal  Journal about creating articles
    Input Text  year  2024
    Click Button  Create

    Input Text  query  å
    Click Button  Search
    Page Should Contain  No results

    Input Text  query  creating
    Click Button  Search
    Page Should Contain  Creating random articles.

    Input Text  query  y
    Click Button  Search
    Page Should Contain  Creating random articles.

User can sort references by order of creation
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  A
    Input Text  author  Ensimmäinen, 1.
    Input Text  journal  Journal about creating articles
    Input Text  year  2023
    Click Button  Create
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  B
    Input Text  author  Toinen, 2.
    Input Text  journal  Journal about creating articles
    Input Text  year  2023
    Click Button  Create
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  C
    Input Text  author  Kolmas, 3.
    Input Text  journal  Journal about creating articles
    Input Text  year  2023
    Click Button  Create
    Go To  ${HOME_URL}
    Wait For Condition    return document.readyState=="complete"
    Select From List By Label    id=sort-options    Created first
    Wait For Condition    return document.readyState=="complete"
    ${elements}=  Get WebElements  xpath=//li[contains(@class, 'bibtex-item')]//span[contains(@class, 'bibtex-title')]
    ${titles}=  Create List
    FOR  ${element}  IN  @{elements}
        ${text}=  Get Text  ${element}
        Append To List  ${titles}  ${text}
    END
    Log Many  ${titles}
    Should Be Equal  ${titles[0]}  A
    Should Be Equal  ${titles[1]}  B
    Should Be Equal  ${titles[2]}  C

    Go To  ${HOME_URL}
    Select From List By Label    id=sort-options    Created last
    Wait For Condition    return document.readyState=="complete"
    ${elements}=  Get WebElements  xpath=//li[contains(@class, 'bibtex-item')]//span[contains(@class, 'bibtex-title')]
    ${titles}=  Create List
    FOR  ${element}  IN  @{elements}
        ${text}=  Get Text  ${element}
        Append To List  ${titles}  ${text}
    END
    Log Many  ${titles}
    Should Be Equal  ${titles[0]}  C
    Should Be Equal  ${titles[1]}  B
    Should Be Equal  ${titles[2]}  A

User can sort references alphabetically
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  CC
    Input Text  author  Ensimmäinen, 1.
    Input Text  journal  Journal about creating articles
    Input Text  year  2023
    Click Button  Create
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  AA
    Input Text  author  Toinen, 2.
    Input Text  journal  Journal about creating articles
    Input Text  year  2023
    Click Button  Create
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  DD
    Input Text  author  Kolmas, 3.
    Input Text  journal  Journal about creating articles
    Input Text  year  2023
    Click Button  Create
    Go To  ${HOME_URL}
    Wait For Condition    return document.readyState=="complete"
    Select From List By Label    id=sort-options    A-Z
    Wait For Condition    return document.readyState=="complete"
    ${elements}=  Get WebElements  xpath=//li[contains(@class, 'bibtex-item')]//span[contains(@class, 'bibtex-title')]
    ${titles}=  Create List
    FOR  ${element}  IN  @{elements}
        ${text}=  Get Text  ${element}
        Append To List  ${titles}  ${text}
    END
    Log Many  ${titles}
    Should Be Equal  ${titles[0]}  AA
    Should Be Equal  ${titles[1]}  CC
    Should Be Equal  ${titles[2]}  DD

    Go To  ${HOME_URL}
    Wait For Condition    return document.readyState=="complete"
    Select From List By Label    id=sort-options    Z-A
    Wait For Condition    return document.readyState=="complete"
    ${elements}=  Get WebElements  xpath=//li[contains(@class, 'bibtex-item')]//span[contains(@class, 'bibtex-title')]
    ${titles}=  Create List
    FOR  ${element}  IN  @{elements}
        ${text}=  Get Text  ${element}
        Append To List  ${titles}  ${text}
    END
    Log Many  ${titles}
    Should Be Equal  ${titles[0]}  DD
    Should Be Equal  ${titles[1]}  CC
    Should Be Equal  ${titles[2]}  AA

User can sort references by modification earliest 
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  First reference
    Input Text  author  First Author
    Input Text  journal  Journal 1
    Input Text  year  2023
    Click Button  Create
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  Second reference
    Input Text  author  Second Author
    Input Text  journal  Journal 2
    Input Text  year  2023
    Click Button  Create
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  Third reference
    Input Text  author  Third Author
    Input Text  journal  Journal 3
    Input Text  year  2023
    Click Button  Create

    # Edit the second reference
    Click Element  xpath=//span[@class='bibtex-title' and contains(text(), 'Second reference')]
    Input Text  title  Second reference edited again
    Click Button  Save
    Sleep  1s

    # Edit the first reference
    Click Element  xpath=//span[@class='bibtex-title' and contains(text(), 'First reference')]
    Input Text  title  First reference edited again
    Click Button  Save
    Sleep  1s

    # Edit the third reference
    Click Element  xpath=//span[@class='bibtex-title' and contains(text(), 'Third reference')]
    Input Text  title  Third reference edited again
    Click Button  Save
    Sleep  1s

    # Sort by earliest modified
    Go To  ${HOME_URL}
    Select From List By Label    id=sort-options    Earliest modified
    Sleep  5s

    # Verify the order
    ${elements}=  Get WebElements  xpath=//li[contains(@class, 'bibtex-item')]//span[contains(@class, 'bibtex-title')]
    ${titles}=  Create List
    FOR  ${element}  IN  @{elements}
        ${text}=  Get Text  ${element}
        Append To List  ${titles}  ${text}
    END
    Log Many  ${titles}
    Should Be Equal  ${titles[0]}  Second reference edited again
    Should Be Equal  ${titles[1]}  First reference edited again
    Should Be Equal  ${titles[2]}  Third reference edited again

User can sort references by year
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  b
    Input Text  author  First Author
    Input Text  journal  Journal 1
    Input Text  year  2023
    Click Button  Create
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  a
    Input Text  author  Second Author
    Input Text  journal  Journal 2
    Input Text  year  2023
    Click Button  Create
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  c
    Input Text  author  Third Author
    Input Text  journal  Journal 3
    Input Text  year  2010
    Click Button  Create

    Go To  ${HOME_URL}
    Select From List By Label    id=sort-options    Year (oldest first)
    Sleep  1s

    # Verify the order
    ${elements}=  Get WebElements  xpath=//li[contains(@class, 'bibtex-item')]//span[contains(@class, 'bibtex-title')]
    ${titles}=  Create List
    FOR  ${element}  IN  @{elements}
        ${text}=  Get Text  ${element}
        Append To List  ${titles}  ${text}
    END
    Log Many  ${titles}
    Should Be Equal  ${titles[0]}  c
    Should Be Equal  ${titles[1]}  a
    Should Be Equal  ${titles[2]}  b

    Go To  ${HOME_URL}
    Select From List By Label    id=sort-options    Year (newest first)
    Sleep  1s

    # Verify the order
    ${elements}=  Get WebElements  xpath=//li[contains(@class, 'bibtex-item')]//span[contains(@class, 'bibtex-title')]
    ${titles}=  Create List
    FOR  ${element}  IN  @{elements}
        ${text}=  Get Text  ${element}
        Append To List  ${titles}  ${text}
    END
    Log Many  ${titles}
    Should Be Equal  ${titles[0]}  a
    Should Be Equal  ${titles[1]}  b
    Should Be Equal  ${titles[2]}  c

User can navigate home from all pages
    Go To  ${HOME_URL}
    Click Link  Create article
    Click Element  xpath=//a[text()='Home']
    Page Should Contain  Create article
    Click Link  Create book
    Click Element  xpath=//a[text()='Home']
    Page Should Contain  Create book
    Click Link  Create inproceedings
    Click Element  xpath=//a[text()='Home']
    Page Should Contain  Create inproceedings
    Click Link  Create misc
    Click Element  xpath=//a[text()='Home']
    Page Should Contain  Create misc

User can open a URL Link
    Go To  ${HOME_URL}
    Click Link  Create article
    Input Text  title  Creating random repositories
    Input Text  author  Dummy, G.
    Input Text  journal  GitHub
    Input Text  year  2024
    Input Text    url    https://github.com/Uxusino/bibtex-kirby
    Click Button    Create
    Wait For Condition    return document.readyState=="complete"
    ${href_value}=    Get Element Attribute    xpath=//a[@id='url-btn']    href
    Log    Href Value: ${href_value}
    Should Be Equal    ${href_value}    https://github.com/Uxusino/bibtex-kirby
