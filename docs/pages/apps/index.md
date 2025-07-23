# Introduction

The Dust client supports embedded apps - web apps that integrate directly into the game client UI and interact with in-game objects and physics. Apps let developers build on top of the world and extend the game client with custom functionality like shops and marketplaces.

A Dust app is:

- A web app hosted at a URL
- Described by a JSON manifest ([schema](https://esm.sh/pr/dustproject/dust/dustkit@d9cb17b/json-schemas/app-config.json))
- Registered onchain (once per manifest URL)
- Launched manually (e.g. installing into client's "desktop" view) or contextually (e.g. opening a chest)

## Getting started

TODO

## Architecture Overview

```
User action (e.g. opens chest)
└─> Dust client (detects program + associated app)
      └─> <iframe> (loads app.startUrl)
          └─> DustKit SDK (postMessage bridge)
              └─> App signals 'ready'
                  └─> Client sends context to app:
                      - entityId
                      - world address
                      - user address
                      - client version
                      ...
```

### App lifecycle

1. **[Registration](registration)**: Developer interacts with the App Registry to register the app's manifest URL.
2. **Discovery**: The Dust client automatically detects app registrations.
3. **Launch**:
   - Manual: User opens via their desktop
   - Contextual: Interacts with an in-game entity (e.g. chest)
4. **Communication**:
   - App loads in iframe
   - [Dustkit](dustkit) sets up postMessage channel
   - App sends `ready` message
   - Client sends contextual info (e.g. `entityId` of chest that opened the app)
