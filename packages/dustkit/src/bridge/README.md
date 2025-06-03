### Client

- Opens app in iframe
- Listens for messages from app (ideally via `event.source` matching the `iframe.contentWindow`) and containing `MessagePort`
- Establishes app-specific RPC listener over `MessagePort` and sends an initial message with app context to let app know its ready
- New `MessagePort` requests may come in at any time (i.e. after app navigates or a component re-mounts), and this should replace the current one (re-establish RPC listener)

### App (optional)

- Asks client (`window.opener ?? window.parent`) via `postMessage` for a dustkit bridge, offers `MessagePort`
- Client establishes port and sends back initial message with app context
- App handles context (e.g. redirects if opened via specific program or entity)
