# App navigation guidance

Read the [navigation README](README.md) for route ownership, deep-link behaviour, and testing examples.

- App routes, localization, analytics, and page builders stay here; generic tab-shell mechanics belong in `packages/navigation`.
- Keep route access decisions explicit and cover redirects through the route-policy seam.
- Do not duplicate generic navigation mechanics in the app layer.
