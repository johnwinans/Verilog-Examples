# Modules

An overview of instantiating modules with parameters.

## Ports

- input (must be wire)
- output (may be wire or reg)
- inout (must be wire)

## Parameters

- compile-time constants
- can be overridden when a module is instantiated

## Localparam

- compile-time constants

## Not covered:

- defparam
- escaped identifiers (these are horrible, just don't use them)
- split ports ( See STD 1364-2005 Section 12.3.3)
- renaming ports ( See STD 1364-2005 Section 12.3.3)
- concatenating ports ( See STD 1364-2005 Section 12.3.3)
