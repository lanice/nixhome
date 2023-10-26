[
  {
    key = "ctrl+7";
    command = "editor.action.commentLine";
    when = "editorTextFocus && !editorReadonly";
  }
  {
    key = "ctrl+shift+7";
    command = "editor.action.blockComment";
    when = "editorTextFocus && !editorReadonly";
  }
  {
    key = "ctrl+shift+a";
    command = "-editor.action.blockComment";
    when = "editorTextFocus && !editorReadonly";
  }
  {
    key = "ctrl+shift+up";
    command = "-editor.action.insertCursorAbove";
    when = "editorTextFocus";
  }
  {
    key = "ctrl+shift+up";
    command = "editor.action.moveLinesUpAction";
    when = "editorTextFocus && !editorReadonly";
  }
  {
    key = "ctrl+shift+down";
    command = "-editor.action.insertCursorBelow";
    when = "editorTextFocus";
  }
  {
    key = "ctrl+shift+down";
    command = "editor.action.moveLinesDownAction";
    when = "editorTextFocus && !editorReadonly";
  }
  {
    key = "alt+down";
    command = "-editor.action.moveLinesDownAction";
    when = "editorTextFocus && !editorReadonly";
  }
  {
    key = "alt+down";
    command = "editor.action.insertCursorBelow";
    when = "editorTextFocus";
  }
  {
    key = "alt+up";
    command = "-editor.action.moveLinesUpAction";
    when = "editorTextFocus && !editorReadonly";
  }
  {
    key = "alt+up";
    command = "editor.action.insertCursorAbove";
    when = "editorTextFocus";
  }
  {
    key = "ctrl+shift+d";
    command = "editor.action.copyLinesDownAction";
    when = "editorTextFocus && !editorReadonly";
  }
  {
    key = "ctrl+enter";
    command = "-github.copilot.generate";
    when = "editorTextFocus && github.copilot.activated && !inInteractiveInput && !interactiveEditorFocused";
  }
]
