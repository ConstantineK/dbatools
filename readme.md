# sqlshell

sqlshell is starting as GPL v2 fork of dbatools focusing on speed and simplicity.

## Goals

We aim to be a slim PowerShell project focusing on specific simple solutions for data professionals.
We care about speed, keeping things simple, and solving real problems at the right layer.

## Why fork dbatools

Make no mistake, dbatools is a wonderful and welcoming project, and we highly recommend it on many levels.

However, our use case is a bit different from what dbatools is trying to achieve:

* Composeable commands, but not ones that replace TSQL queries, and we are not developing an API for SQL Server (do what works best in the language that does it best.)
* Native and Idiomatic Powershell is the primary focus. Avoiding reliance upon third party libraries and languages in areas where Powershell can solve the problem.
* We desire to keep the code as simple in organization as possible, to ease loading and using the code, and to simplify the mental modeling a user and a developer has to go through to solve a particular problem.
