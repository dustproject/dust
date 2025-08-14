# Default Programs

The DUST client auto selects a default program when a player builds a smart object.

Default programs will make the builder the owner of that smart object. As an owner they are the only ones allowed to manage it, but they can change the owner to someone else (or to address(0) to freeze it).

## Force Field Program

- Allows owner to set the list of approved callers
- Approved callers can build, mine, add and remove fragments
- The force field allows all programs

## Chest Program

- Allows owner to set the list of approved callers
- Approved callers can transfer any items in and out

## Bed Program

- Allows owner to set the list of approved callers
- Approved callers can sleep and wakeup
