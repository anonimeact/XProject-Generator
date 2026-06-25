import * as vscode from 'vscode';
import { spawn } from 'node:child_process';

type XProjectAction = 'create' | 'feature';

type XProjectTaskDefinition = vscode.TaskDefinition & {
  type: 'xproject';
  action: XProjectAction;
};

function getWorkspaceCwd(): string | undefined {
  const configured = vscode.workspace
    .getConfiguration('xprojectGenerator')
    .get<string>('cwd');

  const folder = vscode.workspace.workspaceFolders?.[0];
  const workspaceFolder = folder?.uri.fsPath;

  if (!configured || configured.trim().length === 0) return workspaceFolder;

  const trimmed = configured.trim();
  if (trimmed.includes('${workspaceFolder}')) {
    if (!workspaceFolder) return undefined;
    return trimmed.replaceAll('${workspaceFolder}', workspaceFolder);
  }

  return trimmed === '${workspaceFolder}' ? workspaceFolder : trimmed;
}

function getXProjectCommand(): string {
  return (
    vscode.workspace.getConfiguration('xprojectGenerator').get<string>('command') ??
    'xproject'
  ).trim();
}

function shellQuote(arg: string): string {
  if (arg.length === 0) return '""';
  if (/^[a-zA-Z0-9_./:-]+$/.test(arg)) return arg;
  return `"${arg.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"`
}

function joinShellCommand(command: string, args: string[]): string {
  const trimmedCommand = command.trim();
  const trimmedArgs = args.map((a) => a.trim()).filter((a) => a.length > 0);
  if (trimmedArgs.length === 0) return trimmedCommand;
  return `${trimmedCommand} ${trimmedArgs.map(shellQuote).join(' ')}`;
}

class XProjectTaskProvider implements vscode.TaskProvider {
  static readonly type = 'xproject';

  provideTasks(): vscode.ProviderResult<vscode.Task[]> {
    const cwd = getWorkspaceCwd();
    if (!cwd) return [];

    const command = getXProjectCommand();

    const createTask = new vscode.Task(
      { type: XProjectTaskProvider.type, action: 'create' } satisfies XProjectTaskDefinition,
      vscode.TaskScope.Workspace,
      'XProject-Generator: Create Project',
      'XProject Generator',
      new vscode.ShellExecution(joinShellCommand(command, ['create']), { cwd })
    );
    createTask.presentationOptions = { reveal: vscode.TaskRevealKind.Always };

    const featureTask = new vscode.Task(
      { type: XProjectTaskProvider.type, action: 'feature' } satisfies XProjectTaskDefinition,
      vscode.TaskScope.Workspace,
      'XProject-Generator: Add Feature (prompt)',
      'XProject Generator',
      new vscode.CustomExecution(async () => {
        const featureName = await vscode.window.showInputBox({
          prompt: 'Feature name (snake_case recommended)',
          placeHolder: 'authentication'
        });

        return new SpawnShellPseudoterminal({
          cwd,
          command,
          args: featureName ? ['--feature', featureName] : []
        });
      })
    );
    featureTask.presentationOptions = { reveal: vscode.TaskRevealKind.Always };

    return [createTask, featureTask];
  }

  resolveTask(
    task: vscode.Task,
    _token: vscode.CancellationToken
  ): vscode.ProviderResult<vscode.Task> {
    const definition = task.definition as Partial<XProjectTaskDefinition>;
    if (definition.type !== XProjectTaskProvider.type || !definition.action) {
      return undefined;
    }
    return task;
  }
}

class SpawnShellPseudoterminal implements vscode.Pseudoterminal {
  private readonly writeEmitter = new vscode.EventEmitter<string>();
  onDidWrite: vscode.Event<string> = this.writeEmitter.event;

  private readonly closeEmitter = new vscode.EventEmitter<void>();
  onDidClose?: vscode.Event<void> = this.closeEmitter.event;

  private child: ReturnType<typeof spawn> | undefined;

  constructor(
    private readonly opts: {
      cwd: string;
      command: string;
      args: string[];
    }
  ) {}

  open(): void {
    void this.run();
  }

  close(): void {
    this.child?.kill();
    this.closeEmitter.fire();
  }

  private async run(): Promise<void> {
    if (this.opts.args.length === 0) {
      this.writeEmitter.fire('Cancelled (no feature name provided).\r\n');
      this.closeEmitter.fire();
      return;
    }

    const full = joinShellCommand(this.opts.command, this.opts.args);
    this.writeEmitter.fire(`> ${full}\r\n`);

    const child = spawn(full, {
      cwd: this.opts.cwd,
      shell: true,
      env: process.env
    });
    this.child = child;

    child.stdout.on('data', (data: Buffer) => this.writeEmitter.fire(data.toString()));
    child.stderr.on('data', (data: Buffer) => this.writeEmitter.fire(data.toString()));

    child.on('error', (err) => {
      this.writeEmitter.fire(`\r\nFailed to start process: ${String(err)}\r\n`);
      this.closeEmitter.fire();
    });

    child.on('close', (code) => {
      this.writeEmitter.fire(`\r\nProcess exited with code ${code ?? 'unknown'}.\r\n`);
      this.closeEmitter.fire();
    });
  }
}

export function activate(context: vscode.ExtensionContext): void {
  const provider = new XProjectTaskProvider();
  context.subscriptions.push(
    vscode.tasks.registerTaskProvider(XProjectTaskProvider.type, provider)
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('xprojectGenerator.runCreate', async () => {
      const tasks = await provider.provideTasks();
      const task = tasks?.find(
        (t) => (t.definition as Partial<XProjectTaskDefinition>)?.action === 'create'
      );
      if (!task) return;
      await vscode.tasks.executeTask(task);
    })
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('xprojectGenerator.runFeature', async () => {
      const tasks = await provider.provideTasks();
      const task = tasks?.find(
        (t) => (t.definition as Partial<XProjectTaskDefinition>)?.action === 'feature'
      );
      if (!task) return;
      await vscode.tasks.executeTask(task);
    })
  );
}

export function deactivate(): void {}
