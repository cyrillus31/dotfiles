---
name: google-workspace
description: "Create or modify Google Docs, Sheets, or Slides in the user’s Drive when explicitly requested."
---

Discover connected Google tools and inspect the target file, ownership context, and requested range or section. Consult the relevant API documentation for operations the connector does not explain. For Docs, account for UTF-16 positions and shifting indices; for Sheets, choose raw versus interpreted values deliberately; for Slides, preserve object IDs, transforms, and slide ordering. Apply narrowly scoped changes, reread the modified region, and return a direct file link. If no connector is available, explain the missing access rather than claiming the file was changed.
