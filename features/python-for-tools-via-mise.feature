# AI understanding — review before green light
# Agreed: The project's mise configuration provides Python 3.12 so that the Python scripts in tools/ (policy checks and build info) run on a mise-managed interpreter, using the same commands as today. The CI policy job obtains its Python from the project's mise configuration instead of a separate Python setup step, with the user's explicit authorization to edit the otherwise immutable CI workflow. Every existing CI check and step still runs and nothing is weakened. The existing flutter and claude tool entries stay as they are.
# Out of scope: Node for the .mjs tools; mise tasks for lint, test, build or architecture; moving the CI flutter job to mise; changing .ai/decisions.json, tools/policy or any script in tools/; virtualenvs or Python packages.
# Checkable by: `mise exec -- python --version` prints 3.12.x; `mise exec -- python tools/policy/check_all.py` and `mise exec -- python tools/write_build_info.py` exit 0; `mise ls` still lists flutter and claude; the CI workflow file shows the policy job installing tools via mise with the same "Policy checks" command and an unchanged flutter job.

Feature: Python for the tools scripts via mise
  A developer working in the project directory gets Python 3.12 from mise,
  so the tools scripts run on the interpreter the toolchain specifies.
  CI's policy job gets the same Python from the same mise configuration,
  and every existing CI check still runs.

  Rule: mise provides Python 3.12 for the project

    Scenario: The project interpreter is Python 3.12
      Given the developer has run mise install in the project directory
      When the developer asks mise for the Python version
      Then the version reported is 3.12.x

    Scenario Outline: Tools scripts run on the mise Python
      Given the developer has run mise install in the project directory
      When the developer runs "<command>" through mise
      Then the command exits successfully

      Examples:
        | command                             |
        | python tools/policy/check_all.py    |
        | python tools/write_build_info.py    |

    Scenario: Installing again changes nothing
      Given Python 3.12 is already installed by mise for the project
      When the developer runs mise install again
      Then the same Python 3.12 version is still reported

  Rule: Existing tools in the mise configuration are unchanged

    Scenario Outline: Previously configured tools remain available
      Given the mise configuration now includes Python
      When the developer lists the project's mise tools
      Then "<tool>" is listed with its previous version setting

      Examples:
        | tool    |
        | flutter |
        | claude  |

  Rule: The CI policy job gets Python from the mise configuration

    Scenario: Policy job uses the mise-provided Python
      Given a pull request or a push to main
      When the CI policy job runs
      Then it installs Python from the project's mise configuration
      And it does not use a separate Python setup step

    Scenario: Policy checks still run in CI
      Given a pull request or a push to main
      When the CI policy job runs
      Then it runs "python tools/policy/check_all.py"
      And the job fails when that command fails

  Rule: The rest of CI is unchanged

    Scenario Outline: Flutter job steps still run as before
      Given the CI policy job has passed
      When the CI flutter job runs
      Then the "<step>" step runs as it did before this change

      Examples:
        | step                     |
        | flutter pub get          |
        | Analyze                  |
        | Architecture tests       |
        | Tests                    |
        | Build web                |
        | upload web build artifact |
