# XProject Generator (VS Code Extension)

Local VS Code extension that adds Tasks for running XProject Generator.

## Run in Extension Development Host

1. Open this repository in VS Code
2. Open folder `vscode-ext/`
3. Install dependencies:

```bash
npm install
```

4. Build:

```bash
npm run compile
```

5. Press `F5` to launch the Extension Development Host
6. In the new window, open a Flutter workspace and run:
   - `Tasks: Run Task` → `XProject-Generator: Create Project`
   - `Tasks: Run Task` → `XProject-Generator: Add Feature (prompt)`

## Settings

- `xprojectGenerator.command`: default `xproject` (requires global activation).  
  Alternative example: `dart run xproject_generator:xproject`
- `xprojectGenerator.cwd`: default `${workspaceFolder}`

