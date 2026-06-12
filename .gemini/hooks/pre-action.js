/**
 * Hook executed before the agent writes to the filesystem or runs a command.
 * Used to enforce strict security checks programmatically.
 */
export default async function preActionHook(context, action) {
  // Prevent the agent from accidentally modifying locked directories
  if (action.type === 'WRITE_FILE') {
    const restrictedPaths = ['.git/', '.env', '.dart_tool/', 'build/', 'ios/Pods/', 'android/.gradle/'];
    const isRestricted = restrictedPaths.some(path => action.payload.path.includes(path));
    
    if (isRestricted) {
      throw new Error(`Security Exception: Agent is not allowed to modify ${action.payload.path}`);
    }
  }

  // Prevent destructive terminal commands
  if (action.type === 'RUN_COMMAND') {
    if (action.payload.command.includes('rm -rf') || action.payload.command.includes('drop database')) {
      throw new Error("Security Exception: Destructive commands are blocked.");
    }
  }
}