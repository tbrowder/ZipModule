[![Actions Status](https://github.com/tbrowder/ZipModule/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/ZipModule/actions) [![Actions Status](https://github.com/tbrowder/ZipModule/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/ZipModule/actions) [![Actions Status](https://github.com/tbrowder/ZipModule/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/ZipModule/actions)

NAME
====

**ZipModule** - Use this module's 'zip-module' program to aid development of a Raku module with an AI agent

SYNOPSIS
========

This module provides Raku program `zip-module` to safely collect the standard data created in an `App::Mi6`-managed package into a `zip` file without inadvertently including private data hidden in other files (such as .git).

The target user is working on a new module and is using ChatGPT (or another AI agent) to assist. In a common scenario, ChatGPT will want the current state of the user's code or the user wants to ensure ChatGPT has his or her current code.

DESCRIPTION
===========

This module provides Raku program `zip-module` to safely do that without accidentally including any git data or private data in the process. 

Use of this module assumes the user is a developer creating a module using the standard layout created by `Mi6::Helper` or `App::Mi6` as shown here:

Files
-----

        Changes LICENSE META6.json dist.ini

Directories
-----------

        lib/ bin/ docs/ sbin/ t/ xt/ .github/

Example
=======

Safely copy a module directory

    zip-module </path/to/Some-Module>
    See zipped module "./Some-Module-SAFE.zip"

Then, using the appropiate AI agent's method, insert the zipped safe module directory into the AI agent's data input slot.

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2026 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

